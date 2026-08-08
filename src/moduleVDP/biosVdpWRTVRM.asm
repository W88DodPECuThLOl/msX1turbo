; ・主にバンクメモリへアクセスする為のサブルーチンを配置する

    .z80
    .module biosVdp
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /ioHook.inc/
.include /biosVdp.inc/
.include /misc.inc/

    .globl _vdpWriteHook

    .area _CODE

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
_WRTVRM:
    PUSH AF ; メモ）AFレジスタ変わっていない
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

        LD (HL),A

        ; VDPのポインタを更新しておく
        ; @todo 必要？
        ;INC HL
        ;LD (VRAM_ACCESS_POINTER),HL
.if 0
        ; 書き換えの監視
        PUSH BC
        PUSH DE
        PUSH IX
        PUSH IY
            CALL _vdpWriteHook
        POP IY
        POP IX
        POP DE
        POP BC
.endif

.ifdef BANK_MEMORY_VRAM
        ; メインメモリ
        LD L,#0x10
        OUT (C),L
        POP BC
.endif
        ; メモ）VDPのレジスタを設定するときに割り込みを無効にし、その後有効にしているので
        EI
    POP HL
    POP AF
    RET
