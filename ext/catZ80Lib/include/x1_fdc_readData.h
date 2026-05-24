#ifndef INCL_x1_fdc_readData__h
#define INCL_x1_fdc_readData__h

#include "catBasicTypes.h"

/**
 * @brief ディスクからデータを1セクター分読み込む
 * @param[out] data 読み込んだデータの格納先
 * @param[in] sectorNo セクター番号(1～)
 * @return fdcのステータス
 */
const u8 x1_fdcReadData(u8* data, const u8 sectorNo);

#endif // INCL_x1_fdc_readData__h
