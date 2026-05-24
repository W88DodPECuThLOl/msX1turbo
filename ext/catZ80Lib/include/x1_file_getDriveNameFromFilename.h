#ifndef INCL_x1_file_getDriveNameFromFilename__h
#define INCL_x1_file_getDriveNameFromFilename__h

#include "catBasicTypes.h"

/**
 * @brief ファイル名からドライブ名部分を取得する
 * @param[out] driveName    ドライブ名
 * @param[in] driveNameSize ドライブ名のバッファ文字列のサイズ(バイト単位)
 * @param[in] filename      ファイル名
 * @note ドライブ名に区切り文字の「:」は含まれない。
 * @return 処理結果
 * @retval FILE_SYSTEM_SUCCESS : 成功
 * @retval FILE_SYSTEM_ERROR   : エラー
 */
u8 x1_fileGetDriveNameFromFilename(char* driveName, const u8 driveNameSize, const char* filename);

#endif // INCL_x1_file_getDriveNameFromFilename__h
