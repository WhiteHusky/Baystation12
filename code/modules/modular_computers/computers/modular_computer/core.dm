/obj/item/modular_computer/Process()
	if(!enabled) // The computer is turned off
		last_power_usage = 0
		return 0
	if(shutdown_chance && prob(shutdown_chance)) // Faulty processors
		visible_message("<span class='danger'>\The [src]'s screen freezes for few seconds before turning blue and displaying \"SEGFAULT\".</span>" , range = 1)
		bsod = 1
		update_icon()
		shutdown_computer()
		return 0
	if(damage > broken_damage)
		shutdown_computer()
		return 0

	if(updating)
		handle_power()
		process_updates()
		return 1

	if(active_program)
		if(active_program.requires_ntnet && !get_ntnet_status(active_program.requires_ntnet_feature)) // Active program requires NTNet to run but we've just lost connection. Crash.
			active_program.event_networkfailure(0)
		else if(hardware_gid_to_hardware[active_program.disk_gid] == null) // Active program's disk has been removed. Crash.
			active_program.event_diskfailure(0)
	
	for(var/datum/computer_file/program/P in idle_threads)
		if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature))
			P.event_networkfailure(1)
		else if(hardware_gid_to_hardware[P.disk_gid] == null)
			P.event_diskfailure(1)
	if(active_program)
		if(active_program.program_state != PROGRAM_STATE_KILLED)
			active_program.ntnet_status = get_ntnet_status()
			active_program.computer_emagged = computer_emagged
			active_program.process_tick()
		else
			active_program = null

	for(var/datum/computer_file/program/P in idle_threads)
		if(P.program_state != PROGRAM_STATE_KILLED)
			P.ntnet_status = get_ntnet_status()
			P.computer_emagged = computer_emagged
			P.process_tick()
		else
			idle_threads.Remove(P)

	handle_power() // Handles all computer power interaction
	check_update_ui_need()

	var/static/list/beepsounds = list('sound/effects/compbeep1.ogg','sound/effects/compbeep2.ogg','sound/effects/compbeep3.ogg','sound/effects/compbeep4.ogg','sound/effects/compbeep5.ogg')
	if(enabled && world.time > ambience_last_played + 60 SECONDS && prob(1))
		ambience_last_played = world.time
		playsound(src.loc, pick(beepsounds),15,1,10, is_ambiance = 1)

// Used to perform preset-specific hardware changes.
/obj/item/modular_computer/proc/install_default_hardware()
	return 1

// Used to install preset-specific programs
/obj/item/modular_computer/proc/install_default_programs()
	return 1

/obj/item/modular_computer/proc/install_default_programs_by_job(var/mob/living/carbon/human/H)
	var/datum/job/jb = job_master.occupations_by_title[H.job]
	if(!jb) return
	for(var/prog_type in jb.software_on_spawn)
		var/datum/computer_file/program/prog_file = prog_type
		if(initial(prog_file.usage_flags) & hardware_flag)
			prog_file = new prog_file
			boot_device.store_file(prog_file)

/obj/item/modular_computer/Initialize()
	START_PROCESSING(SSobj, src)

	if(stores_pen && ispath(stored_pen))
		stored_pen = new stored_pen(src)

	hardware_installed = list()
	install_default_hardware()
	// Code for installing programs and initializing hardware moved to first_boot()
	
	update_icon()
	update_verbs()
	update_name()
	. = ..()

/obj/item/modular_computer/Destroy()
	kill_program(1)
	QDEL_NULL_LIST(terminals)
	STOP_PROCESSING(SSobj, src)
	if(istype(stored_pen))
		QDEL_NULL(stored_pen)
	for(var/obj/item/weapon/computer_hardware/CH in src.get_all_components())
		uninstall_component(null, CH)
		qdel(CH)
	return ..()

/obj/item/modular_computer/emag_act(var/remaining_charges, var/mob/user)
	if(computer_emagged)
		to_chat(user, "\The [src] was already emagged.")
		return NO_EMAG_ACT
	else
		computer_emagged = 1
		to_chat(user, "You emag \the [src]. It's screen briefly shows a \"OVERRIDE ACCEPTED: New software downloads available.\" message.")
		return 1

