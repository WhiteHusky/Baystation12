#define CARD_SLOT_NAME "RFID card slot"
#define CARD_SLOT_CARD "ID card"
#define INTELLICARD_SLOT_NAME "intellicard slot"
#define INTELLICARD_SLOT_CARD "intellicard"

/*
/obj/item/modular_computer/proc/does_any_card_slots_contain_an_id()
	var/card_slot_list = hardware_by_base_type[HARDWARE_CARD_SLOT]
	if(card_slot_list != null)
		for(var/obj/item/weapon/computer_hardware/card_slot/card_slot in card_slot_list)
			if(card_slot.stored_card)
				return TRUE
	return FALSE

/obj/item/modular_computer/proc/are_any_card_slots_empty()
	var/card_slot_list = hardware_by_base_type[HARDWARE_CARD_SLOT]
	if(card_slot_list != null)
		for(var/obj/item/weapon/computer_hardware/card_slot/card_slot in card_slot_list)
			if(!card_slot.stored_card)
				return TRUE
	return FALSE

/obj/item/modular_computer/proc/get_card_slots_containing_an_id()
	. = list()
	var/card_slot_list = hardware_by_base_type[HARDWARE_CARD_SLOT]
	if(card_slot_list != null)
		for(var/obj/item/weapon/computer_hardware/card_slot/card_slot in card_slot_list)
			if(card_slot.stored_card)
				. += card_slot

/obj/item/modular_computer/proc/get_empty_card_slots()
	. = list()
	var/card_slot_list = hardware_by_base_type[HARDWARE_CARD_SLOT]
	if(card_slot_list != null)
		for(var/obj/item/weapon/computer_hardware/card_slot/card_slot in card_slot_list)
			if(!card_slot.stored_card)
				. += card_slot

/obj/item/modular_computer/proc/does_any_ai_slots_contain_an_ai()
	var/ai_slot_list = hardware_by_base_type[HARDWARE_AI_SLOT]
	if(ai_slot_list != null)
		for(var/obj/item/weapon/computer_hardware/ai_slot/ai_slot in ai_slot_list)
			if(ai_slot.stored_card)
				return TRUE
	return FALSE

/obj/item/modular_computer/proc/are_any_ai_slots_empty()
	var/ai_slot_list = hardware_by_base_type[HARDWARE_AI_SLOT]
	if(ai_slot_list != null)
		for(var/obj/item/weapon/computer_hardware/ai_slot/ai_slot in ai_slot_list)
			if(!ai_slot.stored_card)
				return TRUE
	return FALSE

/obj/item/modular_computer/proc/get_ai_slots_containing_an_ai()
	. = list()
	var/ai_slot_list = hardware_by_base_type[HARDWARE_AI_SLOT]
	if(ai_slot_list != null)
		for(var/obj/item/weapon/computer_hardware/card_slot/ai_slot in ai_slot_list)
			if(ai_slot.stored_card)
				. += ai_slot

/obj/item/modular_computer/proc/get_empty_ai_slots()
	. = list()
	var/ai_slot_list = hardware_by_base_type[HARDWARE_AI_SLOT]
	if(ai_slot_list != null)
		for(var/obj/item/weapon/computer_hardware/card_slot/ai_slot in ai_slot_list)
			if(!ai_slot.stored_card)
				. += ai_slot
*/

/obj/item/modular_computer/proc/get_all_cards()
	. = list()
	for(var/obj/item/weapon/computer_hardware/card_slot/card_slot in all_hardware_containing_stored_items(HARDWARE_CARD_SLOT))
		. += card_slot.stored_card

/obj/item/modular_computer/proc/get_all_cards_broadcastable()
	. = list()
	for(var/obj/item/weapon/computer_hardware/card_slot/card_slot in all_hardware_containing_stored_items(HARDWARE_CARD_SLOT))
		if(card_slot.can_broadcast)
			. += card_slot.stored_card

/obj/item/modular_computer/proc/any_hardware_containing_stored_items(var/base_type_select)
	var/list/hardware_to_check = hardware_by_base_type[base_type_select]
	if(hardware_to_check != null)
		for(var/obj/item/weapon/computer_hardware/hardware_dev in hardware_to_check)
			if(LAZYLEN(hardware_dev.stored_items))
				return hardware_dev
	return null

