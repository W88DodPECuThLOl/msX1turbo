#ifndef INCL_x1_fs_def__h
#define INCL_x1_fs_def__h

#include "catBasicTypes.h"

/**
 * @brief ファイル名の最大文字数
 */
#define FILE_SYSTEM_FILE_NAME_LENGTH (13)

/**
 * @brief ファイルの拡張子の最大文字数
 */
#define FILE_SYSTEM_FILE_EXTENTION_LENGTH (3)

/**
 * @brief ドライブタイプ
 */
typedef enum FileSystemDriveType {
    FILE_SYSTEM_DRIVE_TYPE_2D = 0,
    FILE_SYSTEM_DRIVE_TYPE_2DD = 1,
    FILE_SYSTEM_DRIVE_TYPE_2HD = 2
} FileSystemDriveType;

/**
 * @brief ドライブのコンテキスト
 */
typedef struct FileSystemDriveContext {
    /**
     * @brief ドライブタイプ
     */
    FileSystemDriveType driveType;
} FileSystemDriveContext;

/**
 * @brief ファイルシステム用のコンテキスト
 */
typedef struct FileSystemContext {
    /**
     * @brief 読み書き用のバッファ
     */
    u8* readWriteBuffer;

    /**
     * @brief FAT用のバッファ
     */
    u8* fatBuffer;

    /**
     * @brief カレントドライブ番号(0～3)
     * @note ファイル名でドライブ名を省略した場合に使用される
     */
    u8  currentDriveNo;

    /**
     * @brief ドライブ毎のコンテキスト
     */
    FileSystemDriveContext driveContext[4];
} FileSystemContext;

extern FileSystemContext gFileSystemContext;

#define FILE_SYSTEM_2D_FAT_RECORD_NO     (14)
#define FILE_SYSTEM_2D_FAT_RECORD_COUNT  (1)
#define FILE_SYSTEM_2DD_FAT_RECORD_NO    (14)
#define FILE_SYSTEM_2DD_FAT_RECORD_COUNT (2)
#define FILE_SYSTEM_2HD_FAT_RECORD_NO    (28)
#define FILE_SYSTEM_2HD_FAT_RECORD_COUNT (2)

/**
 * @brief FATの最大レコード数
 */
#define FILE_SYSTEM_MAX_FAT_RECORD_COUNT (2)

/**
 * @brief IBが配置してあるレコード番号
 */
#define FILE_SYSTEM_IB_RECORD_NO     (16)
/**
 * @brief IBの要素１個つのサイズ(バイト単位)
 */
#define FILE_SYSTEM_IB_SIZE          (0x20)

// エラーコード

/**
 * @brief 成功
 */
#define FILE_SYSTEM_SUCCESS  (0)

/**
 * @brief エラー無し
 */
#define FILE_SYSTEM_NO_ERROR (0)

/**
 * @brief エラー
 */
#define FILE_SYSTEM_ERROR (0x80 + 0)

/**
 * @brief ドライブ名が不正です。
 */
#define FILE_SYSTEM_ERROR_INVALID_DRIVE_NAME (0x80 + 10)
/**
 * @brief ドライブ番号が不正です。
 */
#define FILE_SYSTEM_ERROR_INVALID_DRIVE_NO   (0x80 + 11)
/**
 * @brief ファイル名が不正です。
 */
#define FILE_SYSTEM_ERROR_BAD_FILE_NAME      (0x80 + 12)
/**
 * @brief ファイルが見つかりませんでした。
 */
#define FILE_SYSTEM_ERROR_FILE_NOT_FOUND     (0x80 + 13)
/**
 * @brief デバイスがオフラインでした。
 */
#define FILE_SYSTEM_ERROR_DEVICE_OFFLINE     (0x80 + 14)
/**
 * @brief 読み込みに失敗しました。
 */
#define FILE_SYSTEM_ERROR_READ               (0x80 + 15)

inline u32
x1_fileGetInfomationBlockFileSize(const u8* infomationBlock)
{
    return (u16)infomationBlock[18] | ((u16)infomationBlock[19] << 8);
}

inline u32
x1_fileGetInfomationBlockStartCluster(const u8* infomationBlock)
{
    return (u32)infomationBlock[30] | ((u32)infomationBlock[31] << 8) | ((u32)infomationBlock[29] << 16);
}

#endif // INCL_x1_fs_def__h
