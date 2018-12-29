// Operates NanoUI
/obj/item/modular_computer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(!screen_on || !enabled || bsod)
		if(ui)
			ui.close()
		return 0
	if(!apc_power(0) && !battery_power(0))
		if(ui)
			ui.close()
		return 0

	// If we have an active program switch to it now.
	if(active_program)
		if(ui) // This is the main laptop screen. Since we are switching to program's UI close it for now.
			ui.close()
		active_program.ui_interact(user)
		return

	// We are still here, that means there is no program loaded. Load the BIOS/ROM/OS/whatever you want to call it.
	// This screen simply lists available programs and user may select them.
	var/list/data = list()
	data["boot_devices"] = null
	data["boot_device_present"] = (boot_device ? TRUE : FALSE)
	if(!boot_device) // Missing a boot device, so the user will have to select a new one. 
		var/list/hard_drives = hardware_by_base_type[HARDWARE_HARD_DRIVE]
		if(hard_drives != null)
			data["boot_devices"] = list()
			for(var/obj/hard_drive in hard_drives)
				data["boot_devices"].Add(hardware_to_hardware_gid[hard_drive])	
	else
		if(!boot_device.stored_files || !boot_device.stored_files.len)
			visible_message("\The [src] beeps three times, it's screen displaying \"DISK CORRUPTED\" warning.")
			boot_device = null // Should let the user select a different device.
			if(ui)
				ui.close()
			shutdown_computer()
			return
		else
			data += get_header_data()
			var/datum/computer_file/data/autorun = boot_device.find_file_by_name("autorun")
			var/list/programs = list()
			for(var/datum/computer_file/program/P in boot_device.stored_files)
				var/list/program = list()
				program["name"] = P.filename
				program["desc"] = P.filedesc
				program["icon"] = P.program_menu_icon
				program["autorun"] = (istype(autorun) && (autorun.stored_data == P.filename)) ? 1 : 0
				if(P in idle_threads)
					program["running"] = 1
				programs.Add(list(program))

			data["programs"] = programs

			data["updating"] = updating
			data["update_progress"] = update_progress
			data["updates"] = updates

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "laptop_mainscreen.tmpl", "DACOS Main Menu", 400, 500)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/item/modular_computer/CanUseTopic()
	//There is no bypassing the update, mwhahaha
	if(updating)
		return min(STATUS_UPDATE, ..())
	return ..()

// Handles user's GUI input
/obj/item/modular_computer/Topic(href, href_list)
	if(..())
		return 1
	if( href_list["BIOS_set_device"] )
		boot_device = hardware_gid_to_hardware[href_list["BIOS_set_device"]]
		return 1
	if( href_list["PC_exit"] )
		kill_program()
		return 1
	if( href_list["PC_enable_component"] )
		var/obj/item/weapon/computer_hardware/H = find_hardware_by_name(href_list["PC_enable_component"])
		if(H && istype(H) && !H.enabled)
			H.enabled = 1
		. = 1
	if( href_list["PC_disable_component"] )
		var/obj/item/weapon/computer_hardware/H = find_hardware_by_name(href_list["PC_disable_component"])
		if(H && istype(H) && H.enabled)
			H.enabled = 0
		. = 1
	if( href_list["PC_enable_update"] )
		receives_updates = TRUE
		. = 1
	if( href_list["PC_disable_update"] )
		receives_updates = FALSE
		. = 1
	if( href_list["PC_shutdown"] )
		shutdown_computer()
		return 1
	if( href_list["PC_minimize"] )
		var/mob/user = usr
		minimize_program(user)

	if( href_list["PC_killprogram"] )
		var/prog = href_list["PC_killprogram"]
		var/datum/computer_file/program/P = null
		var/mob/user = usr
		if(hard_drive)
			P = hard_drive.find_file_by_name(prog)

		if(!istype(P) || P.program_state == PROGRAM_STATE_KILLED)
			return

		P.kill_program(1)
		update_uis()
		to_chat(user, "<span class='notice'>Program [P.filename].[P.filetype] with PID [rand(100,999)] has been killed.</span>")

	if( href_list["PC_runprogram"] )
		return run_program(href_list["PC_runprogram"])

	if( href_list["PC_setautorun"] )
		if(!hard_drive)
			return
		set_autorun(href_list["PC_setautorun"])
	if( href_list["PC_terminal"] )
		open_terminal(usr)
		return 1

	if(.)
		update_uis()

// Function used by NanoUI's to obtain data for header. All relevant entries begin with "PC_"
/obj/item/modular_computer/proc/get_header_data()
	var/list/data = list()

	if(hardware_by_base_type[HARDWARE_BATTERY_MODULE] != null)
		var/battery_percent = get_average_battery_charge_percent()
		switch(battery_percent)
			if(80 to 200) // 100 should be maximal but just in case..
				data["PC_batteryicon"] = "batt_100.gif"
			if(60 to 80)
				data["PC_batteryicon"] = "batt_80.gif"
			if(40 to 60)
				data["PC_batteryicon"] = "batt_60.gif"
			if(20 to 40)
				data["PC_batteryicon"] = "batt_40.gif"
			if(5 to 20)
				data["PC_batteryicon"] = "batt_20.gif"
			else
				data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "[round(battery_percent)] %"
		data["PC_showbatteryicon"] = 1
	else
		data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "N/C"
		data["PC_showbatteryicon"] = hardware_by_base_type[HARDWARE_BATTERY_MODULE] != null ? 1 : 0

	if(check_tesla_functionality())
		data["PC_apclinkicon"] = "charging.gif"

	if(all_cards_banned())
		data["PC_ntneticon"] = "sig_warning.gif"
	else
		switch(get_ntnet_status())
			if(0)
				data["PC_ntneticon"] = "sig_none.gif"
			if(1)
				data["PC_ntneticon"] = "sig_low.gif"
			if(2)
				data["PC_ntneticon"] = "sig_high.gif"
			if(3)
				data["PC_ntneticon"] = "sig_lan.gif"

	var/list/program_headers = list()
	for(var/datum/computer_file/program/P in idle_threads)
		if(!P.ui_header)
			continue
		program_headers.Add(list(list(
			"icon" = P.ui_header
		)))
	if(active_program && active_program.ui_header)
		program_headers.Add(list(list(
			"icon" = active_program.ui_header
		)))
	data["PC_programheaders"] = program_headers

	data["PC_stationtime"] = stationtime2text()
	data["PC_hasheader"] = !updating
	data["PC_showexitprogram"] = active_program ? 1 : 0 // Hides "Exit Program" button on mainscreen
	return data