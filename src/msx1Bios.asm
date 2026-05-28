    .z80
    .module msx1Bios
    .area _CODE
    .allow_undocumented

H_KEYI          .equ    0xFD9A ; HOOK H.KEYI
SYSTEM_STACK    .equ    0x1800 ; システム用のスタックアドレス


    .globl _INITIALIZE
    .globl _CTC_SETUP
    .globl _vdpRender
    .globl IRQ_ENABLE_FLAG

; MSX BIOS
    .globl _ENASLT
    .globl _GICINI
    .globl _WRTPSG
    .globl _RDPSG
    .globl _GTSTCK
    .globl _GTTRIG
    .globl _RSLREG
    .globl _SNSMAT

; ユーザー側のスタックポインタ保存用
SP_SAVE:
    .DW 0x0000

; ジョイスティックの状態
JOY_STICK0_STATS:
    .DB 0xFF
JOY_STICK1_STATS:
    .DB 0xFF

; サブCPUをリセットする
SUB_CPU_RESET:
    CALL SUB_CPU_WAIT_READY_WRITE
    LD BC,#0x1900
    LD A,#0xE4
    OUT (C),A
    CALL SUB_CPU_WAIT_READY_WRITE
    LD BC,#0x1900
    OUT (C),C
    RET

;書き込み可能になるまで待つ
SUB_CPU_WAIT_READY_WRITE:
    LD BC,#0x1A01
SUB_CPU_WAIT_READY_WRITE_LOOP:
    IN A,(C)
    BIT 6,A
    JR NZ,SUB_CPU_WAIT_READY_WRITE_LOOP
    RET

; CTCを設定する
_CTC_SETUP:
    XOR A
    LD (IRQ_ENABLE_FLAG),A

	; 割り込みの呼び出し先を設定
	LD A,I
	LD H,A
	LD L,#0x70+6
	LD BC,#INT
	LD (HL),C
	INC L
	LD (HL),B

	; CTCの設定
	LD BC,#0x1FA0
	LD A,#0x70
	OUT (C),A ; 割り込みベクタ設定

	; 0
	LD  HL,#0x1700 + 25
	OUT (C),H
	OUT (C),L
	INC C
	INC C
	INC C
	; 3
	LD  HL,#0xD700 + 167
	OUT (C),H
	OUT (C),L
    RET

; CTCをリセットする
CTC_RESET:
    LD A,#3
	LD BC,#0x1FA0
	OUT (C),A
	INC C
	OUT (C),A
	INC C
	OUT (C),A
	INC C
	OUT (C),A
    RET

; 初期化
_INITIALIZE:
    ; スタックを設定
    POP BC
    POP DE
    LD HL,#0xF300
    LD SP,HL
    PUSH DE ; 戻り先を設定
    PUSH BC
    ; 
    CALL SUB_CPU_RESET
    CALL CTC_RESET
    ; ワークエリア初期化
    LD HL,#0xF300
    LD (HL),#0xC9
    LD DE,#0xF301
    LD BC,#0x007F
    LDIR
    LD HL,#0xF380
    LD DE,#0xF381
    LD (HL),#0x00
    LD BC,#0x0C7D
    LDIR
    LD HL,#H_KEYI
    LD (HL),#0xC9
    LD DE,#H_KEYI+1
    LD BC,#0x024D
    LDIR
    XOR A
    LD (0xFCC1),A
    LD (0xFCC2),A
    LD (0xFCC3),A
    LD A,#0x80
    LD (0xFCC4),A
    ; SLTTBL(0xFCC5～0xFCC8)
    XOR A
    LD (0xFCC5),A
    LD (0xFCC6),A
    LD (0xFCC7),A
    LD A,#0xA0
    LD (0xFCC8),A
    RET

