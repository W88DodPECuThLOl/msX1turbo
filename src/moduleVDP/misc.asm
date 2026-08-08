;
; 0xC000-0xDFFF
;

; ・主にバンクメモリへアクセスする為のサブルーチンを配置する

    .z80
    .module misc
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /biosVdp.inc/
.include /misc.inc/

    .area _CODE

;;
; @brief GRAPHIC1モードかどうかを調べる
;
; @return       GRAPHIC1モードかどうか
; @retval       Z  : GRAPHIC1モード
; @retval       NZ : GRAPHIC2またはGRAPHIC3モード
; @note 変更レジスタ AF
;;
_IS_GRA1:
    LD A,(RG0SAV)
    AND #0x0E
    RET NZ
    LD A,(RG1SAV)
    AND #0x18
    RET

;;
; @brief パターンジェネレータテーブルのアドレスの上位８ビットを取得する
;
; @return       A : パターンジェネレータテーブルのアドレスの上位８ビット
; @note 変更レジスタ AF
;;
_GET_PATTERN_GENERATOR_TABLE_ADDRESS:
    CALL _IS_GRA1
    LD A,(RG4SAV)
    JR NZ,GET_PATTERN_GENERATOR_TABLE_ADDRESS_GRAPHIC2
; GRAPHIC1モード
GET_PATTERN_GENERATOR_TABLE_ADDRESS_GRAPHIC1:
    AND #0x3F
    RLCA
    RLCA
    RLCA
.ifdef VRAM_8000
    ADD #0x80
.else
    ADD #0x40
.endif
    RET
; GRAPHIC2,3モード
GET_PATTERN_GENERATOR_TABLE_ADDRESS_GRAPHIC2:
    AND #0x3C
    RLCA
    RLCA
    RLCA
.ifdef VRAM_8000
    ADD #0x80
.else
    ADD #0x40
.endif
    RET

;;
; グラフィックパレット(コンパチモード)の初期化
; @note 破壊レジスタ BC
;;
GRAPHICS_PALETTE_INIT:
    LD BC,#0x10AA
    OUT (C),C
    LD BC,#0x11CC
    OUT (C),C
    LD BC,#0x12F0
    OUT (C),C
    RET

;;
; グラフィックパレット(コンパチモード)をすべて黒にする
; @note 破壊レジスタ BC
;;
GRAPHICS_PALETTE_ALL_BLACK:
    LD BC,#0x1000
    OUT (C),C
    INC B
    OUT (C),C
    INC B
    OUT (C),C
    RET

;;
; @brief スプライトアトリビュートテーブルのアドレスを計算する
; @param[in]    A   VDP R#5の値
; @return       HL  スプライトアトリビュートテーブルのアドレス
; @return       A   上位8bitのアドレス
;;
calcSpriteAttributeTableAddress:
    ; HL : spriteAttributeTableAddress = VRAM + ((u16)vdp[5] << 7);
    LD L,#0x00
    SRL A
    RR L
.ifdef VRAM_8000
    ADD #0x80 ; VRAM 0x8000～0xBFFF
.else
    ADD #0x40 ; VRAM 0x4000～0x7FFF
.endif
    LD H,A
    RET

;;
; @brief スプライトパターンジェネレータテーブルのアドレスを計算する
; @param[in]    A   VDP R#6の値
; @return       HL  スプライトパターンジェネレータテーブルのアドレス
; @return       A   上位8bitのアドレス
;;
calcSpritePatternGeneratorTableAddress:
    ; HL : VRAM + ((u16)(vdp[6] & 0x1F) << 11)
    AND #0x1F
    ADD A
    ADD A
    ADD A
.ifdef VRAM_8000
    ADD	#0x80 ; VRAM 0x8000～0xBFFF
.else
    ADD	#0x40 ; VRAM 0x4000～0x7FFF
.endif
    LD L,#0x00
    LD H,A
    RET


; @param[in]    HL  パターンネームテーブルのアドレス
setPatternNameTable:
    SRL H
    SRL H
    LD B,H ; 書き込む値
    LD C,#0x02 ; VDPのレジスタ番号
    JP _WRTVDP

; @param[in]    HL  カラーテーブルのアドレス
setColorTable:
    SLA L
    RL H
    SLA L
    RL H
    LD B,H ; 書き込む値
    LD C,#0x03 ; VDPのレジスタ番号
    JP _WRTVDP

; @param[in]    HL  パターンジェネレータテーブルのアドレス
setPatternGeneratorTable:
    SRL H
    SRL H
    SRL H
    LD B,H
    LD C,#0x04 ; VDPのレジスタ番号
    JP _WRTVDP

; @param[in]    HL  スプライトアトリビュートテーブルのアドレス
setSpriteAttributeTable:
    .rept 7
    SRL H
    RR L
    .endm
    LD B,L
    LD C,#0x05 ; VDPのレジスタ番号
    JP _WRTVDP

; @param[in]    HL  スプライトジェネレータテーブルのアドレス
setSpriteGeneretorTable:
    SRL H
    SRL H
    SRL H
    LD B,H
    LD C,#0x06 ; VDPのレジスタ番号
    JP _WRTVDP
