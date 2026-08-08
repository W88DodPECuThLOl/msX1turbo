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
; @brief LDIRMV (0059H/MAIN)
; VRAMからメモリへデータをブロック転送します。
;
; @param[in]    HL  転送元のVRAMアドレス(指定するVRAMアドレスは全ビットが有効)
; @param[in]    DE  転送先のRAMアドレス
; @param[in]    BC  転送する長さ(バイト数)
; @note 変更レジスタ すべて
;;
_LDIRMV:
    PUSH HL ; HLレジスタ変わっていない
.ifdef VRAM_8000
        RES 6,H ; VRAM 0x8000～0xBFFF
        SET 7,H
.else
        SET 6,H ; VRAM 0x4000～0x7FFF
        RES 7,H
.endif

.ifdef BANK_MEMORY_VRAM
        LD A,D
        CP #0x80
        JR NC,LDIRMV_NOT_OVERLAP
; 転送先がバンクメモリと重なっている
LDIRMV_OVERLAP:
        EX AF,AF'
            PUSH AF
            LD A,#0x10
        EX AF,AF'
LDIRMV_OVERLAP_LOOP:
            ; バンクメモリから読み込み
            PUSH BC
                ; バンクメモリへ切り替え
                LD BC,#0x0B00
                DI
                OUT (C),C

                ; バンクメモリから読み込む
                LD A,(HL)
                INC HL

                ; メインメモリへ切り替え
                EX AF,AF'
                    OUT (C),A ; A:0x10
                    EI
                EX AF,AF'
            POP BC
            ; 書き込み
            LD (DE),A
            INC DE
        DEC BC
        LD A,B
        OR C
        JR NZ,LDIRMV_OVERLAP_LOOP
        EX AF,AF'
            POP AF
        EX AF,AF'

        ; VDPのポインタを更新しておく
        DI
        LD (VRAM_ACCESS_POINTER),HL
        EI

        JR LDIRMV_EXIT

; 転送先がバンクメモリと重なっていない
LDIRMV_NOT_OVERLAP:
        PUSH BC
        LD BC,#0x0B00
        DI
        OUT (C),C
        POP BC

        LDIR

        ; VDPの読み込みポインタを更新しておく
        LD (VRAM_ACCESS_POINTER),HL

        LD BC,#0x0B00
        LD A,#0x10
        OUT (C),A
        EI
.else
        EI
        LDIR
        ; VDPの読み込みポインタを更新しておく
        DI
        LD (VRAM_ACCESS_POINTER),HL
        EI
.endif
LDIRMV_EXIT:
    POP HL
    ; A  : 0x00
    ; BC : 0x0000
    RET
