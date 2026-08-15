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
VDP_ADDRESS_FETCH1:
    .DB 0xAA


;;
; @brief VDP書き込みのIN命令のフック処理
; 「RST 0x38」+1バイトの「機能番号」で呼び出す。
;
; 0x46 IN B,(C)
; 0x4E IN C,(C)
; 0x56 IN D,(C)
; 0x5E IN E,(C)
; 0x66 IN H,(C)
; 0x6E IN L,(C)
; 0x7E IN A,(C)
;;
IN_HOOK:
    EX (SP),HL
    LD A,(HL) ; function No.
    LD (IN_HOOK_OPCODE+1),A
    INC HL
    EX (SP),HL

    PUSH IX
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

IN_HOOK_OPCODE:
        LD A,-1(IX)   ; DD xx dd

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

;;
; @brief VDP書き込みのOUT命令のフック処理
; 「RST 0x00」+1バイトの「機能番号」で呼び出す。
;
; 0x70 OUT (C),B
; 0x71 OUT (C),C
; 0x72 OUT (C),D
; 0x73 OUT (C),E
; 0x74 OUT (C),H
; 0x75 OUT (C),L
; 0x77 OUT (C),A
;;
OUT_HOOK:
    LD (OUT_HOOK_SAVE_A+1),A   ; Aレジスタ保存

    EX (SP),HL
    ; Cレジスタをチェック
    LD A,C
    CP #VDP_WR+1 ; コントロールレジスタへの書き込み
    LD A,(HL) ; function No.
    INC HL
    EX (SP),HL
    JR Z,OUT_HOOK_SET_WRITE_ADDRESS

    ; VRAMへの書き込み
    LD (OUT_HOOK_OPCODE+1),A ; 「OUT (C),reg」の代替の「LD -1(IX),reg」
    PUSH IX
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

        LD A,(OUT_HOOK_SAVE_A+1)
OUT_HOOK_OPCODE:
        LD -1(IX),A   ; DD xx dd

.ifdef BANK_MEMORY_VRAM
        ; メインメモリに切り替え
        PUSH BC
            LD BC,#0x0B00
            LD A,#0x10
            OUT (C),A
        POP BC
        EI
.endif
    POP IX

OUT_HOOK_SET_WRITE_ADDRESS_EXIT:
OUT_HOOK_SAVE_A:
    LD A,#0x00
    RET

; コントロールレジスタへの書き込み
; A : function No.
OUT_HOOK_SET_WRITE_ADDRESS:
    ; A : function No.
    ; 0x77 => OUT (C),A
    ; 0x70 => OUT (C),B
    ; 0x71 => OUT (C),C
    ; 0x72 => OUT (C),D
    ; 0x73 => OUT (C),E
    ; 0x74 => OUT (C),H
    ; 0x75 => OUT (C),L
    CP #0x77
    JR Z,OUT_HOOK_SET_WRITE_ADDRESS_A
    CP #0x72
    JR Z,OUT_HOOK_SET_WRITE_ADDRESS_D
    CP #0x73
    JR Z,OUT_HOOK_SET_WRITE_ADDRESS_E
    CP #0x74
    JR Z,OUT_HOOK_SET_WRITE_ADDRESS_H
    CP #0x75
    JR Z,OUT_HOOK_SET_WRITE_ADDRESS_L
    DI
    HALT ; @todo
    JP OUT_HOOK_SET_WRITE_ADDRESS_EXIT

    .macro OUT_HOOK_SET_WRITE_ADDRESS reg ?rand
    ; OUT (C),reg
    LD A,reg
    CALL IN_OUT_HOOK_OUT_0x99_A
    JP OUT_HOOK_SET_WRITE_ADDRESS_EXIT
    .endm

OUT_HOOK_SET_WRITE_ADDRESS_A:
    OUT_HOOK_SET_WRITE_ADDRESS (OUT_HOOK_SAVE_A+1)
