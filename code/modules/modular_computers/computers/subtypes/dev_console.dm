/obj/item/modular_computer/console
	name = "console"
	desc = "A stationary computer."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	icon_state_unpowered = "console"
	icon_state_menu = "menu"
	hardware_flag = PROGRAM_CONSOLE
	ports_available = list(
		PORT_CPU = 1,
		PORT_POWER = 2,
		PORT_STORAGE = 4,
		PORT_CARD_READER = 1,
		PORT_EXPANSION = 6,
		PORT_EXTERNAL = 4
	)
	anchored = TRUE
	density = 1
	w_class = ITEM_SIZE_GARGANTUAN
	base_idle_power_usage = 100
	base_active_power_usage = 500
	max_hardware_size = 3
	steel_sheet_cost = 20
	light_strength = 4
	max_damage = 300
	broken_damage = 150
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_CLIMBABLE

/obj/item/modular_computer/console/CouldUseTopic(var/mob/user)
	..()
	if(istype(user, /mob/living/carbon))
		if(prob(50))
			playsound(src, "keyboard", 40)
		else
			playsound(src, "keystroke", 40)