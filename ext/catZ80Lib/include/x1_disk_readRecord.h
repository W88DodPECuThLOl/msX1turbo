#ifndef INCL_x1_disk_readRecord__h
#define INCL_x1_disk_readRecord__h

#include "catBasicTypes.h"

/**
 * @brief 指定されたレコードを読み込む
 * @param[out] buffer   読み込み先
 * @param[in]  driveNo  ドライブ番号(0～3)
 * @param[in]  recordNo レコード番号(0～)
 * @return 処理結果(FDCのステータス)
 */
const u8 x1_diskReadRecord(u8* buffer, const u8 driveNo, const u32 recordNo);

#endif // INCL_x1_disk_readRecord__h