/obj/item/modular_computer/proc/all_hardware_containing_stored_items(var/base_type_select)
	. = list()
	var/list/hardware_to_check = hardware_by_base_type[base_type_select]
	if(hardware_to_check != null)
		for(var/obj/item/weapon/computer_hardware/hardware_dev in hardware_to_check)
			if(LAZYLEN(hardware_dev.stored_items))
				. += hardware_dev

/obj/item/modular_computer/proc/any_hardware_empty_of_stored_items(var/base_type_select)
	var/list/hardware_to_check = hardware_by_base_type[base_type_select]
	if(hardware_to_check != null)
		for(var/obj/item/weapon/computer_hardware/hardware_dev in hardware_to_check)
			if(LAZYLEN(hardware_dev.stored_items) <= 0)
				return hardware_dev
	return null

/obj/item/modular_computer/proc/all_hardware_empty_of_stored_items(var/base_type_select)
	. = list()
	var/list/hardware_to_check = hardware_by_base_type[base_type_select]
	if(hardware_to_check != null)
		for(var/obj/item/weapon/computer_hardware/hardware_dev in hardware_to_check)
			if(LAZYLEN(hardware_dev.stored_items) <= 0)
				. += hardware_dev

/obj/item/modular_computer/proc/update_verbs()
	verbs.Cut()
	if(hardware_by_base_type[HARDWARE_AI_SLOT] != null)
		verbs |= /obj/item/modular_computer/verb/eject_ai
	if(ports_occupied[PORT_EXTERNAL] != null)
		verbs |= /obj/item/modular_computer/verb/eject_usb
	if(any_hardware_containing_stored_items(HARDWARE_CARD_SLOT))
		verbs |= /obj/item/modular_computer/verb/eject_id
	if(stores_pen && istype(stored_pen))
		verbs |= /obj/item/modular_computer/verb/remove_pen

	verbs |= /obj/item/modular_computer/verb/emergency_shutdown

// Forcibly shut down the device. To be used when something bugs out and the UI is nonfunctional.
/obj/item/modular_computer/verb/emergency_shutdown()
	set name = "Forced Shutdown"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated() || !istype(usr, /mob/living))
		to_chat(usr, "<span class='warning'>You can't do that.</span>")
		return

	if(!Adjacent(usr))
		to_chat(usr, "<span class='warning'>You can't reach it.</span>")
		return

	if(enabled)
		bsod = 1
		update_icon()
		to_chat(usr, "You press a hard-reset button on \the [src]. It displays a brief debug screen before shutting down.")
		if(updating)
			updating = FALSE
			updates = 0
			update_progress = 0
			if(prob(10))
				visible_message("<span class='warning'>[src] emits some ominous clicks.</span>")
				boot_device.take_damage(boot_device.damage_malfunction)
			else if(prob(5))
				visible_message("<span class='warning'>[src] emits some ominous clicks.</span>")
				boot_device.take_damage(boot_device.damage_failure)
		shutdown_computer(FALSE)
		spawn(2 SECONDS)
			bsod = 0
			update_icon()


// Eject ID card from computer, if it has ID slot with card inside.
/obj/item/modular_computer/verb/eject_id()
	set name = "Remove ID"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated() || !istype(usr, /mob/living))
		to_chat(usr, "<span class='warning'>You can't do that.</span>")
		return

	if(!Adjacent(usr))
		to_chat(usr, "<span class='warning'>You can't reach it.</span>")
		return

	handle_card_slot_interaction(null, usr, HARDWARE_CARD_SLOT, CARD_SLOT_NAME, CARD_SLOT_CARD)

// Eject ID card from computer, if it has ID slot with card inside.
/obj/item/modular_computer/verb/eject_usb()
	set name = "Eject Portable Storage"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated() || !istype(usr, /mob/living))
		to_chat(usr, "<span class='warning'>You can't do that.</span>")
		return

	if(!Adjacent(usr))
		to_chat(usr, "<span class='warning'>You can't reach it.</span>")
		return

	proc_eject_usb(usr)

/obj/item/modular_computer/verb/eject_ai()
	set name = "Eject AI"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated() || !istype(usr, /mob/living))
		to_chat(usr, "<span class='warning'>You can't do that.</span>")
		return

	if(!Adjacent(usr))
		to_chat(usr, "<span class='warning'>You can't reach it.</span>")
		return

	handle_card_slot_interaction(null, usr, HARDWARE_AI_SLOT, INTELLICARD_SLOT_NAME, INTELLICARD_SLOT_CARD)

