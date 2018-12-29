/obj/item/weapon/computer_hardware/
	name = "Hardware"
	desc = "Unknown Hardware."
	icon = 'icons/obj/modular_components.dmi'
	var/obj/item/modular_computer/holder2 = null
	var/power_usage = 0 			// If the hardware uses extra power, change this.
	var/enabled = 1					// If the hardware is turned off set this to 0.
	var/critical = 1				// Prevent disabling for important component, like the HDD.
	var/hardware_size = 1			// Limits which devices can contain this component. 1: Tablets/Laptops/Consoles, 2: Laptops/Consoles, 3: Consoles only
	var/damage = 0					// Current damage level
	var/max_damage = 100			// Maximal damage level.
	var/damage_malfunction = 20		// "Malfunction" threshold. When damage exceeds this value the hardware piece will semi-randomly fail and do !!FUN!! things
	var/damage_failure = 50			// "Failure" threshold. When damage exceeds this value the hardware piece will not work at all.
	var/malfunction_probability = 10// Chance of malfunction when the component is damaged
	var/usage_flags = PROGRAM_ALL
	var/decl/modular_computer_port/port_type = PORT_EXPANSION
	var/base_type = /obj/item/weapon/computer_hardware
	var/list/stored_items			// Items stored in this piece of hardware.
	var/max_items = 0				// Max items that could be stored.

/obj/item/weapon/computer_hardware/New(obj/L)
	w_class = hardware_size
	stored_items = list()
	if(istype(L, /obj/item/modular_computer))
		holder2 = L
		return

/obj/item/weapon/computer_hardware/Destroy()
	holder2 = null
	return ..()

/obj/item/weapon/computer_hardware/attackby(var/obj/item/W as obj, var/mob/living/user as mob)
	// Multitool. Runs diagnostics
	if(isMultitool(W))
		to_chat(user, "***** DIAGNOSTICS REPORT *****")
		diagnostics(user)
		to_chat(user, "******************************")
		return 1
	// Nanopaste. Repair all damage if present for a single unit.
	var/obj/item/stack/S = W
	if(istype(S, /obj/item/stack/nanopaste))
		if(!damage)
			to_chat(user, "\The [src] doesn't seem to require repairs.")
			return 1
		if(S.use(1))
			to_chat(user, "You apply a bit of \the [W] to \the [src]. It immediately repairs all damage.")
			damage = 0
		return 1
	// Cable coil. Works as repair method, but will probably require multiple applications and more cable.
	if(isCoil(S))
		if(!damage)
			to_chat(user, "\The [src] doesn't seem to require repairs.")
			return 1
		if(S.use(1))
			to_chat(user, "You patch up \the [src] with a bit of \the [W].")
			take_damage(-10)
		return 1
	return ..()


// Called on multitool click, prints diagnostic information to the user.
/obj/item/weapon/computer_hardware/proc/diagnostics(var/mob/user)
	to_chat(user, "Hardware Integrity Test... (Corruption: [damage]/[max_damage]) [damage > damage_failure ? "FAIL" : damage > damage_malfunction ? "WARN" : "PASS"]")

// Handles damage checks
/obj/item/weapon/computer_hardware/proc/check_functionality()
	// Turned off
	if(!enabled)
		return 0
	// Too damaged to work at all.
	if(damage >= damage_failure)
		return 0
	// Still working. Well, sometimes...
	if(damage >= damage_malfunction)
		if(prob(malfunction_probability))
			return 0
	// Good to go.
	return 1

/obj/item/weapon/computer_hardware/examine(var/mob/user)
	. = ..()
	if(damage > damage_failure)
		to_chat(user, "<span class='danger'>It seems to be severely damaged!</span>")
	else if(damage > damage_malfunction)
		to_chat(user, "<span class='notice'>It seems to be damaged!</span>")
	else if(damage)
		to_chat(user, "It seems to be slightly damaged.")

