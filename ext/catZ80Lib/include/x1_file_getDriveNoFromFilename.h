#ifndef INCL_x1_file_getDriveNoFromFilename__h
#define INCL_x1_file_getDriveNoFromFilename__h

#include "catBasicTypes.h"

/**
 * @brief ファイル名からドライブ番号を取得する
 * @param[out] driveNo          ドライブ番号(0～3)
 * @param[in]  defaultDriveNo   ドライブ名が省略されていたときのドライブ番号(0～3)
 * @param[in]  filename         ファイル名
 * @return 処理結果
 * @retval FILE_SYSTEM_SUCCESS : 成功
 * @retval FILE_SYSTEM_ERROR_INVALID_DRIVE_NAME : ドライブ名が不正です
 * @retval FILE_SYSTEM_ERROR_INVALID_DRIVE_NO : ドライブ番号が不正です
 */
u8 x1_fileGetDriveNoFromFilename(u8* driveNo, const u8 defaultDriveNo, const char* filename);

#endif // INCL_x1_file_getDriveNoFromFilename__h
