    .z80
    .module biosVdp
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /ioHook.inc/
.include /biosVdp.inc/
.include /misc.inc/

    .area _CODE

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
_INIT32:
    ; パターンネームテーブルのアドレス
    LD HL,(T32NAM)
    LD (NAMBAS),HL
    CALL setPatternNameTable
    ; カラーテーブルのアドレス
    LD HL,(T32COL)
    CALL setColorTable
    ; パターンジェネレータテーブルのアドレス
    LD HL,(T32CGP)
    LD (CGPBAS),HL
    CALL setPatternGeneratorTable
    ; スプライトアトリビュートテーブルのアドレス
    LD HL,(T32ATR)
    LD (ATRBAS),HL
    CALL setSpriteAttributeTable
    ; スプライトジェネレータテーブルのアドレス
    LD HL,(T32PAT)
    LD (PATBAS),HL
    CALL setSpriteGeneretorTable
    ; 1行の幅（WIDTH文によって設定する値）
    LD A,(LINL32)
    LD (LINLEN),A
    ; カーソル位置
    LD A,#1
    LD (CSRY),A
    LD (CSRX),A
    ; スクリーンモード
    LD (SCRMOD),A
    ; モード設定
    LD A,(RG0SAV)
    AND #0x01
    LD B,A
    LD C,#0x00
    CALL _WRTVDP
    LD A,(RG1SAV)
    AND #0xE7
    LD B,A
    LD C,#0x01
    CALL _WRTVDP
    ; スプライトの初期化
    JP _CLRSPR
