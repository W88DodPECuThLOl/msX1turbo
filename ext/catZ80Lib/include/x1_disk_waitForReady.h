#ifndef INCL_x1_disk_waitForReady__h
#define INCL_x1_disk_waitForReady__h

#include "catBasicTypes.h"

/**
 * @brief 完了を待つ
 * @param[in] timeOut タイムアウト設定
 * @return 処理結果(FDCのステータス)
 */
u8 x1_diskWaitForReady(u32 timeOut);

#endif // INCL_x1_disk_waitForReady__h
