#ifndef INCL_x1_emm0_copyFromEmm0__h
#define INCL_x1_emm0_copyFromEmm0__h

#include "catBasicTypes.h"

/**
 * @brief EMM0からメモリへコピーする
 * @param[in] dst メモリアドレス
 * @param[in] emmAddress EMM0のアドレス
 * @param[in] size コピーするサイズ(バイト単位)
 */
void x1_copyFromEmm0(u8* dst, u32 emmAddress, u16 size);

#endif // INCL_x1_emm0_copyFromEMM0__h