/obj/item/modular_computer/on_update_icon()
	icon_state = icon_state_unpowered

	overlays.Cut()
	if(bsod || updating)
		overlays.Add("bsod")
		return
	if(!enabled)
		if(icon_state_screensaver)
			overlays.Add(icon_state_screensaver)
		set_light(0)
		return
	set_light(0.2, 0.1, light_strength)
	if(active_program)
		overlays.Add(active_program.program_icon_state ? active_program.program_icon_state : icon_state_menu)
		if(active_program.program_key_state)
			overlays.Add(active_program.program_key_state)
	else
		overlays.Add(icon_state_menu)

/obj/item/modular_computer/proc/turn_on(var/mob/user)
	if(!completed_first_boot) // Initialize hardware.
		first_boot()
		completed_first_boot = TRUE
	if(bsod)
		return
	var/list/tesla_link_list = hardware_by_base_type[/obj/item/weapon/computer_hardware/tesla_link]
	if(tesla_link_list != null)
		for(var/obj/item/weapon/computer_hardware/tesla_link/tesla_link in tesla_link_list)
			tesla_link.enabled = 1
	var/issynth = issilicon(user) // Robots and AIs get different activation messages.
	if(damage > broken_damage)
		if(issynth)
			to_chat(user, "You send an activation signal to \the [src], but it responds with an error code. It must be damaged.")
		else
			to_chat(user, "You press the power button, but the computer fails to boot up, displaying variety of errors before shutting down again.")
		return
	if(max_idle_programs && (apc_power(0) || battery_power(0))) // Battery-run and charged or non-battery but powered by APC.
		if(issynth)
			to_chat(user, "You send an activation signal to \the [src], turning it on")
		else
			to_chat(user, "You press the power button and start up \the [src]")
		enable_computer(user)

	else // Unpowered
		if(issynth)
			to_chat(user, "You send an activation signal to \the [src] but it does not respond")
		else
			to_chat(user, "You press the power button but \the [src] does not respond")

// Relays kill program request to currently active program. Use this to quit current program.
/obj/item/modular_computer/proc/kill_program(var/forced = 0)
	if(active_program)
		active_program.kill_program(forced)
		active_program = null
	var/mob/user = usr
	if(user && istype(user))
		ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.
	update_icon()

// Returns 0 for No Signal, 1 for Low Signal and 2 for Good Signal. 3 is for wired connection (always-on)
/obj/item/modular_computer/proc/get_ntnet_status(var/specific_action = 0)
	var/calculated_status = 0
	if(hardware_by_base_type[HARDWARE_NETWORK_CARD] != null)
		for(var/obj/item/weapon/computer_hardware/network_card/card in hardware_by_base_type[HARDWARE_NETWORK_CARD])
			var/card_net_signal = card.get_signal(specific_action)
			calculated_status = (card_net_signal > calculated_status ? card_net_signal : calculated_status)
	
	return calculated_status

/obj/item/modular_computer/proc/get_ntnet_speed(var/specific_action = 0)
	var/total_speed = 0
	if(hardware_by_base_type[HARDWARE_NETWORK_CARD] != null)
		for(var/obj/item/weapon/computer_hardware/network_card/card in hardware_by_base_type[HARDWARE_NETWORK_CARD])
			var/card_net_signal = card.get_signal(specific_action)
			switch(card_net_signal)
				if(1)
					total_speed += NTNETSPEED_LOWSIGNAL
				if(2)
					total_speed += NTNETSPEED_HIGHSIGNAL
				if(3)
					total_speed += NTNETSPEED_ETHERNET

	return total_speed

