    .z80
    .module vdp
    .area _CODE
    .allow_undocumented

    .globl _IN_OUT_HOOK
    .globl IRQ_ENABLE_FLAG

    ; VDPレジスタ
    .globl _vdp

    ; スプライトパターンジェネレータテーブル
    .globl _SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS

    ; VRAMアドレス
VRAM .equ 0x8000

; MSX BIOS
    .globl _WRTVDP
    .globl _RDVRM
    .globl _WRTVRM
    .globl _SETRD
    .globl _SETWRT
    .globl _FILVRM
    .globl _LDIRMV
    .globl _LDIRVM
    .globl _RDVDP
   
; VDPの割り込みが有効かどうかのフラグ
IRQ_ENABLE_FLAG:
    .DB 0

; スプライトパターンジェネレータテーブル
_SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS:
    .DW 0x0000

; 連続して読み書きするときのポインタ
VRAM_ACCESS_POINTER:
    .DW 0x0000

; WRTVDP (0047H/MAIN)
; C VDPのレジスタ番号（レジスタ番号は0～23、32～46）
; B 書き込む値
; 変更レジスタ
; AF,BC
_WRTVDP:
    PUSH AF
    PUSH HL
        RES	7,C

        LD A,#_vdp
        ADD A,C
        LD L,A
        LD H,#(_vdp >> 8)
        LD (HL),B

        ; 
        LD A,C
        DEC A
        JR Z,WRTVDP_R1
        CP #6-1
        JR Z,WRTVDP_R6
WRTVDP_EXIT:
    POP HL
    POP AF
    RET

    ; R#1への書き込み
WRTVDP_R1:
    BIT 5,B
    JR Z,IRQ_DISABLE
IRQ_ENABLE:
    LD A,#1
    LD (IRQ_ENABLE_FLAG),A
    JR WRTVDP_EXIT
IRQ_DISABLE:
    LD A,#0
    LD (IRQ_ENABLE_FLAG),A
    JR WRTVDP_EXIT

    ; R#6への書き込み
WRTVDP_R6:
    ; スプライトパターンジェネレータテーブル
    ; VRAM + ((u16)(vdp[6] & 0x3F) << 11)
    LD A,B
	AND A,#0x3F
	ADD A,A
	ADD A,A
	ADD A,A
.if VRAM == #0x8000
	ADD	A,#0x80 ; VRAM 0x8000～0xBFFF
.else
	ADD	A,#0x40 ; VRAM 0x4000～0x7FFF
.endif
    LD (_SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS+1),A
    JR WRTVDP_EXIT

; RDVRM (004AH/MAIN)
; VRAMの指定したアドレスの内容を読み出します。ただし、このルーチンはTMS9918(MSX1のVDP)に対するもので、VRAMのアドレスは下位14ビットのみが有効です。全ビットを使うときは、NRDVRM(0174H/MAIN)を使います。
; 	HL	VRAMのアドレス
_RDVRM:
    PUSH HL
.if VRAM == #0x8000
        RES 6,H ; VRAM 0x8000～0xBFFF
        SET 7,H
.else
        SET 6,H ; VRAM 0x4000～0x7FFF
        RES 7,H
.endif
        LD A,(HL)
    POP HL
    RET

; VRAMにデータを書き込みます。
; HL	書き込むVRAMのアドレス（0～FFFFH）
; A	書き込むデータ
; 変更レジスタ
; AF
_WRTVRM:
    PUSH HL
.if VRAM == #0x8000
        RES 6,H ; VRAM 0x8000～0xBFFF
        SET 7,H
.else
        SET 6,H ; VRAM 0x4000～0x7FFF
        RES 7,H
.endif
        LD (HL),A
    POP HL
    RET

; SETRD (0050H/MAIN)
; VDP オートインクリメントを用いた読込初期設定を行います。
; HL	VRAMアドレス
; 変更レジスタ
; AF
_SETRD:

