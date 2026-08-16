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
_CLRSPR:
    ;-----------------------------------------------
    ; スプライトパターンをクリアする
    ;-----------------------------------------------

    ; アドレスを計算
    LD A,(RG6SAV)
    CALL calcSpritePatternGeneratorTableAddress
    LD E,L
    LD D,H
    INC DE
.ifdef BANK_MEMORY_VRAM
    ; バンクメモリ0
    LD BC,#0x0B00
    DI
    OUT (C),C
.endif
        LD BC,#0x0800-1
        LD (HL),#0
        LDIR
.ifdef BANK_MEMORY_VRAM
    ; メインメモリ
    LD BC,#0x0B00
    LD A,#0x10
    OUT (C),A
    EI
.endif

    ;-----------------------------------------------
    ; スプライトアトリビュートの初期化
    ;-----------------------------------------------
    ; アドレスを計算
    LD A,(RG5SAV)
    CALL calcSpriteAttributeTableAddress

    ; スプライトのサイズでスプライト面番号のステップを決める
    LD A,(RG1SAV)
    AND #0x02
    LD D,#4 ; 16x16の時
    JR NZ,CLRSPR_SKIP1
    LD D,#1 ; 8x8の時
CLRSPR_SKIP1:

.ifdef BANK_MEMORY_VRAM
    ; バンクメモリ0
    LD BC,#0x0B00
    DI
    OUT (C),C
.endif

    LD A,(FORCLR) ; 前景色
    LD C,A

    XOR A
    LD B,#32
CLRSPR_LOOP:
        LD (HL),#209    ; Y座標
        INC L
        ; X座標は設定しない
        INC L
        LD (HL),A       ; スプライト面番号
        INC L
        ADD D
        LD (HL),C       ; 色
        INC L
    DJNZ CLRSPR_LOOP

.ifdef BANK_MEMORY_VRAM
    ; メインメモリ
    LD BC,#0x0B00
    LD A,#0x10
    OUT (C),A
.endif

    ; メモ）VDPのレジスタを設定するときに割り込みを無効にし、その後有効にしているので
    EI
    RET
