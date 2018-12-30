var/global/file_uid = 0

/datum/computer_file/
	var/filename = "NewFile" 								// Placeholder. No spacebars
	var/filetype = "XXX" 									// File full names are [filename].[filetype] so like NewFile.XXX in this case
	var/size = 1											// File size in GQ. Integers only!
	var/obj/item/weapon/computer_hardware/hard_drive/holder	// Holder that contains this file.
	var/obj/item/weapon/computer_device/hard_drive/hard_drive
	var/datum/computer_file/directory/parent_dir
	var/unsendable = 0										// Whether the file may be sent to someone via NTNet transfer or other means.
	var/undeletable = 0										// Whether the file may be deleted. Setting to 1 prevents deletion/renaming/etc.
	var/uid													// UID of this file
	var/list/metadata										// Any metadata the file uses.
	var/papertype = /obj/item/paper
	var/list/group_access									// List of access required to access
	var/group_permissions = PERMISSION_ALL					// If the group can read/write


/datum/computer_file/New(var/list/md = null)
	..()
	uid = file_uid
	file_uid++
	if(islist(md))
		metadata = md.Copy()
	group_access = list()

/datum/computer_file/Destroy()
	. = ..()
	if(holder)
		holder.remove_file(src)
		// holder.holder is the computer that has drive installed. If we are Destroy()ing program that's currently running kill it.
		if(holder.holder2 && holder.holder2.active_program == src)
			holder.holder2.kill_program(1)
		holder = null
	if(parent_dir)
		parent_dir.do_delete_file(src)
		parent_dir = null
	
	hard_drive = null


// Returns independent copy of this file.
/datum/computer_file/proc/clone(var/rename = 0)
	var/datum/computer_file/temp = new type
	temp.unsendable = unsendable
	temp.undeletable = undeletable
	temp.size = size
	if(metadata)
		temp.metadata = metadata.Copy()
	if(rename)
		temp.filename = filename + "(Copy)"
	else
		temp.filename = filename
	temp.filetype = filetype
	temp.group_access = group_access
	temp.group_permissions = group_permissions
	return temp