/obj/item/modular_computer/verb/remove_pen()
	set name = "Remove Pen"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated() || !istype(usr, /mob/living))
		to_chat(usr, "<span class='warning'>You can't do that.</span>")
		return

	if(!Adjacent(usr))
		to_chat(usr, "<span class='warning'>You can't reach it.</span>")
		return

	if(istype(stored_pen))
		to_chat(usr, "<span class='notice'>You remove [stored_pen] from [src].</span>")
		usr.put_in_hands(stored_pen) // Silicons will drop it anyway.
		stored_pen = null
		update_verbs()

/obj/item/modular_computer/proc/select_hardware(var/mob/user, var/list/list_of_hardware, var/device_name, var/title_text, var/message_text)
	if(list_of_hardware == null || LAZYLEN(list_of_hardware) <= 0)
		to_chat(user, "There is no [device_name] connected to \the [src].")
	var/obj/hardware_selected
	if(list_of_hardware.len == 1)
		hardware_selected = list_of_hardware[1]
	else
		var/list/choices = list()
		for(var/i = 1 to LAZYLEN(list_of_hardware))
			choices["[i]: [list_of_hardware[i]]"] = list_of_hardware[i]
		
		var/input_response = input(user, "[message_text]", "[title_text]") as null|anything in choices
		
		if(!input_response)
			to_chat(user, "You change your mind.")
			return

		if(!Adjacent(user) || user.incapacitated())
			to_chat(user, "You need keep near \the [src].")
			return
		
		hardware_selected = choices[input_response]
		if(!hardware_to_hardware_gid[hardware_selected])
			to_chat(user, "You reach to \the [src] but \the [device_name] itself is missing!")
			return
	return hardware_selected

/obj/item/modular_computer/proc/proc_eject_usb(mob/user)
	if(!user)
		user = usr
	var/obj/selected_hardware = select_hardware(user, ports_occupied[PORT_EXTERNAL], "portable device", "Removing portable device", "Select a portable device to remove")
	if(selected_hardware)
		uninstall_component(user, selected_hardware)
		update_uis()

// Thanks for loaf for help figuring out a way to consolidate inserting cards and intellicards.
// And then there's me butchering that idea.
/obj/item/modular_computer/proc/handle_card_slot_interaction(var/obj/item/weapon/card, var/mob/user, var/slot_type, var/slot_name, var/card_name)
	if(hardware_by_base_type[slot_type] == null)
		to_chat(user, "You try to [card ? "insert" : "eject"] [card] into [src], but it does not have an [slot_name] installed.")
		return FALSE
	
	var/list/card_slots
	var/verb_text
	var/verbing_text
	var/title_text
	switch(istype(card))
		if(TRUE)
			verb_text = "insert"
			verbing_text = "inserting"
			title_text = "Inserting"
			card_slots = all_hardware_empty_of_stored_items(slot_type)

		if(FALSE)
			verb_text = "eject"
			verbing_text = "ejecting"
			title_text = "Ejecting"
			card_slots = all_hardware_containing_stored_items(slot_type)

	
	if(!LAZYLEN(card_slots) <= 0)
		if(card)
			to_chat(user, "You try to [verb_text] [card] into [src], but you can't find an unoccupied [slot_name].")
		else
			to_chat(user, "You try to [verb_text] a [card_name] from [src], but you can not find any.")
		return FALSE
	
	var/obj/item/weapon/computer_hardware/card_slot_selected
	if(LAZYLEN(card_slots) == 1)
		card_slot_selected = card_slots[1]
	else
		var/list/choices = list()
		for(var/i = 1 to LAZYLEN(card_slots))
			choices["[i]: [card_slots[i]]"] = card_slots[i]
		
		var/input_response = input(user, "Select a slot to [verb_text] [card_name].", "[title_text] [card_name]") as null|anything in choices
		
		if(!input_response)
			to_chat(user, "You change your mind about [verbing_text] \the [card] [card ? "into" : "from"] \the [src]")
			return FALSE

		if(!Adjacent(user) || user.incapacitated())
			to_chat(user, "You need keep near \the [src].")
			return FALSE
		
		card_slot_selected = choices[input_response]
		if(!hardware_to_hardware_gid[card_slot_selected])
			to_chat(user, "You reach to \the [src] but \the [slot_name] itself is missing!")
			return FALSE
	
	if(card)
		card_slot_selected.insert_item(user, card)
	else
		card_slot_selected.prompt_remove_stored_item(user)
	update_uis()
	update_verbs()

