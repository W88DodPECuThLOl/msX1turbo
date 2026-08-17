; ・主にバンクメモリへアクセスする為のサブルーチンを配置する

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
; @brief LDIRVM (005CH/MAIN)
; メモリからVRAMへデータをブロック転送します。
;
; @param[in]    HL  転送元のRAMアドレス
; @param[in]    DE	転送先のVRAMアドレス(指定するVRAMアドレスは全ビットが有効)
; @param[in]    BC	転送する長さ(単位はバイト)
; @note 変更レジスタ すべて
;;
_LDIRVM:
    PUSH DE ; 転送先のVRAMアドレス
.ifdef VRAM_8000
        RES 6,D ; VRAM 0x8000～0xBFFF
        SET 7,D
.else
        SET 6,D ; VRAM 0x4000～0x7FFF
        RES 7,D
.endif


.ifdef BANK_MEMORY_VRAM
        LD A,H
        CP #0x80
        JR NC,LDIRVM_NOT_OVERLAP
; 転送元がバンクメモリと重なっている
LDIRVM_OVERLAP:
        EXX
            PUSH BC
            PUSH HL
            LD BC,#0x0B00 ; 10
            LD L,#0x010
        EXX
        DEC BC
        INC C
        LD A,B
        LD B,C
        LD C,A
        INC C
        DI
LDIRVM_OVERLAP_LOOP:
            LD A,(HL)
            INC HL

            ; バンクメモリ0に切り替え
            EXX
                OUT (C),C
            EXX

            LD (DE),A
            INC DE

            ; メインメモリに切り替え
            EXX
                OUT (C),L
            EXX
        DJNZ LDIRVM_OVERLAP_LOOP
        DEC C
        JP NZ,LDIRVM_OVERLAP_LOOP

        ; VDPのポインタを更新しておく
        LD (VRAM_ACCESS_POINTER),DE
        EI
        EXX
            POP HL
            POP BC
        EXX
        EX DE,HL
        JR LDIRVM_EXIT
; 転送元がバンクメモリと重なっていない
LDIRVM_NOT_OVERLAP:
        ; バンクメモリ0に切り替え
        PUSH BC
        LD BC,#0x0B00
        DI
        OUT (C),C
        POP BC

        LDIR

        ; メインメモリに切り替え
        LD B,#0x0B
        LD A,#0x10
        OUT (C),A

        ; VDPのポインタを更新しておく
        LD (VRAM_ACCESS_POINTER),DE
        EI
        EX DE,HL
.else
        ; メモ）VDPのレジスタを設定後、割り込みを許可しているので
        EI
        LDIR

        ; VDPのポインタを更新しておく
        DI
        LD (VRAM_ACCESS_POINTER),DE
        EI
        EX DE,HL
.endif
LDIRVM_EXIT:
    POP HL
    ; HL: 転送先のVRAMアドレス
    ; DE: 転送元のRAMアドレス + 転送する長さ(単位はバイト)
    RET
