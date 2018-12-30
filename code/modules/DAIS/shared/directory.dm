/** Computer file directories.
    Metadata is used to store files */
/datum/computer_file/directory
    filename = "NewDirectory"
    filetype = "DIR"
    size = 1
    /// Includes root directories for copy/move operations.
    var/all_size = 1
    /// Associative list for filename to file in the directory.
    var/list/filename_to_file
    var/list/files_total = 0 // Amount of files in this directory and all others below it.
    /// The remote pseudo directories if a networked directory. This updates these folder's all_size
    var/list/remote_dirs

/// Creates a new directory and populates the filename_to_file list.
/datum/computer_file/directory/New(list/md)
    . = ..()
    filename_to_file = list()
    remote_dirs = list()

/// Goes through the metadata--file list of the directory--and issues Destroy on each item before proceeding with normal Destroy.
/datum/computer_file/directory/Destroy()
    for(var/datum/computer_file/c_file in metadata)
        if(istype(c_file, /datum/computer_file/directory/root)) // This is a root directory. Don't delete it, instead dereference it's parent from this folder.
            c_file.parent_dir = null
        else
            c_file.Destroy()
    metadata = null
    filename_to_file = null
    . = ..()

/// Goes through the metadata and clones all files, converting special directories into normal ones.
/datum/computer_file/directory/clone()
    var/datum/computer_file/directory/temp = ..()
    if(istype(temp, /datum/computer_file/directory/root)) // Convert root directories back to normal.
        temp = temp as /datum/computer_file/directory
        temp.undeletable = 0
    
    var/list/old_metadata = temp.metadata.Copy()
    temp.metadata = list()
    do
        var/datum/computer_file/c_file = old_metadata.Cut(LAZYLEN(old_metadata),2) // Keep popping files from the top of the list.
        temp.do_add_file(c_file.clone())
    while(LAZYLEN(old_metadata))

    return temp

/** Adds a *fresh* file **with** checks. *See proc/do_add_file() also.*
    Returns /datum/computer_file, IO_STORAGE_FULL, IO_FILENAME_COLLISION, IO_OKAY */
/datum/computer_file/directory/proc/add_file(datum/computer_file/c_file, var/list/access_given)
    . = can_access_file(c_file, access_given)
    if(. == IO_OKAY)
        if(hard_drive.root_directory.size + c_file.size > hard_drive.size) // Will adding the file overfill the hard drive?
            return IO_STORAGE_FULL
        
        if(filename_to_file[c_file.filename]) // Do we have an existing file with that name?
            return IO_FILENAME_COLLISION
        
        do_add_file(c_file)


// Add a *fresh* file **without** checks.
/datum/computer_file/directory/proc/do_add_file(datum/computer_file/c_file)
    metadata += c_file
    file.hard_drive = hard_drive
    filename_to_file += list("[c_file.filename].[c_file.filetype]" = c_file)
    propagate_size_change(c_file.size)
    
    return IO_OKAY

/// Locates a file given a path. *See proc/locate_file_by_list_path() for returns.*
/datum/computer_file/directory/proc/locate_file_by_path(path, limit, var/list/access_given)
    var/list/list_path = list()
    if(path[1] == "/") // Path start with root directory?
        list_path += "/"
    list_path.Add(splittext(path, "/"))
    return locate_file_by_list_path(list_path, limit, access_given)

/** Locates a file given a list of file names to traverse through. Supports Unix traversal such as ../../file_here
    Returns /datum/computer_file, LIMIT_REACHED, IO_ERROR, + returns of *proc/can_access_file()* */
/datum/computer_file/directory/proc/locate_file_by_list_path(list/path, limit = 50, var/list/access_given)
    var/datum/computer_file/directory/cur_dir = src
    var/starting_number = 1
    if(path[1] == "/") // Start at root instead of current directory.
        do
            limit--
            if(!limit) // Prevent infinite loop.
                return LIMIT_REACHED
            cur_dir = cur_dir.hard_drive.root_directory
            var/datum/computer_file/directory/fs/root_fs = cur_dir
            if(!root_fs.parent_dir) // Is there a directory holding the root?
                continue // Nope. We're at root.
            cur_dir = root_fs.parent_dir
            // Otherwise, go deeper!
        while(TRUE)
        starting_number = 2
        if(LAZYLEN(path) < 2) // Nowhere else to go after navigating into root.
            return cur_dir

    for(var/i = starting_number to LAZYLEN(path))
        limit--
        
        if(!limit) // Expended the amount of traversals.
            return LIMIT_REACHED
        
        var/access_check = can_access_file(cur_dir, access_given)
        if(access_check != IO_OKAY)
            return access_check
        
        var/name = path[i]
        if(".") // Current directory.
            continue
        if("..") // Go down.
            if(!parent_dir) // No parent! Keep current directory.
                cur_dir = cur_dir.parent_dir
            continue
        else
            var/computer_file/c_file = cur_dir.filename_to_file[name]
            if(LAZYLEN(path) == i) // Last entry?
                access_check = can_access_file(c_file, access_given)
                if(access_check == IO_OKAY)
                    return c_file
                else
                    return access_check

            else // We still have names
                cur_dir = c_file
                if(!istype(cur_dir)) // Is file a directory?
                    return IO_ERROR // Not a directory. Give IO_ERROR.
    
    return cur_dir // Catches "." and ".." as the last entry.

/** Checks to see if a file can be accessed by the current user.
    Returns IO_OKAY, IO_ERROR, IO_PERMISSION*/
