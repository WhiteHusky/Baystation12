/obj/item/modular_computer/proc/power_failure(var/malfunction = 0)
	if(enabled) // Shut down the computer
		visible_message("<span class='danger'>\The [src]'s screen flickers briefly and then goes dark.</span>", range = 1)
		if(active_program)
			active_program.event_powerfailure(0)
		for(var/datum/computer_file/program/PRG in idle_threads)
			PRG.event_powerfailure(1)
		shutdown_computer(0)

/obj/item/modular_computer/proc/get_uncharged_battery_modules()
	. = list()
	if(hardware_by_base_type[HARDWARE_BATTERY_MODULE] != null)
		for(var/obj/item/weapon/computer_hardware/battery_module/battery_module in hardware_by_base_type[HARDWARE_BATTERY_MODULE])
			if(battery_module.check_functionality() && battery_module.battery.charge < battery_module.battery.maxcharge)
				. += battery_module

/obj/item/modular_computer/proc/get_charged_battery_modules()
	. = list()
	if(hardware_by_base_type[HARDWARE_BATTERY_MODULE] != null)
		for(var/obj/item/weapon/computer_hardware/battery_module/battery_module in hardware_by_base_type[HARDWARE_BATTERY_MODULE])
			if(battery_module.check_functionality() && battery_module.battery.charge)
				. += battery_module

/obj/item/modular_computer/proc/get_any_charged_battery_module()
	if(hardware_by_base_type[HARDWARE_BATTERY_MODULE] != null)
		for(var/obj/item/weapon/computer_hardware/battery_module/battery_module in hardware_by_base_type[HARDWARE_BATTERY_MODULE])
			if(battery_module.check_functionality() && battery_module.battery.charge)
				return battery_module

/obj/item/modular_computer/proc/get_average_battery_charge_percent()
	var/total_charge = 0
	var/total_max_charge = 0
	if(hardware_by_base_type[HARDWARE_BATTERY_MODULE] != null)
		for(var/obj/item/weapon/computer_hardware/battery_module/battery_module in hardware_by_base_type[HARDWARE_BATTERY_MODULE])
			if(battery_module.check_functionality())
				total_charge += battery_module.battery.charge
				total_max_charge += battery_module.battery.maxcharge
		
		if(total_max_charge)
			return (total_charge / total_max_charge) * 100
		
	return 0

// Tries to use power from battery. Passing 0 as parameter results in this proc returning whether battery is functional or not.
/obj/item/modular_computer/proc/battery_power(var/power_usage = 0)
	apc_powered = FALSE
	if(!power_usage) // Just find a working battery
		if(hardware_by_base_type[HARDWARE_BATTERY_MODULE] != null) // Check if we have any.
			for(var/obj/item/weapon/computer_hardware/battery_module/battery_module in hardware_by_base_type[HARDWARE_BATTERY_MODULE])
				if(battery_module.check_functionality() && battery_module.battery.charge) // Check if it is working and has a charge.
					return TRUE
		
		return FALSE // No functional or charged batteries.
	else // Collect some charged batteries.
		var/list/batteries_to_drain = get_charged_battery_modules()
		while(batteries_to_drain.len)
			var/obj/item/weapon/computer_hardware/battery_module/battery_module = batteries_to_drain[1]
			power_usage -= FROM_CELLRATE(battery_module.battery.use(power_usage * CELLRATE))
			// Covert to cellrate, provide to battery, then convert actual used from cellrate and subtract the power_usage
			if(power_usage <= 0) // Battery supplied all power.
				return TRUE
			
			batteries_to_drain -= battery_module // Battery discharged, get another.
		
		return FALSE // Couldn't supply all power.

/obj/item/modular_computer/proc/check_tesla_functionality()
	if(hardware_by_base_type[HARDWARE_TESLA_LINK] != null)
		for(var/obj/item/weapon/computer_hardware/tesla_link/tesla_link in hardware_by_base_type[HARDWARE_TESLA_LINK])
			if(tesla_link.check_functionality())
				return TRUE
	return FALSE

// Tries to use power from APC, if present.
/obj/item/modular_computer/proc/apc_power(var/power_usage = 0)
	apc_powered = TRUE
	// Tesla link was originally limited to machinery only, but this probably works too, and the benefit of being able to power all devices from an APC outweights
	// the possible minor performance loss.

	if(hardware_by_base_type[HARDWARE_TESLA_LINK] != null) // We have present tesla links
		var/battery_present = hardware_by_base_type[HARDWARE_BATTERY_MODULE] != null ? TRUE : FALSE
		var/teslas_working = 0
		var/total_possible_charge = 0
		var/actual_provided_charge = 0
		for(var/obj/item/weapon/computer_hardware/tesla_link/tesla_link in hardware_by_base_type[HARDWARE_TESLA_LINK])
			if(tesla_link.check_functionality())
				teslas_working++
				if(!battery_present)
					break
				else
					total_possible_charge += tesla_link.passive_charging_rate
		
		if(!teslas_working) // No teslas working.
			return FALSE
		
		var/area/A = get_area(src)
		if(!istype(A) || !A.powered(EQUIP)) // Is area powered?
			return FALSE
		
		// We can use power. Let's charge some batteries.
		if(battery_present)
			var/list/batteries_to_charge = get_uncharged_battery_modules()
			while(batteries_to_charge.len) // Go through the batteries until all are charged or we run out of charge to provide this tick.
				var/obj/item/weapon/computer_hardware/battery_module/battery_module = batteries_to_charge[1]
				var/provided_converted = (actual_provided_charge - total_possible_charge) * CELLRATE
				actual_provided_charge += FROM_CELLRATE(battery_module.battery.give(provided_converted))
				if(total_possible_charge == actual_provided_charge) // We expended all the work we can do.
					break

				batteries_to_charge -= battery_module // Battery must be charged. Remove it from the list.
		
		A.use_power_oneoff(power_usage + actual_provided_charge, EQUIP) // Power usage, plus the power used to charge the batteries.
		return TRUE
	
	return FALSE

// Handles power-related things, such as battery interaction, recharging, shutdown when it's discharged
/obj/item/modular_computer/proc/handle_power()
	var/power_usage = screen_on ? base_active_power_usage : base_idle_power_usage
	for(var/obj/item/weapon/computer_hardware/H in hardware_installed)
		if(H.enabled)
			power_usage += H.power_usage
	last_power_usage = power_usage

	// First tries to charge from an APC, if APC is unavailable switches to battery power. If neither works the computer fails.
	if(apc_power(power_usage))
		return
	if(battery_power(power_usage))
		return
	power_failure()