/obj/item/modular_computer/console/preset/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/processor_unit(src)
	hardware_installed += new/obj/item/weapon/computer_hardware/tesla_link(src)
	hardware_installed += new/obj/item/weapon/computer_hardware/hard_drive/super(src)
	hardware_installed += new/obj/item/weapon/computer_hardware/network_card/wired(src)
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/paper(src)

// Engineering
/obj/item/modular_computer/console/preset/engineering/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/power_monitor())
	boot_device.store_file(new/datum/computer_file/program/supermatter_monitor())
	boot_device.store_file(new/datum/computer_file/program/alarm_monitor())
	boot_device.store_file(new/datum/computer_file/program/atmos_control())
	boot_device.store_file(new/datum/computer_file/program/rcon_console())
	boot_device.store_file(new/datum/computer_file/program/camera_monitor())
	boot_device.store_file(new/datum/computer_file/program/shields_monitor())

// Medical
/obj/item/modular_computer/console/preset/medical/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/medical/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/suit_sensors())
	boot_device.store_file(new/datum/computer_file/program/camera_monitor())
	boot_device.store_file(new/datum/computer_file/program/records())
	boot_device.store_file(new/datum/computer_file/program/wordprocessor())
	set_autorun("sensormonitor")

// Research
/obj/item/modular_computer/console/preset/research/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/ai_slot(src)

/obj/item/modular_computer/console/preset/research/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/ntnetmonitor())
	boot_device.store_file(new/datum/computer_file/program/nttransfer())
	boot_device.store_file(new/datum/computer_file/program/chatclient())
	boot_device.store_file(new/datum/computer_file/program/camera_monitor())
	boot_device.store_file(new/datum/computer_file/program/aidiag())
	boot_device.store_file(new/datum/computer_file/program/email_client())
	boot_device.store_file(new/datum/computer_file/program/wordprocessor())

// Administrator
/obj/item/modular_computer/console/preset/sysadmin/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/ai_slot(src)

/obj/item/modular_computer/console/preset/sysadmin/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/ntnetmonitor())
	boot_device.store_file(new/datum/computer_file/program/nttransfer())
	boot_device.store_file(new/datum/computer_file/program/chatclient())
	boot_device.store_file(new/datum/computer_file/program/camera_monitor())
	boot_device.store_file(new/datum/computer_file/program/aidiag())
	boot_device.store_file(new/datum/computer_file/program/email_client())
	boot_device.store_file(new/datum/computer_file/program/email_administration())
	boot_device.store_file(new/datum/computer_file/program/records())
	boot_device.store_file(new/datum/computer_file/program/wordprocessor())

// Command
/obj/item/modular_computer/console/preset/command/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/nano_printer(src)
	hardware_installed += new/obj/item/weapon/computer_hardware/card_slot(src)

/obj/item/modular_computer/console/preset/command/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/chatclient())
	boot_device.store_file(new/datum/computer_file/program/comm())
	boot_device.store_file(new/datum/computer_file/program/camera_monitor())
	boot_device.store_file(new/datum/computer_file/program/email_client())
	boot_device.store_file(new/datum/computer_file/program/records())
	boot_device.store_file(new/datum/computer_file/program/wordprocessor())
	boot_device.store_file(new/datum/computer_file/program/docking())

// Security
/obj/item/modular_computer/console/preset/security/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/security/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/camera_monitor())
	boot_device.store_file(new/datum/computer_file/program/digitalwarrant())
	boot_device.store_file(new/datum/computer_file/program/forceauthorization())
	boot_device.store_file(new/datum/computer_file/program/records())
	boot_device.store_file(new/datum/computer_file/program/wordprocessor())

// Civilian
/obj/item/modular_computer/console/preset/civilian/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/chatclient())
	boot_device.store_file(new/datum/computer_file/program/nttransfer())
	boot_device.store_file(new/datum/computer_file/program/newsbrowser())
	boot_device.store_file(new/datum/computer_file/program/camera_monitor())
	boot_device.store_file(new/datum/computer_file/program/email_client())
	boot_device.store_file(new/datum/computer_file/program/supply())
	boot_device.store_file(new/datum/computer_file/program/records())
	boot_device.store_file(new/datum/computer_file/program/wordprocessor())

// Offices
/obj/item/modular_computer/console/preset/civilian/professional/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/nano_printer(src)

//Dock control
/obj/item/modular_computer/console/preset/dock/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/dock/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/nttransfer())
	boot_device.store_file(new/datum/computer_file/program/email_client())
	boot_device.store_file(new/datum/computer_file/program/supply())
	boot_device.store_file(new/datum/computer_file/program/wordprocessor())
	boot_device.store_file(new/datum/computer_file/program/docking())

// Crew-facing supply ordering computer
/obj/item/modular_computer/console/preset/supply/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/supply/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/supply())
	set_autorun("supply")

// ERT
/obj/item/modular_computer/console/preset/ert/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/ai_slot(src)
	hardware_installed += new/obj/item/weapon/computer_hardware/nano_printer(src)
	hardware_installed += new/obj/item/weapon/computer_hardware/card_slot(src)

/obj/item/modular_computer/console/preset/ert/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/nttransfer())
	boot_device.store_file(new/datum/computer_file/program/camera_monitor/ert())
	boot_device.store_file(new/datum/computer_file/program/alarm_monitor())
	boot_device.store_file(new/datum/computer_file/program/comm())
	boot_device.store_file(new/datum/computer_file/program/aidiag())
	boot_device.store_file(new/datum/computer_file/program/records())
	boot_device.store_file(new/datum/computer_file/program/wordprocessor())

// Mercenary
/obj/item/modular_computer/console/preset/mercenary/
	computer_emagged = TRUE

/obj/item/modular_computer/console/preset/mercenary/install_default_hardware()
	..()
	hardware_installed += new/obj/item/weapon/computer_hardware/ai_slot(src)
	hardware_installed += new/obj/item/weapon/computer_hardware/nano_printer(src)
	hardware_installed += new/obj/item/weapon/computer_hardware/card_slot(src)

/obj/item/modular_computer/console/preset/mercenary/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/camera_monitor/hacked())
	boot_device.store_file(new/datum/computer_file/program/alarm_monitor())
	boot_device.store_file(new/datum/computer_file/program/aidiag())

// Merchant
/obj/item/modular_computer/console/preset/merchant/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/merchant())
	boot_device.store_file(new/datum/computer_file/program/wordprocessor())

// Library
/obj/item/modular_computer/console/preset/library/install_default_programs()
	..()
	boot_device.store_file(new/datum/computer_file/program/nttransfer())
	boot_device.store_file(new/datum/computer_file/program/newsbrowser())
	boot_device.store_file(new/datum/computer_file/program/email_client())
	boot_device.store_file(new/datum/computer_file/program/wordprocessor())
	boot_device.store_file(new/datum/computer_file/program/library())