/datum/computer_file/directory/proc/can_access_file(datum/computer_file/c_file, var/list/access_given)
    if(hard_drive && !hard_drive.check_functionality())
        return IO_ERROR
    
    if(access_given && LAZYLEN(group_access) > 0) // File requires identification.
        if(!has_access(group_access, list(), access_given))
            return IO_PERMISSION
    
    return IO_OKAY


/// Remove a file by reference.
/datum/computer_file/directory/proc/delete_file(datum/computer_file/c_file, var/list/access_given)
    if(!c_file || !(locate(c_file) in metadata))
        return IO_MISSING
    
    return try_delete_file(c_file, access_given)

/// Deletes a file by filename inside the directory.
/datum/computer_file/directory/proc/delete_file_by_filename(filename, var/list/access_given)
    var/datum/computer_file/file_to_delete = filename_to_file[file_or_filename]
    if(!file_to_delete)
        return IO_MISSING
    
    return try_delete_file(file_to_delete, access_given)

/// Deletes a file by relative path. *See proc/locate_file_by_list_path() for returns.*
/datum/computer_file/directory/proc/delete_file_by_path(file_path, var/list/access_given)
    . = locate_file_by_path(file_path, access_given)
    if(typeof(., /datum/computer_file))
        return try_delete_file(., access_given)

/// Deletes a file by a list of file names to traverse through. *See proc/locate_file_by_list_path() for returns.*
/datum/computer_file/directory/proc/delete_file_by_list_path(list/path, var/list/access_given)
    . = locate_file_by_list_path(path, access_given)
    if(typeof(., /datum/computer_file))
        return try_delete_file(., access_given)

/** Check if a file can be deleted before doing it, and to handle folder deletions as well.
    Returns with results from *proc/can_access_file()* or a file that failed to delete if deleting a folder. */
/datum/computer_file/directory/proc/try_delete_file(datum/computer_file/c_file, var/list/access_given)
    if(c_file.undeletable)
        return IO_PERMISSION
    . = can_access_file(c_file, access_given)
    if(. == IO_OKAY)
        if(istype(c_file, /datum/computer_file/directory))
            var/datum/computer_file/directory/deleting_dir = c_file
            for(var/datum/computer_file/deleting_c_file in deleting_dir.metadata)
                . = deleting_dir.try_delete_file(deleting_c_file, access_given)
                if(. != IO_OKAY)
                    return deleting_c_file
        
        do_delete_file(c_file)

/// Deletes a file by reference, skipping all checks.
/datum/computer_file/directory/proc/do_delete_file(datum/computer_file/c_file)
    metadata -= c_file
    filename_to_file -= "[c_file.filename].[c_file.filetype]"
    propagate_size_change(c_file.size * -1)
    c_file.Destroy()

/// Copies a file from one directory to another.
/datum/computer_file/directory/proc/copy_file_to(datum/computer_file/c_file, datum/computer_file/directory/to_dir, var/list/access_given)
    var/access_check = can_access_file(c_file, access_given) // Can access the source file
    if(access_check != IO_OKAY)
        return access_check

    access_check = can_access_file(to_dir, access_given) // Can access the destination folder
    if(access_check != IO_OKAY)
        return access_check
    
    var/hard_drive_capacity = to_dir.hard_drive.size
    var/hard_drive_used = to_dir.hard_drive.root_directory.size

    if(istype(c_file, /datum/computer_file/directory)) // Is the file being moved a directory?
        var/datum/computer_file/directory/d_file = c_file
        if(hard_drive_used + d_file.all_size > hard_drive_capacity) // Check if the all_size, which includes root directories, will go over capacity.
            return IO_STORAGE_FULL
    else
        if(hard_drive_used + c_file.size > hard_drive_capacity) // Will adding the file overfill the hard drive?
            return IO_STORAGE_FULL
    
    if(to_dir.filename_to_file[c_file.filename]) // Do we have an existing file with that name on the destination?
        return IO_FILENAME_COLLISION
    
    var/copied_c_file = c_file.clone()
    do_add_file(copied_c_file)

/// Moves a file from one directory to another.
/datum/computer_file/directory/proc/move_file_to(datum/computer_file/c_file, datum/computer_file/directory/to_dir, var/list/access_given)
    . = copy_file_to(c_file, to_dir, access_given)
    if(. == IO_OKAY)
        do_delete_file(c_file)

/// Propagates the size change to directories.
/datum/computer_file/directory/proc/propagate_size_change(size_diff, passed_root = FALSE)
    all_size += size_diff
    if(!passed_root)
        size += size_diff
    // If we pass root, don't change the size of directories passed it.
    if(!passed_root && istype(src, /datum/computer_file/directory/root))
        passed_root = TRUE
    
    if(parent_dir)
        parent_dir.propagate_size_change(size_diff, passed_root)
    
    for(var/datum/computer_file/directory/remote/remote_dir in remote_dirs)
        remote_dir.propagate_size_change(size_diff, passed_root)
    
/// The root folder on hard drives.
/datum/computer_file/directory/root
    filename = "ROOT" // Also could be the hard drive label.
    filetype = "DIR"
    undeletable = 1 // Really bad idea otherwise.

/datum/computer_file/directory/root/proc/mount_to_dir(datum/computer_file/directory/to_dir, var/list/access_given)
    . = can_access_file(to_dir, access_given) // Can we mount to the folder?
    if(. == IO_OKAY)
        

/datum/computer_file/directory/root/proc/do_mount_to_dir(datum/computer_file/directory/to_dir)


/// Special folder that directs to a networked directory.
/datum/computer_file/directory/root/remote
    filename = "REMOTE" // Could also be the server name + folder name.
    filetype = "RDIR"