; 割り込み処理
INT:
    DI
    PUSH AF
        LD A,(IRQ_ENABLE_FLAG)
        OR A
        JP Z, INT_EXIT

        PUSH HL
            LD HL, #0
            ADD HL, SP
            LD (SP_SAVE), HL
            LD SP,#SYSTEM_STACK
            PUSH BC
            PUSH DE
            PUSH IX
            PUSH IY
            EX AF,AF'
            PUSH AF
            EXX
            PUSH BC
            PUSH DE
            PUSH HL
                ; 描画
                CALL _vdpRender

                ; CTC 再設定
            	LD  BC,#0x1FA0 + 3
            	LD  HL,#0xD700 + 167
                OUT (C),H
                OUT (C),L
            POP HL
            POP DE
            POP BC
            EXX
            POP AF
            EX AF,AF'
            POP IY
            POP IX
            POP DE
            POP BC
            LD HL, (SP_SAVE)
            LD SP, HL
        POP HL
    POP AF

    ; HOOK呼び出し
    LD (SP_SAVE),HL ; HL保存
    LD HL,#INT_HOOK
    PUSH HL         ; RETIでINI_HOOKアドレスへ飛ぶように
    LD HL,(SP_SAVE) ; HL復帰

    EI
    RETI

    ; IRQ 割り込み無効
INT_EXIT:
    POP AF
    EI
    RETI

INT_HOOK:
    DI
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
    PUSH IX
    PUSH IY
    EXX
    EX AF,AF'
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
        CALL #H_KEYI
        NOP
        NOP
    POP HL
    POP DE
    POP BC
    POP AF
    EX AF,AF'
    EXX
    POP IY
    POP IX
    POP HL
    POP DE
    POP BC
    POP AF
    EI
    RET

JOY_STICK_UPDATA:
    ; JOY STICK読み込み
    ; ジョイスティックを入力設定に
    PUSH AF
    PUSH BC
        ;LD A, I
        ;PUSH AF
            LD BC,#0x1C07
            ;DI
            OUT (C),C
            DEC B
            IN A,(C)
            AND #0x3F
            OUT (C),A
            ;
            LD BC,#0x1C0E
            OUT (C),C
            DEC B
            IN A,(C)
            LD (JOY_STICK0_STATS),A
            LD BC,#0x1C0F
            OUT (C),C
            DEC B
            IN A,(C)
            LD (JOY_STICK1_STATS),A
        ;POP AF
        ;JP PO,JOY_STICK_UPDATA_SKIP1
        ;EI
;JOY_STICK_UPDATA_SKIP1:
    POP BC
    POP AF
    RET

; ENASLT (0024H/MAIN)
; 	Aレジスタの値に対応するスロットを選択し、以降そのスロットを使用可能にします。このルーチンを呼ぶと、割り込みを禁止し、実行後も割り込みは解除されません。
_ENASLT:
    DI
    RET

; GICINI (0090H/MAIN)
; PSGを初期化し、PLAY文のための初期値を設定します。
; 変更レジスタ
; すべて
_GICINI:
    LD BC,#0x1C00
    LD A,#0x07
    DI
    OUT (C),A
    DEC B
    LD D,#0xF8
    OUT (C),D
    INC B
    INC A
GICINI_LOOP:
    OUT (C),A
    DEC B
    .DB 0xED,0x71 ; OUT (C),F
    INC B
    INC A
    CP #11
    JR NZ,GICINI_LOOP
    EI
    RET

; WRTPSG (0093H/MAIN)
; @param    A   PSGのレジスタ番号
; @param    E   書き込むデータ
_WRTPSG:
    CP A,#0x0F
    JR Z,WRTPSG_PORT_B
    PUSH BC
        LD BC,#0x1C00
        DI
        OUT	(C),A ; PSGレジスタ番号
        DEC B
        OUT	(C),E ; データ書き込み
        EI
    POP BC
    RET
WRTPSG_PORT_B:
    PUSH AF
    LD A,E
    LD (PSG_REG15),A
    POP AF
    RET

PSG_REG15:
    .DB 0xFF

; RDPSG (0096H/MAIN)
; @param    A   PSGのレジスタ番号
; @return   A   読み出した値
_RDPSG:
    CP A,#0x0E
    JR Z,RDPSG_PORT_A
RDPSG_SUB:
    PUSH BC
        LD BC,#0x1C00
        DI
        OUT	(C),A ; PSGレジスタ番号
        DEC B
        IN A,(C) ; データ読み込み
        EI
    POP BC
    RET
