#ifndef INCL_x1_file_getCurrentDriveNo__h
#define INCL_x1_file_getCurrentDriveNo__h

#include "catBasicTypes.h"

/**
 * @brief カレントドライブ番号を取得する。
 * @param[out] driveNo  ドライブ番号(0～3)
 * @return 処理結果
 * @retval FILE_SYSTEM_SUCCESS : 成功
 * @retval FILE_SYSTEM_ERROR_INVALID_DRIVE_NO : ドライブ番号が不正です
 */
u8 x1_fileGetCurrentDriveNo(u8* driveNo);

#endif // INCL_x1_file_getCurrentDriveNo__h
