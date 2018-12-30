var/global/list/used_mount_points = list() // Global to prevent mount point collision

/// Computer hardware. Currently under the computer_device to prevent collision
/obj/item/weapon/computer_device
    /// Name of the hardware
    name = "Hardware device"
    /// Examine description of the hardware.
    desc = "You're not sure what kind of device it is, but something tells you you should be seeing this."
    /// Icon (set) to use.
    icon = 'icons/obj/modular_components.dmi'
    /// The port that the piece of hardware is compatible with.
    var/decl/computer_port/port = /decl/computer_port/expansion
    /// Host of this hardware.
    var/obj/host = null
    /// If can store items.
    var/can_store_items = FALSE
    /// Delete the contents on Destroy()
    var/eject_contents_on_destroy = TRUE
    /// Max items that can be stored in the hardware
    var/max_items = 0
    /// Items stored inside the device.
    var/list/stored_items
    /// Tool used to manual eject all contents of the hardware.
    var/obj/manual_eject_tool_type = /obj/item/weapon/screwdriver
    /// The amount of power the hardware consumes in watts.
    var/power_usage = 0
    /// Device turned on to function and consume power when inside a computer.
    var/power = OFF
    /// Hardware usage limitations
    var/hardware_usage = HARDWARE_ALL
    /// Mount location. Generated and managed by the host. Used for fluff, but also as a means for a computer to recognize a previous device.
    var/mount_point = null
    /// How much damage the device has sustained.
    var/damage = 0
    /// The maximum amount of damage it can take.
    var/max_damage = 100
    /// The minimum amount of damage for the device to be malfunctioning.
    var/min_malfunction_damage = 40
    /// The probability of failing when malfunctioning.
    var/malfunction_prob = 20

/// Standard Initialize. Creates lists.
/obj/item/weapon/computer_device/Initialize()
    . = ..()
    stored_items = list()

/// Show the device plug when examined.
/obj/item/weapon/computer_device/examine(mob/user, distance)
    . = ..()
    to_chat(user, "It has a [port.name_plug] to connect with.")

/obj/item/weapon/computer_device/proc/check_functionality()
    if(power == OFF)
        return FALSE
    
    if(damage >= min_malfunction_damage && prob(malfunction_prob))
        return FALSE
    
    return TRUE

/** Handle physical interaction, usually called through the host.
    Example being the host presented a paper that is then forwarded to the scanner */
/obj/item/weapon/computer_device/attackby(obj/item/weapon/W, mob/user)
    . = ..()
    if(can_store_items && istype(W, manual_eject_tool_type))
        if(LAZYLEN(stored_items) <= 0) // Nothing inside
            to_chat(user, "There is nothing inside \the [src] to manually eject.")
        else
            remove_stored_items(user, TRUE) // Drop everything onto the floor.
        return

/// Turns on the hardware.
/obj/item/weapon/computer_device/proc/turn_on(mob/user)
    if(power == ON) // Power already on.
        return
    power = ON
    on_turn_on()
    return

/// Special action after the device is turned on.
/obj/item/weapon/computer_device/proc/on_turn_on()
    return

/// Turns off the hardware.
/obj/item/weapon/computer_device/proc/turn_off()
    if(power == OFF) // Device already off
        return
    power = OFF
    on_turn_off()
    return

/// Special action after the device is turned off.
/obj/item/weapon/computer_device/proc/on_turn_off()
    return

/// Insert an item into the hardware.
/obj/item/weapon/computer_device/proc/insert_item(mob/user, obj/item, force)
    if(!force && LAZYLEN(stored_items) >= max_items)
        to_chat(user, "There is no more space in \the [src] to store \the [item].")
    else
        if(user.unEquip(item, src))
            stored_items += item
            _item_insertion(item)
    return

/// Sterilization to proc/on_item_insertion()
/obj/item/weapon/computer_device/proc/_item_insertion(item)
    if(istype(item, /list))
        on_item_insertion(item)
    else
        on_item_insertion(list(item))

/** Special action after items inserted.
    inserted_items is either an empty list or a list containing the inserted items. */
/obj/item/weapon/computer_device/proc/on_item_insertion(list/inserted_items)
    return

/// Ejects all stored items of the hardware. 
/obj/item/weapon/computer_device/proc/remove_stored_items(mob/user, drop_on_floor = FALSE)
    for(var/obj/item in stored_items)
        if(!drop_on_floor && user)
            user.put_in_hands(stored_items)
        else
            dropInto(loc)
    
    _item_removal(stored_items)
    stored_items = list()

/// Prompt for input for removing something inside the hardware.
/obj/item/weapon/computer_device/proc/prompt_remove_stored_item(mob/user)
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
/obj/item/weapon/computer_device/proc/_item_removal(item)
    if(istype(item, /list))
        on_item_removal(item)
    else
        on_item_removal(list(item))

/** Special action after items removed.
    removed_items is either an empty list or a list containing the removed items. */
/obj/item/weapon/computer_device/proc/on_item_removal(list/removed_items)
    return

/// Called by the removing host. Sets the hardware's host to null, but can be used to do special actions as well.
/obj/item/weapon/computer_device/proc/on_eject(obj/old_host)
    host = null
    return

/// Called by the installing host. Sets the hardware's host, but can be used to do special actions as well.
/obj/item/weapon/computer_device/proc/on_insert(obj/new_host)
    host = new_host
    return

/obj/item/weapon/computer_device/Destroy()
    if(eject_contents_on_destroy)
        remove_stored_items(null, TRUE)
    . = ..()