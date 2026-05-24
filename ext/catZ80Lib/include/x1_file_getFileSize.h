#ifndef INCL_x1_file_getFileSize__h
#define INCL_x1_file_getFileSize__h

#include "catBasicTypes.h"

/**
 * @brief ファイルサイズを取得する
 * @param[in]  filename ファイル名
 * @param[out] fileSize ファイルサイズ(バイト単位)
 * @return 処理結果
 * @retval FILE_SYSTEM_SUCCESS : 成功
 * @retval FILE_SYSTEM_ERROR_INVALID_DRIVE_NAME : ドライブ名が不正です
 * @retval FILE_SYSTEM_ERROR_BAD_FILE_NAME : ファイル名が不正です
 * @retval FILE_SYSTEM_ERROR_DEVICE_OFFLINE : デバイスがオフラインでした
 * @retval FILE_SYSTEM_ERROR_READ : 読み込みに失敗しました
 * @retval FILE_SYSTEM_ERROR_FILE_NOT_FOUND : ファイルが見つかりませんでした
 */
u8 x1_fileGetFileSize(const char* filename, u32* fileSize);

#endif // INCL_x1_file_getFileSize__h
