#ifndef INCL_z80_decode_LZE__h
#define INCL_z80_decode_LZE__h

#include "catBasicTypes.h"

/**
 * @brief LZE形式の圧縮データを展開する
 * @param[in]  encodedDataAddress   LZE形式の圧縮データ
 * @param[out] extractingAddress    展開先
 */
void z80_decodeLZE(const u8* encodedDataAddress, u8* extractingAddress);

#endif // INCL_z80_decode_LZE__h
