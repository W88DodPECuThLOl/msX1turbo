#ifndef INCL_x1_fdc_mortorOn__h
#define INCL_x1_fdc_mortorOn__h

#include "catBasicTypes.h"

/**
 * @brief ドライブのモーターの電源を入れる
 * @param[in] driveNo ドライブ番号(0～3)
 * @param[in] side ディスクのサイド(0～1)
 */
void x1_fdcMortorOn(const u8 driveNo, const u8 side);

#endif // INCL_x1_fdc_mortorOn__h
