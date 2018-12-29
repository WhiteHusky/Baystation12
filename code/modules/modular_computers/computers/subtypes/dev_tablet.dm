/obj/item/modular_computer/tablet
	name = "tablet computer"
	desc = "A small, portable microcomputer."
	icon = 'icons/obj/modular_tablet.dmi'
	icon_state = "tablet"
	icon_state_unpowered = "tablet"

	icon_state_menu = "menu"
	hardware_flag = PROGRAM_TABLET
	ports_available = list(
		PORT_CPU = 1,
		PORT_POWER = 2,
		PORT_STORAGE = 1,
		PORT_CARD_READER = 1,
		PORT_EXPANSION = 3,
		PORT_EXTERNAL = 3
	)
	max_hardware_size = 1
	w_class = ITEM_SIZE_SMALL
	light_strength = 5 // same as PDAs

/obj/item/modular_computer/tablet/lease
	desc = "A small, portable microcomputer. This one has a gold and blue stripe, and a serial number stamped into the case."
	icon_state = "tabletsol"
	icon_state_unpowered = "tabletsol"