// Damages the component. Contains necessary checks. Negative damage "heals" the component.
/obj/item/weapon/computer_hardware/proc/take_damage(var/amount)
	damage += round(amount) 					// We want nice rounded numbers here.
	damage = between(0, damage, max_damage)		// Clamp the value.

/obj/item/weapon/computer_hardware/proc/eject(var/mob/user)
	before_eject()
	if(user)
		to_chat(user, "You remove \the [src] from \the [holder2].")
		user.put_in_hands(src)
	else
		dropInto(holder2.loc)
	on_eject()

/// Called by *proc/eject()*. Sets the hardware's host to null, but can be used to do special actions as well.
/obj/item/weapon/computer_device/proc/on_eject(obj/old_host)
	holder2 = null
	return

/obj/item/weapon/computer_hardware/proc/before_eject()
	return

/// Insert an item into the hardware.
/obj/item/weapon/computer_hardware/proc/insert_item(mob/user, obj/item, force)
	if(!force && LAZYLEN(stored_items) >= max_items)
		to_chat(user, "There is no more space in \the [src] to store \the [item].")
	else
		if(user.unEquip(item, src))
			stored_items += item
			_item_insertion(item)
			return TRUE
	return FALSE

/// Sterilization to proc/on_item_insertion()
/obj/item/weapon/computer_hardware/proc/_item_insertion(item)
	if(istype(item, /list))
		on_item_insertion(item)
	else
		on_item_insertion(list(item))

/** Special action after items inserted.
	inserted_items is either an empty list or a list containing the inserted items. */
/obj/item/weapon/computer_hardware/proc/on_item_insertion(list/inserted_items)
	return

/// Ejects all stored items of the hardware. 
/obj/item/weapon/computer_hardware/proc/remove_stored_items(mob/user, drop_on_floor = FALSE)
	for(var/obj/item in stored_items)
		if(!drop_on_floor && user)
			user.put_in_hands(stored_items)
		else
			dropInto(loc)
	
	_item_removal(stored_items)
	stored_items = list()

/// Prompt for input for removing something inside the hardware.
/obj/item/weapon/computer_hardware/proc/prompt_remove_stored_item(mob/user)
	var/selected_item
	if(LAZYLEN(stored_items) <= 0) // Nothing inside.
		to_chat(user, "There's nothing inside \the [src].")
		return

	else if(LAZYLEN(stored_items) == 1) // Only one item in the hardware, eject that.
		selected_item = stored_items[1] 

	else
		var/choices = list()
		for(var/i = 1 to LAZYLEN(stored_items))
			choices["[src], [i]: [contents[i]]"] = stored_items[i]
		
		selected_item = choices[input(user, "Select an item to remove from \the [src].", "Item removal") as null|anything in choices]

		if(!selected_item) // No item selected
			to_chat(user, "You change your mind about removing something in \the [src].")
		
		if(!(locate(selected_item) in stored_items)) // Is the item still there?
			to_chat(user, "You try to remove \the [selected_item] but it has been removed from \the [src]!")
		
		if(!Adjacent(user)) // User moved away
			to_chat(user, "You need to keep next to \the [src] to remove something from it.")
	
	stored_items -= selected_item
	user.put_in_hands(selected_item)
	to_chat(user, "You remove \the [selected_item] from \the [src]")
	_item_removal(selected_item)

/// Sterilization to proc/on_item_removal()
/obj/item/weapon/computer_hardware/proc/_item_removal(item)
	if(istype(item, /list))
		on_item_removal(item)
	else
		on_item_removal(list(item))

/** Special action after items removed.
	removed_items is either an empty list or a list containing the removed items. */
/obj/item/weapon/computer_hardware/proc/on_item_removal(list/removed_items)
	return

/// Called by the installing host. Sets the hardware's host, but can be used to do special actions as well.
/obj/item/weapon/computer_device/proc/on_insert(obj/new_host)
	holder2 = new_host
	return