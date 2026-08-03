;
; 0xC000-0xDFFF
;

; ・主にバンクメモリへアクセスする為のサブルーチンを配置する

    .z80
    .module misc
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
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
