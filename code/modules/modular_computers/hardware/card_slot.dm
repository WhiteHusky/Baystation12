/obj/item/weapon/computer_hardware/card_slot
	name = "RFID card slot"
	desc = "Slot that allows this computer to write data on RFID cards. Necessary for some programs to run properly."
	power_usage = 10 //W
	critical = 0
	icon_state = "cardreader"
	hardware_size = 1
	origin_tech = list(TECH_DATA = 2)
	usage_flags = PROGRAM_ALL & ~PROGRAM_PDA
	port_type = PORT_CARD_READER
	base_type = /obj/item/weapon/computer_hardware/card_slot
	max_items = 1
	var/can_write = TRUE
	var/can_broadcast = FALSE

	var/obj/item/weapon/card/id/stored_card = null

/obj/item/weapon/computer_hardware/card_slot/examine(var/user)
	. = ..()
	if(stored_card)
		to_chat(user, "There appears to be a card still inside it.")


/obj/item/weapon/computer_hardware/card_slot/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(..())
		return 1
	if(istype(W, /obj/item/weapon/card/id))
		insert_item(user, W)
		return
	
	if(isScrewdriver(W))
		eject_contents(user, src)
		return
		

/obj/item/weapon/computer_hardware/card_slot/broadcaster // read only
	name = "RFID card broadcaster"
	desc = "Reads and broadcasts the RFID signal of an inserted card."
	can_write = FALSE
	can_broadcast = TRUE

	usage_flags = PROGRAM_PDA

/obj/item/weapon/computer_hardware/card_slot/Destroy()
	eject_contents()
	holder2 = null
	return ..()