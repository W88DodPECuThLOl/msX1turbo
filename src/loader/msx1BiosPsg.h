#ifndef INCL_msx1BiosPsg__h
#define INCL_msx1BiosPsg__h

/**
 * @brief GICINI (0090H/MAIN)
 * PSGを初期化し、PLAY文のための初期値を設定します。
 */
extern void GICINI();

/**
 * @brief WRTPSG (0093H/MAIN)
 * PSG のレジスタにデータを書き込む
 */
extern void WRTPSG();

/**
 * @brief RDPSG (0096H/MAIN)
 * PSG のレジスタの値を読む
 */
extern void RDPSG();

/**
 * @brief GTSTCK (00D5H/MAIN)
 * ジョイスティックまたはカーソルキーの状態を調べます。
 */
extern void GTSTCK();

/**
 * @brief GTTRIG (00D8H/MAIN)
 * トリガボタンの状態を調べます。
 */
extern void GTTRIG();

#endif // INCL_msx1BiosPsg__h
