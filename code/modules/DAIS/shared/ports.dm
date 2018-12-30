/// DAIS Ports, or how each piece of hardware should interact.
/decl/computer_port
    /// Name of the port if looking at it's slot.
    var/name_slot = "unknown slot" 
    /// Name of the port if looking at it's plug.
    var/name_plug = "unknown plug"
    /// "Folder" where the device would be.
    var/mount_location = "dev"
    /** "Mount point" of the device as presented to the machine.
        This, along with mount_location, becomes something like /dev/unkn-KSJ8AK. */
    var/block_device = "unk"

/// Power port. Teslas and Batteries
/decl/computer_port/power
    name_slot = "power socket"
    name_plug = "power plug"
    block_device = "pwr"

/// CPU port.
/decl/computer_port/cpu
    name_slot = "CPU socket"
    name_plug = "CPU contacts"
    block_device = "cpu"

/// HDD port.
/decl/computer_port/hard_drive
    name_slot = "hard drive port"
    name_plug = "hard drive plug"
    mount_location = "mnt"
    block_device = "hdd"

/// Expansion port.
/decl/computer_port/expansion
    name_slot = "expansion slot"
    name_plug = "expansion contacts"
    block_device = "exp"

/// External ports. This isn't just limited to portable storage, but could be extended to network dongles or an external printer.
/decl/computer_port/external
    name_slot = "data serial bus port"
    name_plug = "data serial bus plug"
    block_device = "dsb"

/// External storage port variant for fluff.
/decl/computer_port/external/storage
    mount_location = "mnt"