OUT_HOOK_SET_WRITE_ADDRESS_D:
    OUT_HOOK_SET_WRITE_ADDRESS D
OUT_HOOK_SET_WRITE_ADDRESS_E:
    OUT_HOOK_SET_WRITE_ADDRESS E
OUT_HOOK_SET_WRITE_ADDRESS_H:
    OUT_HOOK_SET_WRITE_ADDRESS H
OUT_HOOK_SET_WRITE_ADDRESS_L:
    OUT_HOOK_SET_WRITE_ADDRESS L

;;
; OUT (0x98),A
; VDP ポート#0
;;
IN_OUT_HOOK_OUT_0x98_A:
.ifdef BANK_MEMORY_VRAM
    PUSH AF
        LD A,I ; P/V 現在の割り込み許可フラグ
                ; PE : 許可
        JP PE,IFF2_ENABLE
    POP AF
    ; 割り込み禁止で呼び出された
IFF2_DISABLE:
    PUSH AF
    PUSH BC
        LD BC,#0x0B00
        OUT (C),C

        LD BC,(VRAM_ACCESS_POINTER)
        LD (BC),A
        INC BC
        LD (VRAM_ACCESS_POINTER),BC

        LD BC,#0x0B00
        LD A,#0x10
        OUT (C),A
    POP BC
    POP AF
    RET
    ; 割り込み許可で呼び出された
IFF2_ENABLE:
    POP AF
    DI
    PUSH AF
    PUSH BC
        LD BC,#0x0B00
        OUT (C),C

        LD BC,(VRAM_ACCESS_POINTER)
        LD (BC),A
        INC BC
        LD (VRAM_ACCESS_POINTER),BC

        LD BC,#0x0B00
        LD A,#0x10
        OUT (C),A
    POP BC
    POP AF
    EI
    RET
.else
    PUSH HL
        LD HL,(VRAM_ACCESS_POINTER)
        LD (HL),A
        INC HL
        LD (VRAM_ACCESS_POINTER),HL
    POP HL
    RET
.endif

;;
; OUT (0x99),A
; VDP ポート#1 コントロールレジスタへの書き込み
;
; 10...... ; レジスタ番号へ書き込み
; 00...... : READ
; 01...... : WRITE
;;
IN_OUT_HOOK_OUT_0x99_A: ; OUT (0x99),A
    PUSH HL
        LD HL,#VDP_ADDRESS_FETCH1
        RRC (HL) ; 15
    POP HL
    JR C,IN_OUT_HOOK_OUT_0x99_A_HIGH
IN_OUT_HOOK_OUT_0x99_A_LOW:    
    LD (VDP_ADDRESS_FETCH),A
    RET

; 読み書きアドレス設定
IN_OUT_HOOK_OUT_0x99_A_HIGH:
    BIT 7,A
    JR NZ,IN_OUT_HOOK_OUT_0x99_A_REG
    PUSH AF
        AND #0x3F
.ifdef VRAM_8000
        ADD #0x80 ; VRAM 0x8000
.else
        ADD #0x40 ; VRAM 0x4000
.endif
        LD (VRAM_ACCESS_POINTER+1),A
        LD A,(VDP_ADDRESS_FETCH)
        LD (VRAM_ACCESS_POINTER),A
    POP AF
    RET

; レジスタ番号へ書き込み
IN_OUT_HOOK_OUT_0x99_A_REG:
    PUSH AF
    PUSH BC
        AND #0x07
        LD C,A
        LD A,(VDP_ADDRESS_FETCH)
        LD B,A
        CALL WRTVDP_SUB
    POP BC
    POP AF
    RET


;;
; IN A,(0x99)
; VDP ポート#1 ステータスレジスタの読み込み
;;
IN_OUT_HOOK_IN_A_0x99: ; IN A,(0x99)
    PUSH HL
        LD HL,#STATFL
        LD A,(HL)
        RES 7,(HL)
    POP HL
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
