    .z80
    .module biosVdp
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /ioHook.inc/
.include /biosVdp.inc/
.include /misc.inc/

    .area _CODE

; Neko Sys Work

; 連続して読み書きするときのポインタ
VRAM_ACCESS_POINTER:
.ifdef VRAM_8000
    .DW 0x8000
.else
    .DW 0x4000
.endif

; スプライトパターンジェネレータテーブル
_SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS:
.ifdef VRAM_8000
    .DW 0x8000
.else
    .DW 0x4000
.endif

;;
; @brief WRTVDP (0047H/MAIN)
; VDPのレジスタに値を書き込みます。
;
; @param[in]    C  VDPのレジスタ番号（レジスタ番号は0～23、32～46）
; @param[in]    B  書き込む値
; @note 変更レジスタ AF,BC
;;
_WRTVDP:
    DI
    CALL WRTVDP_SUB
    ; メモ）VDPのレジスタを設定するときに割り込みを無効にし、その後有効にしているので
    EI
    RET

WRTVDP_SUB:
    PUSH BC
    PUSH HL
        LD A,C
        AND #7      ; レジスタ番号を0～7までに
        ; MSX WORK(RG0SAV～RG7SAV)に書き込む値を保存
        LD C,A
        ADD #0xDF  ; #RG0SAV ; 0xF3DF
        LD L,A
        LD H,#0xF3 ; #(RG0SAV >> 8)
        LD (HL),B
        ;
        LD A,C
        DEC A
        JR Z,WRTVDP_R1
        CP #6-1
        JR Z,WRTVDP_R6
WRTVDP_EXIT:
    POP HL
    POP BC
    RET

    ; R#1への書き込み
WRTVDP_R1:
    BIT 6,B
    JR Z,WRTVDP_DISSCR
WRTVDP_ENASCR:
    CALL GRAPHICS_PALETTE_INIT
    ; プライオリティでテキストを表示してみる
    LD BC,#0x1300
    LD A,#0xFE
    OUT (C),A
    JR WRTVDP_EXIT
WRTVDP_DISSCR:
    CALL GRAPHICS_PALETTE_ALL_BLACK
    ; プライオリティでテキストを消してみる
    LD BC,#0x1300
    LD A,#0xFF
    OUT (C),A
    JR WRTVDP_EXIT

    ; R#6への書き込み
WRTVDP_R6:
    LD A,B
    CALL calcSpritePatternGeneratorTableAddress
    LD (_SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS+1),A
    JR WRTVDP_EXIT
