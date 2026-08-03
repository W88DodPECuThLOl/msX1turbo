#ifndef INCL_x1_disk_readRecords__h
#define INCL_x1_disk_readRecords__h

#include "catBasicTypes.h"

#if 0
    // ディスクシステムの初期化
    // 一度だけ
    x1_diskInitialize();

    // レコード番号14(2DDのFAT領域)読み込む
    u8 driveNo = 0;
    u16 recordNo = 14;
    u8 fat[DISK_SECTOR_SIZE*2];
    x1_diskReadRecords(fat, driveNo, recordNo, 2);

    // 操作が終わったらドライブのモーターを切る
    x1_diskMortorOff(driveNo);
#endif

/**
 * @brief 連続したレコードを読み込む
 * @param[out] buffer           読み込み先
 * @param[in]  driveNo          ドライブ番号(0～3)
 * @param[in]  recordNo         レコード番号(0～)
 * @param[in]  readRecordCount  読み込むレコード数(1～)
 * @return 処理結果(FDCのステータス)
 */
const u8 x1_diskReadRecords(u8* buffer, const u8 driveNo, const u32 recordNo, const u8 readRecordCount);

#endif // INCL_x1_disk_readRecords__h
