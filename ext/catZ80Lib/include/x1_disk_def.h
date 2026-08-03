#ifndef INCL_x1_disk_def__h
#define INCL_x1_disk_def__h

#include "catBasicTypes.h"

#define DISK_2D_SECTOR_SIZE       (0x100)
#define DISK_2DD_SECTOR_SIZE      (0x100)
#define DISK_2HD_SECTOR_SIZE      (0x100)

#define DISK_SECTOR_SIZE    DISK_2D_SECTOR_SIZE

/**
 * @brief ディスクシステムで使用するコンテキスト
 */
typedef struct X1_DISK_CONTEXT {
    /**
     * @brief カレントのドライブ(0-3)
     */
    u8 driveNo;
    /**
     * @brief サイド(0-1)
     */
    u8 side;
    /**
     * @brief トラック番号(0-)
     */
    u8 trackNo;
} X1_DISK_CONTEXT;

#endif // INCL_x1_disk_def__h
