/obj/item/modular_computer/pda/install_default_hardware()
	..()

	hardware_installed += new /obj/item/weapon/computer_hardware/network_card/(src)
	hardware_installed += new /obj/item/weapon/computer_hardware/hard_drive/small(src)
	hardware_installed += new /obj/item/weapon/computer_hardware/processor_unit/small(src)
	hardware_installed += new /obj/item/weapon/computer_hardware/card_slot/broadcaster(src)
	hardware_installed += new /obj/item/weapon/computer_hardware/battery_module(src)
	battery_module.charge_to_full()

	hardware_installed += new /obj/item/weapon/computer_hardware/tesla_link(src)

/obj/item/modular_computer/pda/install_default_programs()
	..()

	boot_device.store_file(new /datum/computer_file/program/chatclient())
	boot_device.store_file(new /datum/computer_file/program/email_client())
	boot_device.store_file(new /datum/computer_file/program/crew_manifest())
	boot_device.store_file(new /datum/computer_file/program/wordprocessor())
	boot_device.store_file(new /datum/computer_file/program/records())
	if(prob(50)) //harmless tax software
		boot_device.store_file(new /datum/computer_file/program/uplink())
	set_autorun("emailc")

/obj/item/modular_computer/pda/medical/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/medical(src)

/obj/item/modular_computer/pda/chemistry/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/reagent(src)

/obj/item/modular_computer/pda/engineering/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/atmos(src)

/obj/item/modular_computer/pda/science/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/reagent(src)

/obj/item/modular_computer/pda/forensics/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/reagent(src)

/obj/item/modular_computer/pda/heads/hop/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/paper(src)

/obj/item/modular_computer/pda/heads/hos/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/paper(src)

/obj/item/modular_computer/pda/heads/ce/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/atmos(src)

/obj/item/modular_computer/pda/heads/cmo/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/medical(src)

/obj/item/modular_computer/pda/heads/rd/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/paper(src)

/obj/item/modular_computer/pda/cargo/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/paper(src)

/obj/item/modular_computer/pda/captain/install_default_hardware()
	..()
	hardware_installed += new /obj/item/weapon/computer_hardware/scanner/paper(src)