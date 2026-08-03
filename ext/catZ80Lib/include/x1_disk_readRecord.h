#ifndef INCL_x1_disk_readRecord__h
#define INCL_x1_disk_readRecord__h

#include "catBasicTypes.h"

#if 0
    // ディスクシステムの初期化
    // 一度だけ
    x1_diskInitialize();

    // レコード番号14(2DのFAT領域)読み込む
    u8 driveNo = 0;
    u16 recordNo = 14;
    u8 fat[DISK_SECTOR_SIZE];
    x1_diskReadRecord(fat, driveNo, recordNo);

    // レコード番号16(2Dのディレクトリエントリ)読み込む
    recordNo = 16;
    u8 dirEntry[DISK_SECTOR_SIZE];
    x1_diskReadRecord(dirEntry, driveNo, recordNo);

    // 操作が終わったらドライブのモーターを切る
    x1_diskMortorOff(driveNo);
#endif

/**
 * @brief 指定されたレコードを読み込む
 * @param[out] buffer   読み込み先
 * @param[in]  driveNo  ドライブ番号(0～3)
 * @param[in]  recordNo レコード番号(0～)
 * @return 処理結果(FDCのステータス)
 */
const u8 x1_diskReadRecord(u8* buffer, const u8 driveNo, const u32 recordNo);

#endif // INCL_x1_disk_readRecord__h