/obj/item/modular_computer/proc/all_cards_banned()
	var/total_banned
	if(hardware_by_base_type[HARDWARE_NETWORK_CARD] != null)
		for(var/obj/item/weapon/computer_hardware/network_card/card in hardware_by_base_type[HARDWARE_NETWORK_CARD])
			if(card.is_banned())
				total_banned++
	return (total_banned == hardware_by_base_type[HARDWARE_NETWORK_CARD].len ? TRUE : FALSE)

/obj/item/modular_computer/proc/add_log(var/text)
	if(!get_ntnet_status())
		return 0
	if(hardware_by_base_type[HARDWARE_NETWORK_CARD] != null)
		for(var/obj/item/weapon/computer_hardware/network_card/card in hardware_by_base_type[HARDWARE_NETWORK_CARD])
			ntnet_global.add_log(text, card)
	return 

/obj/item/modular_computer/proc/shutdown_computer(var/loud = 1)
	kill_program(1)
	QDEL_NULL_LIST(terminals)
	for(var/datum/computer_file/program/P in idle_threads)
		P.kill_program(1)
		idle_threads.Remove(P)

	//Not so fast!
	if(updates)
		handle_updates(TRUE)
		update_icon()
		return

	if(loud)
		visible_message("\The [src] shuts down.", range = 1)
	enabled = 0
	update_icon()

/obj/item/modular_computer/proc/enable_computer(var/mob/user = null)
	enabled = 1

	//Not so fast!
	if(updates)
		handle_updates(FALSE)

	update_icon()

	// Autorun feature
	if(!updates)
		var/datum/computer_file/data/autorun = boot_device ? boot_device.find_file_by_name("autorun") : null
		if(istype(autorun))
			run_program(autorun.stored_data)

	if(user)
		ui_interact(user)

/obj/item/modular_computer/proc/minimize_program(mob/user)
	if(!active_program || !max_idle_programs)
		return

	idle_threads.Add(active_program)
	active_program.program_state = PROGRAM_STATE_BACKGROUND // Should close any existing UIs
	SSnano.close_uis(active_program.NM ? active_program.NM : active_program)
	active_program = null
	update_icon()
	if(istype(user))
		ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.


/obj/item/modular_computer/proc/run_program(prog, var/obj/item/weapon/computer_hardware/hard_drive/using_hdd)
	if(!using_hdd)
		using_hdd = boot_device
	var/datum/computer_file/program/P = null
	var/mob/user = usr
	if(using_hdd)
		P = using_hdd.find_file_by_name(prog)

	if(!P || !istype(P)) // Program not found or it's not executable program.
		to_chat(user, "<span class='danger'>\The [src]'s screen shows \"I/O ERROR - Unable to run [prog]\" warning.</span>")
		return

	P.computer = src
	if(!P.is_supported_by_hardware(hardware_flag, 1, user))
		return
	if(P in idle_threads)
		P.program_state = PROGRAM_STATE_ACTIVE
		active_program = P
		idle_threads.Remove(P)
		update_icon()
		return

	if(idle_threads.len >= max_idle_programs + 1)
		to_chat(user, "<span class='notice'>\The [src] displays a \"Maximal CPU load reached. Unable to run another program.\" error</span>")
		return

	if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature)) // The program requires NTNet connection, but we are not connected to NTNet.
		to_chat(user, "<span class='danger'>\The [src]'s screen shows \"NETWORK ERROR - Unable to connect to NTNet. Please retry. If problem persists contact your system administrator.\" warning.</span>")
		return

	if(active_program)
		minimize_program(user)

	if(P.run_program(user))
		active_program = P
		P.disk_gid = hardware_to_hardware_gid[using_hdd]
		update_icon()
	return 1

/obj/item/modular_computer/proc/update_uis()
	if(active_program) //Should we update program ui or computer ui?
		SSnano.update_uis(active_program)
		if(active_program.NM)
			SSnano.update_uis(active_program.NM)
	else
		SSnano.update_uis(src)