/obj/item/modular_computer/attack_ghost(var/mob/observer/ghost/user)
	if(enabled)
		ui_interact(user)
	else if(check_rights(R_ADMIN, 0, user))
		var/response = alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", "Yes", "No")
		if(response == "Yes")
			turn_on(user)

/obj/item/modular_computer/attack_ai(var/mob/user)
	return attack_self(user)

/obj/item/modular_computer/attack_hand(var/mob/user)
	if(anchored)
		return attack_self(user)
	return ..()

// On-click handling. Turns on the computer if it's off and opens the GUI.
/obj/item/modular_computer/attack_self(var/mob/user)
	if(enabled && screen_on)
		ui_interact(user)
	else if(!enabled && screen_on)
		turn_on(user)

/obj/item/modular_computer/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/card/id)) // ID Card, try to insert it.
		handle_card_slot_interaction(W, user, HARDWARE_CARD_SLOT, CARD_SLOT_NAME, CARD_SLOT_CARD)
		return
	
	if(istype(W, /obj/item/weapon/aicard))
		handle_card_slot_interaction(W, user, HARDWARE_AI_SLOT, INTELLICARD_SLOT_NAME, INTELLICARD_SLOT_CARD)
		return
	
	if(istype(W, /obj/item/weapon/pen) && stores_pen)
		if(istype(stored_pen))
			to_chat(user, "<span class='notice'>There is already a pen in [src].</span>")
			return
		if(!user.unEquip(W, src))
			return
		stored_pen = W
		update_verbs()
		to_chat(user, "<span class='notice'>You insert [W] into [src].</span>")
		return
	if(istype(W, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/paper = W
		if(paper.info)
			var/obj/item/weapon/computer_hardware/scanner/scanner = select_hardware(user, hardware_by_base_type[HARDWARE_SCANNER], "scanner", "Selecting scanner", "Select a scanner to scan [paper]")
			if(scanner)
				scanner.do_on_attackby(user, W)
				return
	if(istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/weapon/paper_bundle))
		var/obj/printer = select_hardware(user, hardware_by_base_type[HARDWARE_NANO_PRINTER], "printer", "Selecting printer", "Select a printer to recycle [W]")
		if(printer)
			printer.attackby(W, user)
			return

	if(!modifiable)
		return ..()

	if(istype(W, /obj/item/weapon/computer_hardware))
		try_install_component(user, W)
		
	if(isWrench(W))
		if(LAZYLEN(hardware_installed))
			to_chat(user, "Remove all components from \the [src] before disassembling it.")
			return
		new /obj/item/stack/material/steel( get_turf(src.loc), steel_sheet_cost )
		src.visible_message("\The [src] has been disassembled by [user].")
		qdel(src)
		return
	if(isWelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.isOn())
			to_chat(user, "\The [W] is off.")
			return

		if(!damage)
			to_chat(user, "\The [src] does not require repairs.")
			return

		to_chat(user, "You begin repairing damage to \the [src]...")
		if(WT.remove_fuel(round(damage/75)) && do_after(usr, damage/10))
			damage = 0
			to_chat(user, "You repair \the [src].")
		return

	if(isScrewdriver(W))
		var/list/selected_hardware = select_hardware(user, hardware_installed, "hardware", "Removing hardware", "Select hardware to remove.")
		if(!selected_hardware)
			to_chat(user, "This device doesn't have any components installed.")
			return
		uninstall_component(user, selected_hardware)
		return

	..()

/obj/item/modular_computer/examine(var/mob/user)
	. = ..()

	if(enabled && .)
		to_chat(user, "The time [stationtime2text()] is displayed in the corner of the screen.")

	for(var/obj/card in get_all_cards())
		to_chat(user, "\The [card] is inserted.")

/obj/item/modular_computer/MouseDrop(var/atom/over_object)
	var/mob/M = usr
	if(!istype(over_object, /obj/screen) && CanMouseDrop(M))
		return attack_self(M)

/obj/item/modular_computer/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(hardware_by_base_type[HARDWARE_SCANNER] != null)
		for(var/obj/item/weapon/computer_hardware/scanner/scanner in hardware_by_base_type[HARDWARE_SCANNER])
			scanner.do_on_afterattack(user, target, proximity)

obj/item/modular_computer/CtrlAltClick(mob/user)
	if(!CanPhysicallyInteract(user))
		return
	open_terminal(user)

#undef CARD_SLOT_NAME
#undef CARD_SLOT_CARD
#undef INTELLICARD_SLOT_NAME
#undef INTELLICARD_SLOT_CARD