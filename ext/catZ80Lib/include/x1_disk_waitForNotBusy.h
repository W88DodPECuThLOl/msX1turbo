#ifndef INCL_x1_disk_waitForNotBusy__h
#define INCL_x1_disk_waitForNotBusy__h

#include "catBasicTypes.h"

/**
 * @brief 完了を待つ
 * @return 処理結果(FDCのステータス)
 */
u8 x1_diskWaitForNotBusy();

#endif // INCL_x1_disk_waitForNotBusy__h
