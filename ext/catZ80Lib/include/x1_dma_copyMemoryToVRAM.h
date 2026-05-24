#ifndef INCL_dma__h
#define INCL_dma__h

#include "catBasicTypes.h"

/**
 * @brief DMAを使用してメモリからVRAMへコピーする
 * @param[in] sourceMemoryAddress       メモリのアドレス
 * @param[in] destinationVRAMAddress    VRAMのアドレス
 * @param[in] copySize                  コピーするサイズ(バイト単位)
 */
void x1_dmaCopyMemoryToVRAM(const u16 sourceMemoryAddress, const u16 destinationVRAMAddress, u16 copySize);

#endif // INCL_dma__h