/obj/item/modular_computer/proc/check_update_ui_need()
	var/ui_update_needed = 0
	var/list/battery_module_list = hardware_by_base_type[/obj/item/weapon/computer_hardware/battery_module]
	if(battery_module_list != null)
		var/battery_percent = 0
		for(var/obj/item/weapon/computer_hardware/battery_module/battery_module in battery_module_list)
			battery_percent += battery_module.battery.percent()
		
		battery_percent = battery_percent / battery_module_list.len // Get average
		if(last_battery_percent != battery_percent) //Let's update UI on percent change
			ui_update_needed = 1
			last_battery_percent = battery_percent

	if(stationtime2text() != last_world_time)
		last_world_time = stationtime2text()
		ui_update_needed = 1

	if(idle_threads.len)
		var/list/current_header_icons = list()
		for(var/datum/computer_file/program/P in idle_threads)
			if(!P.ui_header)
				continue
			current_header_icons[P.type] = P.ui_header
		if(!last_header_icons)
			last_header_icons = current_header_icons

		else if(!listequal(last_header_icons, current_header_icons))
			last_header_icons = current_header_icons
			ui_update_needed = 1
		else
			for(var/x in last_header_icons|current_header_icons)
				if(last_header_icons[x]!=current_header_icons[x])
					last_header_icons = current_header_icons
					ui_update_needed = 1
					break

	if(ui_update_needed)
		update_uis()

// Used by camera monitor program
/obj/item/modular_computer/check_eye(var/mob/user)
	if(active_program)
		return active_program.check_eye(user)
	else
		return ..()

/obj/item/modular_computer/proc/set_autorun(program)
	if(!boot_device)
		return
	var/datum/computer_file/data/autorun = boot_device.find_file_by_name("autorun")
	if(!istype(autorun))
		autorun = new/datum/computer_file/data()
		autorun.filename = "autorun"
		autorun.stored_data = "[program]"
		boot_device.store_file(autorun)
	else
		autorun.stored_data = "[program]"

/obj/item/modular_computer/GetIdCard()
	var/list/cards = get_all_cards_broadcastable()
	if(cards.len)
		return pick(cards) // Pick a card. Any card.

/obj/item/modular_computer/proc/update_name()

/obj/item/modular_computer/get_cell() // Something is trying to charge. Probably.
	var/list/battery_modules = get_uncharged_battery_modules()
	var/obj/item/weapon/computer_hardware/battery_module/battery_module
	if(battery_modules.len)
		battery_module = pick(battery_modules)
		return battery_module.battery // Just keep giving random uncharged batteries.
	else // No more uncharged batteries. Give a charged one to appease whatever device.
		battery_module = get_any_charged_battery_module()
		if(battery_module)
			return battery_module.battery

/obj/item/modular_computer/proc/has_terminal(mob/user)
	for(var/datum/terminal/terminal in terminals)
		if(terminal.get_user() == user)
			return terminal

/obj/item/modular_computer/proc/open_terminal(mob/user)
	if(!enabled)
		return
	if(has_terminal(user))
		return
	LAZYADD(terminals, new /datum/terminal/(user, src))

/obj/item/modular_computer/proc/handle_updates(shutdown_after)
	updating = TRUE
	update_progress = 0
	update_postshutdown = shutdown_after

/obj/item/modular_computer/proc/process_updates()
	if(update_progress < updates)
		update_progress += rand(0, 2500)
		return

	//It's done.
	updating = FALSE
	update_icon()
	updates = 0
	update_progress = 0

	if(update_postshutdown)
		shutdown_computer()

/obj/item/modular_computer/proc/first_boot()
	if(hardware_installed.len) // Did we even install hardware?
		regenerate_hardware_lists() // Populate the lists.
		var/list/hdd_list = hardware_by_base_type[/obj/item/weapon/computer_hardware/hard_drive]
		if(hdd_list != null) // If there is a list, then there is at least one item.
			boot_device = hdd_list[1]
			install_default_programs()
		
		var/list/scanner_list = hardware_by_base_type[/obj/item/weapon/computer_hardware/scanner]
		if(scanner_list != null)
			for(var/obj/item/weapon/computer_hardware/scanner/scanner in scanner_list)
				scanner.do_after_install(null, src)