// This is special hardware configuration program.
// It is to be used only with modular computers.
// It allows you to toggle components of your device.

/datum/computer_file/program/computerconfig
	filename = "compconfig"
	filedesc = "Computer Configuration Tool"
	extended_desc = "This program allows configuration of computer's hardware"
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "gear"
	unsendable = 1
	undeletable = 1
	size = 4
	available_on_ntnet = 0
	requires_ntnet = 0
	nanomodule_path = /datum/nano_module/program/computer_configurator/
	usage_flags = PROGRAM_ALL

/datum/nano_module/program/computer_configurator
	name = "DACOS Computer Configuration Tool"
	var/obj/item/modular_computer/movable = null

/datum/nano_module/program/computer_configurator/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = GLOB.default_state)
	if(program)
		movable = program.computer
	if(!istype(movable))
		movable = null

	// No computer connection, we can't get data from that.
	if(!movable)
		return 0

	var/list/data = list()

	if(program)
		data = program.get_header_data()

	data["disk_size"] = movable.boot_device.max_capacity
	data["disk_used"] = movable.boot_device.used_capacity
	data["power_usage"] = movable.last_power_usage
	if(hardware_by_base_type[HARDWARE_BATTERY_MODULE] != null)
		data["battery_exists"] = 1
		for(var/obj/item/weapon/computer_hardware/battery_module/battery_module in hardware_by_base_type[HARDWARE_BATTERY_MODULE])

	data["battery_exists"] = movable.battery_module ? 1 : 0
	if(movable.battery_module)
		data["battery_rating"] = movable.battery_module.battery.maxcharge
		data["battery_percent"] = round(movable.battery_module.battery.percent())

	var/list/all_entries[0]
	for(var/obj/item/weapon/computer_hardware/H in hardware_installed)
		all_entries.Add(list(list(
		"name" = H.name,
		"desc" = H.desc,
		"enabled" = H.enabled,
		"critical" = H.critical,
		"powerusage" = H.power_usage,
		"mountpoint" = movable.hardware_to_hardware_gid[H]
		)))

	data["hardware"] = all_entries

	data["receives_updates"] = movable.receives_updates

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "laptop_configuration.tmpl", "DACOS Configuration Utility", 575, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()