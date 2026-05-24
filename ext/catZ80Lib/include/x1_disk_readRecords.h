#ifndef INCL_x1_disk_readRecords__h
#define INCL_x1_disk_readRecords__h

#include "catBasicTypes.h"

/**
 * @brief 指定された連続レコードを読み込む
 * @param[out] buffer           読み込み先
 * @param[in]  driveNo          ドライブ番号(0～3)
 * @param[in]  recordNo         レコード番号(0～)
 * @param[in]  readRecordCount  読み込むレコード数(1～)
 * @return 処理結果(FDCのステータス)
 */
const u8 x1_diskReadRecords(u8* buffer, const u8 driveNo, const u32 recordNo, const u8 readRecordCount);

#endif // INCL_x1_disk_readRecords__h
