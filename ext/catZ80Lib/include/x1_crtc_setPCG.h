#ifndef INCL_x1_crtc_setPCG__h
#define INCL_x1_crtc_setPCG__h

#include "catBasicTypes.h"

/**
 * @brief PCGを設定する
 * @param[in]   pcgDataAddress  PCGのデータ
 */
void x1_crtcSetPCG(const u8* pcgDataAddress);

/*
■PCGのデータ

1バイト         設定するキャラクタ数
               (キャラクタ数分繰り返し)
1バイト             設定するキャラクタコード
3x8=24バイト        キャラクタパターン(B,R,Gの並びで8ライン分)
*/

#endif // INCL_x1_crtc_setPCG__h
