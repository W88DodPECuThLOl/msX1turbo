; MSX BIOS

;;
; @brief WRTVDP (0047H/MAIN)
; VDPのレジスタに値を書き込みます。
;
; @param[in]    C  VDPのレジスタ番号（レジスタ番号は0～23、32～46）
; @param[in]    B  書き込む値
; @note 変更レジスタ AF,BC
;;
    .globl _WRTVDP
    .globl WRTVDP_SUB

;;
; @brief RDVRM (004AH/MAIN)
; VRAMの指定したアドレスの内容を読み出します。
; ただし、このルーチンはTMS9918(MSX1のVDP)に対するもので、
; VRAMのアドレスは下位14ビットのみが有効です。
; 全ビットを使うときは、NRDVRM(0174H/MAIN)を使います。
;
; @param[in]    HL  VRAMのアドレス
; @return       A   読み出した値
; @note 変更レジスタ AF
;;
    .globl _RDVRM

;;
; @brief WRTVRM (004DH/MAIN)
; VRAMにデータを書き込みます。
; ただし、このルーチンはTMS9918に対するもので、
; VRAMのアドレスは下位14ビットのみが有効です。
; 全ビットを使うときは、NVRVRM(0177H/MAIN)を使います。
;
; @param[in]    HL  VRAMのアドレス
; @param[in]    A   書き込むデータ
; @note 変更レジスタ AF
;;
    .globl _WRTVRM

;;
; @brief FILVRM (0056H/MAIN)
; VRAMの指定領域を同一のデータで埋めます。
; ただし、このルーチンはTMS9918に対するもので、
; VRAMのアドレスは下位14ビットのみが有効です。
; 全ビットを使うときは、BIGFIL(016BH/MAIN)を使います。
;
; @param[in]    HL  書き込みを開始するVRAMアドレス
; @param[in]    BC  書き込む領域の長さ(バイト数)
; @param[in]    A   書き込む値
; @note 変更レジスタ AF,BC
;;
    .globl _FILVRM

;;
; @brief LDIRMV (0059H/MAIN)
; VRAMからメモリへデータをブロック転送します。
;
; @param[in]    HL  転送元のVRAMアドレス(指定するVRAMアドレスは全ビットが有効)
; @param[in]    DE  転送先のRAMアドレス
; @param[in]    BC  転送する長さ(バイト数)
; @note 変更レジスタ すべて
;;
    .globl _LDIRMV

;;
; @brief LDIRVM (005CH/MAIN)
; メモリからVRAMへデータをブロック転送します。
;
; @param[in]    HL  転送元のRAMアドレス
; @param[in]    DE	転送先のVRAMアドレス(指定するVRAMアドレスは全ビットが有効)
; @param[in]    BC	転送する長さ(単位はバイト)
; @note 変更レジスタ すべて
;;
    .globl _LDIRVM

;;
; @brief CLRSPR (0069H/MAIN)
; すべてのスプライトを次のように初期化します。
;  スプライトパターン	ヌル
;  スプライト番号	スプライト面番号
;  スプライトカラー	前景色
;  スプライトの垂直位置(SCREEN 0～3)	209
;  スプライトの垂直位置(SCREEN 4～12)	217
;
; @note 変更レジスタ すべて
;;
    .globl _CLRSPR

;;
; @brief INIT32 (006FH/MAIN)
; 画面をTEXT2モード（SCREEN 1、32×24）に初期化します。
; このルーチンはパレットを初期化しません。
; パレットの初期化が必要であれば、このルーチンを実行した後、INIPLT（0141H/SUB）を実行します。
; コール手順
;【T32NAM(F3BDH)】	パターンネームテーブルのアドレス
;【T32COL(F3BFH)】	カラーテーブルのアドレス
;【T32CGP(F3C1H)】	パターンジェネレータテーブルのアドレス
;【T32ATR(F3C3H)】	スプライトアトリビュートテーブルのアドレス
;【T32PAT(F3C5H)】	スプライトジェネレータテーブルのアドレス
;【LINL32(F3AFH)】	1行の幅（WIDTH文によって設定する値）
;
; @note 変更レジスタ    すべて
;;
    .globl _INIT32

;;
; @brief INIGRP (0072H/MAIN)
; 画面をGRAPHIC1モード（SCREEN 2）に初期化します。
; このルーチンはパレットを初期化しません。
; パレットの初期化が必要であれば、このルーチンを実行した後、
; INIPLT（0141H/SUB）を実行します。
; 
; @note 変更レジスタ すべて
;;
    .globl _INIGRP


;;
; 連続して読み書きするときのポインタ
;;
    .globl VRAM_ACCESS_POINTER

;;
; スプライトパターンジェネレータテーブルのアドレス
;;
    .globl _SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS
