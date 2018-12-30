/// Functionally same as TRUE, but reads better in the context of device power.
#define ON TRUE
/// Functionally same as FALSE, but reads better in the context of device power.
#define OFF FALSE
/*
    HARDWARE_ BITFLAG
    1
*/
/// Program/Software not limited to anything
#define HARDWARE_ALL 0xFF
/// Program/Software limited to consoles
#define HARDWARE_CONSOLE 0x1
/// Program/Software limited to telescreens
#define HARDWARE_TELESCREEN 0x2
/// Program/Software limited to laptops
#define HARDWARE_LAPTOP 0x4
/// Program/Software limited to tablets
#define HARDWARE_TABLET 0x8
/// Program/Software limited to PDAs
#define HARDWARE_PDA 0x10

/// File permission all
#define PERMISSION_ALL 0xFF
/// File permissions read flag
#define PERMISSION_READ 0x1
/// File permissions write flag
#define PERMISSIONS_WRITE 0x2

/// Something was using a resource excessively.
#define LIMIT_REACHED 999
/// IO action was OK.
#define IO_OKAY 101
/// IO action could not find a file.
#define IO_MISSING 102
/// IO action encountered a generic error.
#define IO_ERROR 103
/// IO action not allowed.
#define IO_PERMISSION 104
/// IO action would have overfilled the hard drive.
#define IO_STORAGE_FULL 105
/// IO action would have caused a file name collision.
#define IO_FILENAME_COLLISION 106