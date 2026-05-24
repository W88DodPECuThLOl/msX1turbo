#ifndef INCL_x1_file_initialize__h
#define INCL_x1_file_initialize__h

#include "catBasicTypes.h"

/**
 * @brief ファイルシステムを初期化する
 * @param[in/out] fatBuffer         FAT用に使用するバッファ
 * @param[in/out] readWriteBuffer   読み書き用に使用するバッファ
 * @return 処理結果
 * @retval FILE_SYSTEM_SUCCESS : 成功
 * @retval FILE_SYSTEM_ERROR : エラー
 * @note fatBufferは2セクタ分、readWriteBufferは1セクタ分のバッファサイズが必要
 */
u8 x1_fileInitialize(u8* fatBuffer, u8* readWriteBuffer);

#endif // INCL_x1_file_initialize__h
