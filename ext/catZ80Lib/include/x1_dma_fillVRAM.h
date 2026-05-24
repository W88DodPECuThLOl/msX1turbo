#ifndef INCL_x1_dma_fillVRAM__h
#define INCL_x1_dma_fillVRAM__h

#include "catBasicTypes.h"

/**
 * @brief DMAを使用してVRAMを指定された値で設定する
 * @param[in] vramAddress   VRAMのアドレス
 * @param[in] fillSize      サイズ(バイト単位)
 * @param[in] fillValue     設定する値
 */
void x1_dmaFillVRAM(const u16 vramAddress, u16 fillSize, const u8 fillValue);

#endif // INCL_x1_dma_fillVRAM__h
