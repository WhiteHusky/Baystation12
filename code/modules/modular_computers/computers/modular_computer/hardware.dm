/obj/item/modular_computer/proc/regenerate_hardware_lists()
	if(!completed_first_boot) // In case someone modifies a fresh computer
		first_boot()
		completed_first_boot = TRUE
	if(hardware_installed.len > hardware_to_hardware_gid.len) // Hardware installed.
		var/list/new_hardware = hardware_installed - hardware_to_hardware_gid // Generates a list of new hardware.
		for(var/obj/item/weapon/computer_hardware/hardware in new_hardware)
			var/new_hid
			do
				new_hid = "/dev/[hardware.port_type.mount]-[uppertext(generateRandomString(6))]" // Generate a new hid
				// If everything went well, we'll get something like
				// /dev/hata-6C8349
			while(!hardware_gid_to_hardware[new_hid])
			
			if(!ports_occupied[hardware.port_type]) // No list present for that port.
				ports_occupied[hardware.port_type] = list() // Add port type list if wasn't present.
			
			if(!hardware_by_base_type[hardware.base_type]) // No list for that basetype
				hardware_by_base_type[hardware.base_type] = list() // Add base type list if wasn't present.
			
			ports_occupied[hardware.port_type] += hardware // Add the hardware to the port list.
			hardware_by_base_type[hardware.base_type] += hardware // Add the hardware to the base type list.
			hardware_gid_to_hardware[new_hid] = hardware // Add the hardware to it's gid.
			hardware_to_hardware_gid[hardware] = new_hid // Add the gid to the hardware.
	else // Hardware removed
		var/list/removed_hardware = hardware_to_hardware_gid - hardware_installed
		for(var/obj/item/weapon/computer_hardware/hardware in removed_hardware)
			ports_occupied[hardware.port_type] -= hardware // Remove the hardware from the port list.
			hardware_by_base_type[hardware.port_type] -= hardware // Remove the hardware from the base type list.
			if(ports_occupied[hardware.port_type].len == 0)	// Port type is empty.
				ports_occupied -= hardware.port_type // Remove port type if empty.
			
			if(hardware_by_base_type[hardware.base_type].len == 0)	// Base type is empty.
				hardware_by_base_type -= hardware.base_type // Remove base type if empty.
			
			var/old_hid = hardware_to_hardware_gid[hardware] // Store the old hid.
			hardware_gid_to_hardware -= old_hid // Remove the hardware from it's hid.
			hardware_to_hardware_gid -= hardware // Remove the gid from it's hardware.
	
	post_regenerate_hardware_lists()

/obj/item/modular_computer/proc/post_regenerate_hardware_lists()
	max_idle_programs = 0
	shutdown_chance = 0
	var/list/processor_list = hardware_by_base_type[/obj/item/weapon/computer_hardware/processor_unit]
	if(processor_list != null)
		for(var/obj/item/weapon/computer_hardware/processor_unit/processor in processor_list)
			max_idle_programs += processor.max_idle_programs
			if(processor.damage >= processor.damage_malfunction)
				if(processor.damage >= processor.damage_failure)
					shutdown_chance += 100
				else
					shutdown_chance += processor.malfunction_probability
		shutdown_chance = shutdown_chance / processor_list.len

// Attempts to install the hardware into an appropriate slot.
/obj/item/modular_computer/proc/try_install_component(var/mob/living/user, var/obj/item/weapon/computer_hardware/H)
	if(!H)
		return
	var/installed = FALSE
	if(H.hardware_size <= max_hardware_size)
		to_chat(user, "This component is too large for \the [src].")
		return FALSE
	
	if(!(H.usage_flags & hardware_flag))
		to_chat(user, "This computer isn't compatible with [H].")
		return FALSE
	
	if(ports_available[H.port_type]) // Do we have a port?
		if(ports_occupied[H.port_type]) // Can we check a port amount?
			if(ports_occupied[H.port_type].len + 1 > ports_available[H.port_type]) // Will the hardware overflow the available ports?
				to_chat(user, "You can't find a free [H.port_type.name].")
				return FALSE

		else // We can't check a port amount, but there might be space.
			if(ports_available[H.port_type] == 0) // There shouldn't be a port declared if it's max size is 0, but just in case.
				to_chat(user, "You can't find a [H.port_type.name]. <i>But you thought you saw one...</i>") // Snark/suggest something wrong.
				return FALSE
	
	else // No port for that certain port type.
		to_chat(user, "You can't find a [H.port_type.name].")
		return FALSE
	
	user.unEquip(H, src) // Yoink
	hardware_installed += H
	regenerate_hardware_lists()
	to_chat(user, "You install \the [H] into \the [src] with \the [H.port_type]")
	H.on_insert(src)
	update_verbs()
	return TRUE

// Removes components from a computer when provided a piece of hardware.
/obj/item/modular_computer/proc/uninstall_component(var/mob/living/user, var/obj/item/weapon/computer_hardware/H)
	if(!locate(H) in hardware_installed) // In the event two people are removing hardware.
		if(user)
			to_chat(user, "You can not find \the [H] from in \the [src] to remove it.")
			return FALSE
	
	hardware_installed -= H
	H.eject(user, src)
	
	if(enabled)
		switch(H.port_type)
			if(PORT_CPU) // Removing CPUs regardless of how many installed should probably not be removed while the computer is running.
				visible_message("<span class='danger'>\The [src]'s screen suddenly goes black and emits a few beeps!</span>", range = 1)
				playsound(src.loc, 'sound/machines/twobeep.ogg', 75, 1)
				if(user && prob(50)) // Also punish them.
					H.damage += H.damage_malfunction
					to_chat(user, "<span class='danger'>\The [src] makes a pop!</span>")
				shutdown_computer()
				update_icon()
			if(PORT_STORAGE)
				if(H == boot_device) // Equally not wise to remove the booting hard drive.
					visible_message("<span class='danger'>\The [src]'s screen freezes for few seconds before filling with blackness as the line \"I/O ERROR\" repeats across before shutting down.</span>", range = 1)
					shutdown_computer()
					update_icon()
	
	return TRUE