RDPSG_PORT_A:
    PUSH BC
        LD BC,#0x1C07
        DI
        OUT (C),C
        DEC B
        IN A,(C)
        AND #0x3F
        OUT (C),A
        EI
    POP BC
    PUSH HL
        LD HL,#PSG_REG15
        BIT 6,(HL)
        JR Z,RDPSG_JOYSTICK1
RDPSG_JOYSTICK2:
        BIT 5,(HL)
        LD A,#15
        JR Z,RDPSG_JOYSTICK
RDPSG_EXIT:
    POP HL
    LD A,#0xFF
    RET
RDPSG_JOYSTICK1:
        BIT 4,(HL)
        JR NZ,RDPSG_EXIT
        LD A,#14
RDPSG_JOYSTICK:
        CALL RDPSG_SUB
        ; 11BARLDU MSX
        ; -BA-RLDU X1
        LD H,A
        AND #0x0F
        LD L,A
        SRL H
        LD A,H
        AND #0x30
        OR #0xC0
        OR L
    POP HL
    RET

; GTSTCK (00D5H/MAIN)
_GTSTCK:
    OR A
    RET Z
    DI
    CALL JOY_STICK_UPDATA
    EI
    DEC A
    LD A,(JOY_STICK0_STATS)
    JR Z,GTSTCK_CHECK_JOY_STICK
    LD A,(JOY_STICK1_STATS)
GTSTCK_CHECK_JOY_STICK:
    AND #0x0F
    LD HL,#GTSTCK_TABLE
    ADD L
    LD L,A
    JR NC,GTSTCK_SKIP
    INC H
GTSTCK_SKIP:
    LD A,(HL)
    RET
GTSTCK_TABLE:
    .DB 0x00 ; 0000
    .DB 0x05 ; 0001 RIGHT&LEFT&DOWN
    .DB 0x01 ; 0010 RIGHT&LEFT&UP
    .DB 0x00 ; 0011 RIGHT&LEFT
    .DB 0x03 ; 0100 RIGHT&UP&DOWN
    .DB 0x04 ; 0101 RIGHT&DOWN
    .DB 0x02 ; 0110 RIGHT&UP
    .DB 0x03 ; 0111 RIGHT
    .DB 0x07 ; 1000 LEFT&UP&DOWN
    .DB 0x06 ; 1001 LEFT&DOWN
    .DB 0x08 ; 1010 LEFT&UP
    .DB 0x07 ; 1011 LEFT
    .DB 0x00 ; 1100 UP&DOWN
    .DB 0x05 ; 1101 DOWN
    .DB 0x01 ; 1110 UP
    .DB 0x00 ; 1111 

; GTTRIG (00D8H/MAIN)
; トリガボタンの状態を調べます。
; A 調べるトリガボタンの番号（0=スペースキー、1～2=トリガボタン）
;
; A	0		トリガボタンは押されていない
; FFH		トリガボタンは押されている
; 変更レジスタ
; AF
_GTTRIG:
    OR A
    RET Z
    DI
    CALL JOY_STICK_UPDATA
    EI
    DEC A
    LD A,(JOY_STICK0_STATS)
    JR Z,GTTRIG_CHECK_TRIGGER_BUTTON0
GTTRIG_CHECK_TRIGGER_BUTTON1:
    BIT 6,A
    JR Z,GTTRIG_ON
    JR GTTRIG_OFF
GTTRIG_CHECK_TRIGGER_BUTTON0:
    BIT 5,A
    JR  Z,GTTRIG_ON
GTTRIG_OFF:
    XOR A
    RET
GTTRIG_ON:
    LD  A,#0xFF
    RET

; RSLREG (0138H/MAIN)
; 基本スロット選択レジスタに出力している内容を読み出します。
_RSLREG:
    LD A,#0xF4 ; @todo
    RET

; SNSMAT (0141H/MAIN)
; キーボードマトリックスから指定した行の値を読み出します。
; A	指定する行
; 変更レジスタ
; AF、C
_SNSMAT:
    LD A,#0xFF
    RET
