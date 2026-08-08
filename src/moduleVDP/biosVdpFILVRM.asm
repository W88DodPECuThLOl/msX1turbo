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
_FILVRM:
    PUSH AF ; メモ）AFレジスタ変わっていない
    PUSH DE ; メモ）DEレジスタ変わっていない
    PUSH HL ; メモ）HLレジスタ変わっていない
.ifdef VRAM_8000
        RES 6,H ; VRAM 0x8000～0xBFFF
        SET 7,H
.else
        SET 6,H ; VRAM 0x4000～0x7FFF
        RES 7,H
.endif

.ifdef BANK_MEMORY_VRAM
        PUSH BC ; メモ）スタックがバンクメモリ範囲外にあること
            ; バンクメモリ0
            LD BC,#0x0B00
            DI
            OUT (C),C
        POP BC

        LD (HL),A
        ; @todo VDPのポインタ更新
        DEC BC
        LD A,B
        OR C
        JR Z,FILVRM_EXIT2
        LD D,H
        LD E,L
        INC DE
        LDIR
        ; VDPのポインタを更新しておく
        LD (VRAM_ACCESS_POINTER),HL

FILVRM_EXIT2:
        ; メインメモリ
        LD BC,#0x0B00
        LD A,#0x10
        OUT (C),A
        EI
.else
        LD (HL),A
        ; @todo VDPのポインタ更新
        DEC BC
        LD A,B
        OR C
        JR Z,FILVRM_EXIT
        EI
        LD D,H
        LD E,L
        INC DE
        LDIR

        ; VDPのポインタを更新しておく
        DI
        LD (VRAM_ACCESS_POINTER),HL
FILVRM_EXIT:
        ; メモ）VDPのレジスタを設定するときに割り込みを無効にし、その後有効にしているので
        EI
.endif
    POP HL
    POP DE
    POP AF
    RET
