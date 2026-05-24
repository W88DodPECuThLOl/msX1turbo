#ifndef INCL_x1_file_readFat__h
#define INCL_x1_file_readFat__h

#include "catBasicTypes.h"

/**
 * @brief FATを読み込む
 * @param[in] driveNo   ドライブ番号(0～3)
 * @return 処理結果
 * @retval FILE_SYSTEM_SUCCESS : 成功
 * @retval FILE_SYSTEM_ERROR_INVALID_DRIVE_NO : ドライブ番号が不正です
 * @retval FILE_SYSTEM_ERROR_DEVICE_OFFLINE : デバイスがオフラインでした
 * @retval FILE_SYSTEM_ERROR_READ : 読み込みに失敗しました
 */
u8 x1_fileReadFat(const u8 driveNo);

#endif // INCL_x1_file_readFat__h
