#ifndef INCL_ipsPatch__h
#define INCL_ipsPatch__h

#include <catZ80Lib.h>

/**
 * @brief IPS形式のパッチを適用する
 * @param[out] target           パッチの適応対象
 * @param[in]  ipsSource        パッチのソース
 * @param[in]  ipsSourceSize    パッチのサイズ(バイト単位)
 * @return 処理結果
 * @retval 0:正常にパッチが適応された
 * @retval 0以外:パッチ適応に失敗した
 */
u8 ipsPatch(u8* target, const u8* ipsSource, const u32 ipsSourceSize);

#endif // INCL_ipsPatch__h
