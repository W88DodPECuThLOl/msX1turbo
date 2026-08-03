; ・主にバンクメモリへアクセスする為のサブルーチンを配置する

    .z80
    .module ioHook
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /ioHook.inc/
.include /biosVdp.inc/

    .area _CODE

; コントロールレジスタに書き込むときのフラグ
VDP_ADDRESS_FETCH:
    .DB 0

;;
; @brief VDP書き込みのIN/OUT命令のフック処理
; 「RST 0x00」+1バイトの「機能番号」で呼び出す。
;
; 0x70 OUT (C),B
; 0x71 OUT (C),C
; 0x72 OUT (C),D
; 0x73 OUT (C),E
; 0x74 OUT (C),H
; 0x75 OUT (C),L
; 0x77 OUT (C),A
; 0x46 IN B,(C)
; 0x4E IN C,(C)
; 0x56 IN D,(C)
; 0x5E IN E,(C)
; 0x66 IN H,(C)
; 0x6E IN L,(C)
; 0x7E IN A,(C)
;;
_IN_OUT_HOOK:
    PUSH IX
        PUSH AF
            PUSH HL
                LD IX,#0x0006
                ADD IX,SP
                LD L,0(IX)
                LD H,1(IX)

                ; Cレジスタをチェック
                LD A,C
                CP #VDP_WR+1    ; コントロールレジスタへの書き込みチェック
                LD A,(HL)       ; function No.
                ; 戻り先を1個進めておく
                INC HL          ; フラグの変化なし
                LD 0(IX),L
                LD 1(IX),H
            POP HL
            JR Z,IN_OUT_HOOK_SET_WRITE_ADDRESS

            LD (IN_OUT_OPCODE + 1),A
        POP AF

        ; VDPの読み込みポインタを更新しておく
        LD IX,(VRAM_ACCESS_POINTER)
        INC IX
        LD (VRAM_ACCESS_POINTER),IX

.ifdef BANK_MEMORY_VRAM
        ; バンクメモリ0に切り替え
        DI
        PUSH BC
            LD BC,#0x0B00
            OUT (C),C
        POP BC
.endif

        ; IN/OUT命令
        ; 0x70 OUT (C),B => LD 0(IX),B
        ; 0x71 OUT (C),C => LD 0(IX),C
        ; 0x72 OUT (C),D => LD 0(IX),D
        ; 0x73 OUT (C),E => LD 0(IX),E
        ; 0x74 OUT (C),H => LD 0(IX),H
        ; 0x75 OUT (C),L => LD 0(IX),L
        ; 0x77 OUT (C),A => LD 0(IX),A
        ; 0x46 IN B,(C)  => LD B,0(IX)
        ; 0x4E IN C,(C)  => LD C,0(IX)
        ; 0x56 IN D,(C)  => LD D,0(IX)
        ; 0x5E IN E,(C)  => LD E,0(IX)
        ; 0x66 IN H,(C)  => LD H,0(IX)
        ; 0x6E IN L,(C)  => LD L,0(IX)
        ; 0x7E IN A,(C)  => LD A,0(IX)
IN_OUT_OPCODE:
        LD -1(IX),A   ; DD xx dd

.ifdef BANK_MEMORY_VRAM
        ; メインメモリに切り替え
        PUSH AF
        PUSH BC
            LD BC,#0x0B00
            LD A,#0x10
            OUT (C),A
        POP BC
        POP AF
        EI
.endif
    POP IX
    RET

; コントロールレジスタへの書き込み
IN_OUT_HOOK_SET_WRITE_ADDRESS:
            ; A : function No.
            ; 0x74 => OUT (C),H
            ; 0x75 => OUT (C),L
            CP #0x74
            JR Z,IN_OUT_HOOK_SET_WRITE_ADDRESS_H
            CP #0x75
            JR Z,IN_OUT_HOOK_SET_WRITE_ADDRESS_L
            JR IN_OUT_HOOK_SET_WRITE_ADDRESS_EXIT

IN_OUT_HOOK_SET_WRITE_ADDRESS_H:
            ; OUT (C),H
            LD A,(VDP_ADDRESS_FETCH)
            OR A
            JR NZ,IN_OUT_HOOK_SET_WRITE_ADDRESS_HIGH_H
IN_OUT_HOOK_SET_WRITE_ADDRESS_LOW_H:
            ; 下位アドレス
            LD A,H
            LD (VRAM_ACCESS_POINTER),A
            LD A,#1
            LD (VDP_ADDRESS_FETCH),A
            JR IN_OUT_HOOK_SET_WRITE_ADDRESS_EXIT
IN_OUT_HOOK_SET_WRITE_ADDRESS_HIGH_H:
            ; 上位アドレス
            LD A,H
            AND #0x3F
.ifdef VRAM_8000
            ADD #0x80 ; VRAM 0x8000
.else
            ADD #0x40 ; VRAM 0x4000
.endif
            LD (VRAM_ACCESS_POINTER+1),A
            XOR A
            LD (VDP_ADDRESS_FETCH),A
            JR IN_OUT_HOOK_SET_WRITE_ADDRESS_EXIT

IN_OUT_HOOK_SET_WRITE_ADDRESS_L:
            ; OUT (C),L
            LD A,(VDP_ADDRESS_FETCH)
            OR A
            JR NZ,IN_OUT_HOOK_SET_WRITE_ADDRESS_HIGH_L
IN_OUT_HOOK_SET_WRITE_ADDRESS_LOW_L:
            ; 下位アドレス
            LD A,L
            LD (VRAM_ACCESS_POINTER),A
            LD A,#1
            LD (VDP_ADDRESS_FETCH),A
            JR IN_OUT_HOOK_SET_WRITE_ADDRESS_EXIT
IN_OUT_HOOK_SET_WRITE_ADDRESS_HIGH_L:
            ; 上位アドレス
            LD A,L
            AND #0x3F
.ifdef VRAM_8000
            ADD #0x80 ; VRAM 0x8000
.else
            ADD #0x40 ; VRAM 0x4000
.endif
            LD (VRAM_ACCESS_POINTER+1),A
            XOR A
            LD (VDP_ADDRESS_FETCH),A
            ;JR IN_OUT_HOOK_SET_WRITE_ADDRESS_EXIT
IN_OUT_HOOK_SET_WRITE_ADDRESS_EXIT:
        POP AF
    POP IX
    RET

;;
; OUTI
;   DEC B
;   OUT (C),(HL)
;   INC HL
;;
_BLOCK_IN_OUT_HOOK:
    PUSH AF
    PUSH BC
        LD A,(HL)
        INC HL
.ifdef BANK_MEMORY_VRAM
        LD BC,#0x0B00
        DI
        OUT (C),C
.endif
        LD BC,(VRAM_ACCESS_POINTER)
        LD (BC),A
        INC BC
        LD (VRAM_ACCESS_POINTER),BC
.ifdef BANK_MEMORY_VRAM
        LD BC,#0x0B00
        LD A,#0x10
        OUT (C),A
        EI
.endif
    POP BC
    POP AF
    DEC B ; 忘れずに１つ減らしておく。フラグも変わる。
    RET
