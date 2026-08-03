#ifndef INCL_x1_file_normalizeFileName__h
#define INCL_x1_file_normalizeFileName__h

#include "catBasicTypes.h"

/**
 * @brief ファイル名をノーマライズする
 * 
 * - ファイル名13文字と拡張子3文字の16文字にする。
 * 
 * - 足りない場合は空白文字で埋められる。
 * 
 * - ドライブ名は無視される。
 * 
 * - 例1）"B:TEST.BIN" => "TEST         BIN"
 * - 例2）"TEST"       => "TEST            "
 * - 例3）".BIN"       => "             BIN"
 * @param[out] normalizedFilename ノーマライズされたファイル名
 * @param[in] filename ファイル名
 * @return 処理結果
 * @retval FILE_SYSTEM_SUCCESS : 成功
 * @retval FILE_SYSTEM_ERROR_BAD_FILE_NAME : ファイル名が不正です。
 */
u8 x1_fileNormalizeFileName(char* normalizedFilename, const u8* filename);

#endif // INCL_x1_file_normalizeFileName__h
