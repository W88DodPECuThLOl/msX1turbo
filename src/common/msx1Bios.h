#ifndef INCL_msx1Bios__h
#define INCL_msx1Bios__h

#include "msx1BiosPsg.h"
#include "msx1BiosVdp.h"

 /**
  * @brief RDSLT (000CH/MAIN)
  * Aレジスタの値に対応するスロットを選択し、
  * そのスロットのメモリを1バイト読み出します。
  * このルーチンを呼ぶと、割り込みを禁止し、実行後も割り込みは解除されません。
  */
extern void RDSLT();

/**
  * @brief ENASLT (0024H/MAIN)
  * Aレジスタの値に対応するスロットを選択し、以降そのスロットを使用可能にします。
  * このルーチンを呼ぶと、割り込みを禁止し、実行後も割り込みは解除されません。
  */
extern void ENASLT();

 /**
  * @brief RSLREG (0138H/MAIN)
  * 基本スロット選択レジスタに出力している内容を読み出します。
  */
extern void RSLREG();

/**
 * @brief SNSMAT (0141H/MAIN)
 * 	キーボードマトリックスから指定した行の値を読み出します。
 */
extern void SNSMAT();

#endif // INCL_msx1Bios__h