; SETWRT (0053H/MAIN)
; VDPにVRAMアドレスをセットして、書き込める状態にします。使用目的はSETRDと同じです。ただし、このルーチンはTMS9918に対するもので、VRAMのアドレスは下位14ビットのみが有効です。全ビットを使うときは、NSTWRT(0171H/MAIN)を使います。
; memo) VDP オートインクリメントを用いた書込初期設定を行います。
; HL	VRAMアドレス
; 変更レジスタ
; AF
_SETWRT:
.if VRAM == #0x8000
    RES 6,H ; VRAM 0x8000～0xBFFF
    SET 7,H
.else
    SET 6,H ; VRAM 0x4000～0x7FFF
    RES 7,H
.endif
    LD (VRAM_ACCESS_POINTER),HL
    RET

; VDP書き込みのIN/OUT命令のフック処理
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
; 
_IN_OUT_HOOK:
;    0x4000 RST 0x00
;    0x4001 funcNo
;    SP-> 0x41  RETURN ADDRESS
;         0x40
;
;    SP-> IX
;         IX
;         HL
;         HL
;         AF
;         AF
;         41  RETURN ADDRESS
;         40
    PUSH IX
        PUSH HL
        PUSH AF
            LD IX,#0x0006
            ADD IX,SP
            LD L,0(IX)
            LD H,1(IX)
            LD A,(HL)   ; function No.
            LD (IN_OUT_OPCODE + 1),A
            ; 戻り先を1個進めておく
            INC HL
            LD 0(IX),L
            LD 1(IX),H
        POP AF
        POP HL
        ; IN/OUT命令
        LD IX,(VRAM_ACCESS_POINTER)
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
        LD 0(IX),A   ; DD xx dd
        INC IX
        LD (VRAM_ACCESS_POINTER),IX
    POP IX
    RET

; LDIRMV (0059H/MAIN)
; HL 書き込みを開始するVRAMアドレス
; BC 書き込む領域の長さ(バイト数)
; A  書き込む値
; 変更レジスタ
; AF,BC
_FILVRM:
    PUSH HL
    PUSH DE
.if VRAM == #0x8000
        RES 6,H ; VRAM 0x8000～0xBFFF
        SET 7,H
.else
        SET 6,H ; VRAM 0x4000～0x7FFF
        RES 7,H
.endif
        LD (HL),A

        DEC BC
        LD A,B
        OR C
        JP Z,FILVRM_EXIT

        LD D,H
        LD E,L
        INC DE
        LDIR
FILVRM_EXIT:
    POP DE
    POP HL
    RET

; LDIRMV (0059H/MAIN)
; VRAMからメモリへデータをブロック転送します。
; HL 転送元のVRAMアドレス(指定するVRAMアドレスは全ビットが有効)
; DE 転送先のRAMアドレス
; BC 転送する長さ(バイト数)
; 変更レジスタ
; すべて
_LDIRMV:
.if VRAM == #0x8000
    RES 6,H ; VRAM 0x8000～0xBFFF
    SET 7,H
.else
    SET 6,H ; VRAM 0x4000～0x7FFF
    RES 7,H
.endif
    LDIR
    RET

; LDIRVM (005CH/MAIN)
; メモリからVRAMへデータをブロック転送します。
;HL	転送元のRAMアドレス
;DE	転送先のVRAMアドレス(指定するVRAMアドレスは全ビットが有効)
;BC	転送する長さ(単位はバイト)
; 変更レジスタ
; すべて
_LDIRVM:
.if VRAM == #0x8000
    RES 6,D ; VRAM 0x8000～0xBFFF
    SET 7,D
.else
    SET 6,D ; VRAM 0x4000～0x7FFF
    RES 7,D
.endif
    LDIR
    RET

; RDVDP (013EH/MAIN)
; VDPのステータスレジスタを読み出します。このルーチンはTMS9918に対するものです。
_RDVDP:
    LD A,#0 ; @todo
    RET
