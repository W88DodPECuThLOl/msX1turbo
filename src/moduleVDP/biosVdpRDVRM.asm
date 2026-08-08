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
_RDVRM:
    PUSH HL
.ifdef VRAM_8000
        RES 6,H ; VRAM 0x8000～0xBFFF
        SET 7,H
.else
        SET 6,H ; VRAM 0x4000～0x7FFF
        RES 7,H
.endif
        DI
.ifdef BANK_MEMORY_VRAM
        PUSH BC
        ; バンクメモリ0
        LD BC,#0x0B00
        OUT (C),C
.endif

        LD A,(HL)

        ; VDPのポインタを更新しておく
        INC HL
        LD (VRAM_ACCESS_POINTER),HL

.ifdef BANK_MEMORY_VRAM
        ; メインメモリ
        LD L,#0x10
        OUT (C),L
        POP BC
.endif
        ; メモ）VDPのレジスタを設定するときに割り込みを無効にし、その後有効にしているので
        EI
    POP HL
    RET
