/obj/item/modular_computer/telescreen/preset/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/processor_unit(src)
	hardware_installed += new/obj/item/weapon/computer_hardware/tesla_link(src)
	hardware_installed += new/obj/item/weapon/computer_hardware/hard_drive(src)
	hardware_installed += new/obj/item/weapon/computer_hardware/network_card(src)

/obj/item/modular_computer/telescreen/preset/generic/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/alarm_monitor())
	boot_device.store_file(new/datum/computer_file/program/camera_monitor())
	set_autorun("cammon")

/obj/item/modular_computer/telescreen/preset/medical/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/camera_monitor())
	boot_device.store_file(new/datum/computer_file/program/records())
	boot_device.store_file(new/datum/computer_file/program/suit_sensors())
	set_autorun("sensormonitor")

/obj/item/modular_computer/telescreen/preset/engineering/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/alarm_monitor())
	boot_device.store_file(new/datum/computer_file/program/camera_monitor())
	boot_device.store_file(new/datum/computer_file/program/shields_monitor())
	boot_device.store_file(new/datum/computer_file/program/supermatter_monitor())
	set_autorun("alarmmonitor")
