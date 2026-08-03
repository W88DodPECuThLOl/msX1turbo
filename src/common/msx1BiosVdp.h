#ifndef INCL_msx1BiosVdp__h
#define INCL_msx1BiosVdp__h

/**
 * @brief WRTVDP (0047H/MAIN)
 * VDPのレジスタに値を書き込みます。
 */
extern void WRTVDP();

/**
 * @brief RDVRM (004AH/MAIN)
 * VRAMの指定したアドレスの内容を読み出します。
 * ただし、このルーチンはTMS9918(MSX1のVDP)に対するもので、
 * VRAMのアドレスは下位14ビットのみが有効です。
 * 全ビットを使うときは、NRDVRM(0174H/MAIN)を使います。
 */
extern void RDVRM();

/**
 * @brief WRTVRM (004DH/MAIN)
 * VRAMにデータを書き込みます。
 * ただし、このルーチンはTMS9918に対するもので、
 * VRAMのアドレスは下位14ビットのみが有効です。
 * 全ビットを使うときは、NVRVRM(0177H/MAIN)を使います。
 */
extern void WRTVRM();

/**
 * @brief SETRD (0050H/MAIN)
 * VDPにVRAMアドレスをセットして、読み出せる状態にします。
 * このルーチンはVDPのアドレスオートインクリメントの機能を使って、
 * 連続したVRAM領域からデータを読み出すときに使います。
 * このルーチンの実行後はポートから直接VRAMから読み出します。
 * したがって、RDVRMをループ中で使うより高速な読み出しができます。
 * ただし、このルーチンはTMS9918に対するもので、
 * VRAMのアドレスは下位14ビットのみが有効です。
 * 全ビットを使うときは、NSETRD(016EH/MAIN)を使います。
 */
extern void SETRD();

/**
 * @brief SETWRT (0053H/MAIN)
 * VDPにVRAMアドレスをセットして、書き込める状態にします。
 * 使用目的はSETRDと同じです。
 * ただし、このルーチンはTMS9918に対するもので、
 * VRAMのアドレスは下位14ビットのみが有効です。
 * 全ビットを使うときは、NSTWRT(0171H/MAIN)を使います。
 */
extern void SETWRT();

/**
 * @brief FILVRM (0056H/MAIN)
 * VRAMの指定領域を同一のデータで埋めます。
 * ただし、このルーチンはTMS9918に対するもので、
 * VRAMのアドレスは下位14ビットのみが有効です。
 * 全ビットを使うときは、BIGFIL(016BH/MAIN)を使います。
 */
extern void FILVRM();

/**
 * @brief LDIRMV (0059H/MAIN)
 * VRAMからメモリへデータをブロック転送します。
 */
extern void LDIRMV();

/**
 * @brief LDIRVM (005CH/MAIN)
 * メモリからVRAMへデータをブロック転送します。
 */
extern void LDIRVM();

/**
 * @brief CLRSPR (0069H/MAIN)
 * すべてのスプライトを次のように初期化します。
 * スプライトパターン	ヌル
 * スプライト番号	スプライト面番号
 * スプライトカラー	前景色
 * スプライトの垂直位置(SCREEN 0～3)	209
 * スプライトの垂直位置(SCREEN 4～12)	217
 */
extern void CLRSPR();

/**
 * @brief INIT32 (006FH/MAIN)
 * 画面をTEXT2モード（SCREEN 1、32×24）に初期化します。
 * このルーチンはパレットを初期化しません。
 * パレットの初期化が必要であれば、このルーチンを実行した後、
 * INIPLT（0141H/SUB）を実行します。
 */
extern void INIT32();

/**
 * @brief RDVDP (013EH/MAIN)
 * VDPのステータスレジスタを読み出します。
 * このルーチンはTMS9918に対するものです。
 */
extern void RDVDP();

#endif // INCL_msx1BiosVdp__h
