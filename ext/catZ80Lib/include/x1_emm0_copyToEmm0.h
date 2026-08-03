#ifndef INCL_x1_emm0_copyToEmm0__h
#define INCL_x1_emm0_copyToEmm0__h

#include "catBasicTypes.h"

/**
 * @brief メモリからEMM0へコピーする
 * @param[in] emmAddress EMM0のアドレス
 * @param[in] src メモリアドレス
 * @param[in] size コピーするサイズ(バイト単位)
 */
void x1_copyToEmm0(u32 emmAddress, const u8* src, u16 size);

#endif // INCL_x1_emm0_copyToEmm0__h
