    .z80
    .module boot
    .area BOOT (ABS)
    .org 0x0000

START               .equ 0x1000 ; スタートアドレス
STACK_POINTER       .equ 0xF300 ; スタックポインタのアドレス
INTERRUPT_VECTOR    .equ 0x02   ; 割り込みベクタ

TEMP_WORK           .equ 0xC000 ; 一時ワーク用に使用するメモリのアドレス

    ;
    .globl _writeBankMemory0Byte
    .globl _readBankMemory0Byte
    .globl _fillBankMemory0
    .globl _copyBankMemory0ToMain
    .globl _copyMainToBankMemory0

    .globl _copy8KiBFromEmm0

    .globl _copy8KiBFromEmm0ToMem6000
    .globl _copy8KiBFromEmm0ToMem8000
    .globl _copy8KiBFromEmm0ToMemA000

    .globl TEXT_ATTRIBUTE_CLEAR
    .globl TEXT_VRAM_CLEAR
    .globl GRAM_CLEAR
    .globl CRTC_WIDTH40
    .globl CRTC_WIDTH80
    .globl CTC_RESET
    .globl SUB_CPU_SEND
    .globl SUB_CPU_RECEIVE
    .globl SUB_CPU_WAIT_READY_FOR_SEND
    .globl SUB_CPU_WAIT_READY_FOR_RECEIVE

    .org 0x0000
    JP COLD_START
    .rept 0x200-3
        .DB 0xC9
    .endm

; INTERRUPT VECTOR TABLE
; 0x0200-0x02FF
    ;.org 0x0200
    .rept 0x100
    .DB 0x00
    .endm

    ;.org 0x0300
    JP CTC_RESET    ; 0x0300
    JP CRTC_WIDTH40 ; 0x0303
    JP CRTC_WIDTH80 ; 0x0306
    JP WRITE_OUTPUT ; 0x0309
    JP _x1_psgReset ; 0x030C
    ;
    JP _readBankMemory0Byte ; 0x030F
    JP _writeBankMemory0Byte ; 0x0312
    JP _copy8KiBFromEmm0ToMem6000 ; 0x0315
    JP _copy8KiBFromEmm0ToMem8000 ; 0x0318
    JP _copy8KiBFromEmm0ToMemA000 ; 0x031B
    JP _copy8KiBFromEmm0ToMem4000 ; 0x031E
    ;
    .DB 0xC9,0xC9,0xC9  ; 0x0321
    .DB 0xC9,0xC9,0xC9
    .DB 0xC9,0xC9,0xC9
    .DB 0xC9,0xC9,0xC9
    .DB 0xC9,0xC9,0xC9
    .DB 0xC9,0xC9,0xC9
    ;
_SUB_CPU_SEND::
    JP SUB_CPU_SEND
_SUB_CPU_RECEIVE::
    JP SUB_CPU_RECEIVE

;;
; テキストのアトリビュート(0x2000～0x27FF)をクリアする
; ・CGで白色に設定
; @note 破壊レジスタ AF,BC,DE,L
;;
TEXT_ATTRIBUTE_CLEAR:
    ; 0x2000～0x27FF
    LD L,#0x07 ; 白色、CG
    LD BC,#0x2000
TEXT_VRAM_CLEAR_SUB:
    LD DE,#0x0800
IO_FILL:
TEXT_ATTRIBUTE_LOOP:
        OUT (C),L
        INC BC
    DEC DE
    LD A,D
    OR E
    JR NZ,TEXT_ATTRIBUTE_LOOP
    RET

;;
; テキスト(0x3000～0x37FF)をスペース(0x20)でクリアする
; @note 破壊レジスタ AF,BC,DE,L
;;
TEXT_VRAM_CLEAR:
    ; 0x3000～0x37FF
    LD L,#0x20 ; スペース
    LD BC,#0x3000
    JR TEXT_VRAM_CLEAR_SUB

;;
; 同時アクセスモード
; @note X1turbo以降
; @note 破壊レジスタ AF,BC
;;
CONCURRENT_ACCESS_MODE:
    LD BC,#0x1A03
    LD A,#0x0B
    OUT (C),A   ; PC6セット
    DEC A
    OUT (C),A   ; PC6リセット
    RET

;;
; グラフィック(0x4000～0xFFFF)を0クリアする
; @note X1turbo以降
; @note 割り込み禁止状態で呼び出すこと
; @note 破壊レジスタ AF,BC,DE,HL
;;
GRAM_CLEAR:
    CALL CONCURRENT_ACCESS_MODE
    ; 0x0000～0x3FFF
    LD BC,#0x0000
    LD DE,#0x4000
    LD L,C
    CALL IO_FILL
    ; 同時アクセスモードを解除
    IN A,(C)
    RET

;;
; 80桁に設定する
; @note 破壊レジスタ AF,BC,HL
;;
CRTC_WIDTH80:
    LD HL,#WIDTH80_DATA
    JR CRTC_SETUP
;;
; 40桁に設定する
; @note 破壊レジスタ AF,BC,HL
;;
CRTC_WIDTH40:
    LD HL,#WIDTH40_DATA
CRTC_SETUP:
    LD BC,#0x1801
    LD A,(HL)
	INC HL
CRTC_SETUP_LOOP:
        ; 書き込むレジスタ設定
        DEC C
        INC B
        OUTI
        ; 値を書き込む
        INC C
        INC B
        OUTI
    DEC A
    JR NZ,CRTC_SETUP_LOOP
	; 0x1Ax3 8255
    LD BC,#0x1A03 + 0x100
    OUTI
	; 0x1FDx 画面管理
    LD BC,#0x1FD0 + 0x100
    OUTI
    RET

WIDTH40_DATA:
	; CRTCに設定する数
	.DB 12
	; R0 水平総文字数-1
	.DB	0, 55
	; R1 水平表示文字数
	.DB 1, 40
	; R2 水平同期位置-1
	.DB 2, 45
	; R3 同期パルス幅
	.DB 3, 52
	; R4 垂直総文字数-1
	.DB 4, 31
	; R5 総ラスタ調整
	.DB 5, 2
	; R6 垂直表示文字数
	.DB 6, 25
	; R7 垂直同期位置-1 
	.DB 7, 28
	; R8 インタレース、スキュー
	.DB 8, 0
	; R9 最大ラスタアドレス
	.DB 9, 7
	; R12 スタートアドレス上位
	.DB 12, 0
	; R12 スタートアドレス下位
	.DB 13, 0
	; 0x1Ax3 8255 PC6のセット 40桁モード
	.DB 0x0D
	; 0x1FDx 画面管理
	.DB 0x00 ; 低解像モニタ(200ライン)、25行

WIDTH80_DATA:
	; CRTCに設定する数
	.DB 12
	; R0 水平総文字数-1
	.DB	0, 111
	; R1 水平表示文字数
	.DB 1, 80
	; R2 水平同期位置-1
	.DB 2, 89
	; R3 同期パルス幅
	.DB 3, 56
	; R4 垂直総文字数-1
	.DB 4, 31
	; R5 総ラスタ調整
	.DB 5, 2
	; R6 垂直表示文字数
	.DB 6, 25
	; R7 垂直同期位置-1 
	.DB 7, 28
	; R8 インタレース、スキュー
	.DB 8, 0
	; R9 最大ラスタアドレス
	.DB 9, 7
	; R12 スタートアドレス上位
	.DB 12, 0
	; R12 スタートアドレス下位
	.DB 13, 0
	; 0x1Ax3 8255 PC6のリセット 80桁モード
	.DB 0x0C
	; 0x1FDx 画面管理
	.DB 0x00 ; 低解像モニタ(200ライン)、25行

;;
; グラフィックパレット(コンパチモード)の初期化
; @note 破壊レジスタ BC
;;
GRAPHICS_PALETTE_INIT:
    LD BC,#0x10AA
    OUT (C),C
    LD BC,#0x11CC
    OUT (C),C
    LD BC,#0x12F0
    OUT (C),C
    RET

;;
; プライオリティの初期化
; テキストがグラフィックよりも上に表示されるように設定
; @note 破壊レジスタ BC
;;
GRAPHICS_PRIORITY_INIT:
    LD BC,#0x1300
    OUT (C),C
    RET

;;
; ・Zモード指定をコンパチブルモードに設定
;
; @note 破壊レジスタ AF,BC,HL
;;
TURBO_Z_INIT:
    LD HL,#TURBO_Z_INIT_DATA
WRITE_OUTPUT:
    LD C,(HL)
	INC HL
    LD B,(HL)
    LD A,C
    OR B
    RET Z
	INC HL
    LD A,(HL)
	INC HL
    OUT (C),A
    JR WRITE_OUTPUT
TURBO_Z_INIT_DATA:
    .DB 0xB0,0x1F,0x00 ; Zモード指定
    .DB 0xC0,0x1F,0x00 ; Zプライオリティ指定
TURBO_Z_TEXT_PALETTE_DATA:
    .DB 0xB9,0x1F,0x03 ; 青のカラーコード
    .DB 0xBA,0x1F,0x0C ; 赤のカラーコード
    .DB 0xBB,0x1F,0x0F ; マゼンタのカラーコード
    .DB 0xBC,0x1F,0x30 ; 緑のカラーコード
    .DB 0xBD,0x1F,0x33 ; シアンのカラーコード
    .DB 0xBE,0x1F,0x3C ; 黄のカラーコード
    .DB 0xBF,0x1F,0x3F ; 白のカラーコード
    .DB 0x00,0x00 ; END MARKER

;;
; CTCをリセットする
;
; @note 破壊レジスタ AF,BC
;;
CTC_RESET:
    LD BC,#0x1FA0
    CALL CTC_RESET_SUB
    LD BC,#0x0704
    CALL CTC_RESET_SUB
    LD BC,#0x0A04
    ;JP CTC_RESET_SUB
CTC_RESET_SUB:
    LD A,#3
    OUT (C),A
    INC C
    OUT (C),A
    INC C
    OUT (C),A
    INC C
    OUT (C),A
    RET

;;
; サブCPUをリセットする
;
; @note 破壊レジスタ AF,BC
;;
SUB_CPU_RESET:
    LD A,#0xE4 ; キー入力割り込みベクタセットコマンド
    CALL SUB_CPU_SEND
    XOR A ; キー入力割り込みベクタ 0で０割り込み無効
    ;JP SUB_CPU_SEND

;;
; サブCPUに1バイトデータを送る
;
; @param[in]    A   送るデータ
; @note 破壊レジスタ BC
;;
SUB_CPU_SEND:
    ; サブCPUへデータを送信できるようになるまで待つ
    PUSH AF
        CALL SUB_CPU_WAIT_READY_FOR_SEND
    POP AF
    ; データを送信する
    LD BC,#0x1900
    OUT (C),A
    RET

;;
; サブCPUから1バイトデータを受信する
;
; @return   A   受信データ
; @note 破壊レジスタ BC
;;
SUB_CPU_RECEIVE:
    ; サブCPUからデータを受信できるようになるまで待つ
    CALL SUB_CPU_WAIT_READY_FOR_RECEIVE
    ; データを受信する
    LD BC,#0x1900
    IN A,(C)
    RET

;;
; サブCPUへデータを送信できるようになるまで待つ
;
; @note 破壊レジスタ AF
;;
SUB_CPU_WAIT_READY_FOR_SEND:
    LD A,#0x1A
    IN A,(0x01) ; 0x1A01
    AND #0x40
    JR NZ,SUB_CPU_WAIT_READY_FOR_SEND
    RET

;;
; サブCPUからデータを受信できるようになるまで待つ
;
; @note 破壊レジスタ AF
;;
SUB_CPU_WAIT_READY_FOR_RECEIVE:
    LD A,#0x1A
    IN A,(0x01) ; 0x1A01
    AND #0x20
    JR NZ,SUB_CPU_WAIT_READY_FOR_RECEIVE
    RET

_x1_psgReset:
    ld hl, #PSG_RESET_TABLE
_x1_psgReset_syb:
    ld b, #0x1C
    xor a
x1_psgReset_Loop:
        out (c),a ; 書き込むレジスタ番号を設定
        dec b
        LD e,(hl)
        inc hl
        out (C),e ; PSGへ値を書き込む
        inc b
    inc a
    cp #14
    jr nz, x1_psgReset_Loop
    ret
PSG_RESET_TABLE:
    .DB 0x55,0,0,0,0,0,0,0x3F,0,0,0,0x0B,0,0 ; 0～13のPCGのレジスタに書き込む値

_x1_dmaReset:
    ld bc, #0x1f80
    ld a, #0xc3
    out (c), a
    out (c), a
    out (c), a
    out (c), a
    out (c), a
    out (c), a
    ret

COLD_START:
; 割り込み関連の初期化
    DI
    IM 2
    LD A,#INTERRUPT_VECTOR
    LD I,A
; メモリ初期化
MAIN_MEMORY_CLEAR:
    ; 0x4000～0xFFFF
    LD HL,#0x4000
    LD DE,#0x4001
    LD BC,#0x8000 - 1
    LD (HL),L
    LDIR
HOT_START:
; スタック
    LD SP,#STACK_POINTER
; DMA初期化
    CALL _x1_dmaReset
; PSGのリセット
    CALL _x1_psgReset
; CTC初期化
    CALL CTC_RESET
; サブCPUのリセット
    CALL SUB_CPU_RESET
; テキストをクリアする
    CALL TEXT_VRAM_CLEAR
; テキストのアトリビュートをクリアする
    CALL TEXT_ATTRIBUTE_CLEAR
; 画面関連の初期化
    ; 低解像度40桁
    CALL CRTC_WIDTH40
    ; TurboZ関連
    CALL TURBO_Z_INIT
    ; グラフィックパレット初期化
    CALL GRAPHICS_PALETTE_INIT
    ; テキストがグラフィックよりも上になるようにプライオリティを設定
    CALL GRAPHICS_PRIORITY_INIT
    ; グラフィックをクリア
    CALL GRAM_CLEAR
;
    .DB 0xCD
    .DW START
    JR HOT_START

;;
; メモリバンク0に値を書き込む
; @param HL アドレス 0x0000～0x7FFFまで
; @param A 書き込む値
;;
_writeBankMemory0Byte:
    PUSH AF
    PUSH BC
        ; バンクメモリ0に切り替え
        LD BC,#0x0B00
        OUT (C),C
            LD (HL),A
        ; メインメモリに切り替え
        LD A,#0x10
        OUT (C),A
    POP BC
    POP AF
    RET

;;
; メモリバンク0の値を読む
; @param HL アドレス 0x0000～0x7FFFまで
; @return A 読み込んだ値
;;
_readBankMemory0Byte:
    PUSH BC
    PUSH DE
        ; バンクメモリ0に切り替え
        LD BC,#0x0B00
        OUT (C),C
            LD A,(HL)
        ; メインメモリに切り替え
        LD E,#0x10
        OUT (C),E
    POP DE
    POP BC
    RET

;;
; メモリバンク0のメモリをセットする
; @param A  セットする値
; @param HL セットするアドレス
; @param BC サイズ(バイト単位)
;;
_fillBankMemory0:
    PUSH DE
    PUSH HL
    PUSH AF
        LD E,C
        LD D,B
        ; バンクメモリ0に切り替え
        LD BC,#0x0B00
        OUT (C),C
            LD (HL),A
            DEC DE
            LD A,E
            OR D
            JR Z,fillBankMemory0_EXIT
            LD C,E
            LD B,D
            LD D,H
            LD E,L
            INC DE
            LDIR
fillBankMemory0_EXIT:
        ; メインメモリに切り替え
        LD BC,#0x0B00
        LD A,#0x10
        OUT (C),A
    POP AF
    POP HL
    POP DE
    RET

;HL	転送元のVRAMアドレス(指定するVRAMアドレスは全ビットが有効)
;DE	転送先のRAMアドレス
;BC	転送する長さ(バイト数)
_copyBankMemory0ToMain:
    PUSH DE
    LD E,C
    LD D,B
    LD BC,#0x0B00
    EXX
        POP HL
        LD BC,#0x0B00
        LD E,#0x10
    EXX
copyBankMemory0ToMain_LOOP:
        ; バンクメモリ0に切り替え
        .DB 0xED,0x71 ; OUT (C),F
        ; 読み込んで
        LD A,(HL)
        INC HL
        EXX
            ; メインメモリに切り替え
            OUT (C),E ; E: 0x10
            ; 書き込む
            LD (HL),A
            INC HL
        EXX
    DEC DE
    LD A,D
    OR E
    JR NZ,copyBankMemory0ToMain_LOOP
    RET

dmaCommand_EMM0toMem:
    .DB 0xC3
    .DB 0xC3
    .DB 0xC3
;    .DB 0xC3
;    .DB 0xC3
;    .DB 0xC3

    .DB 0x7D        ; 01111101　WR0
                    ;       転送 A=>B
    .DW 0x0D03      ; PORT A アドレス EMM0
    .DW 0x2000-1    ; 転送バイト数-1
    .DB 0x2C        ; 0010 1100　WR1
                    ; PORT A固定
                    ; IO
    .DB 0x10        ; 0001 0000 WR2
                    ; アドレス可変
                    ; インクリメント
                    ; MEM
    .DB 0xCD        ; 1100 1101 WR4
                    ; バースト
dmaCommand_EMM0toMem_Address:
    .DW 0x8000      ; ポートBアドレス
    .DB 0x9A        ; 1001 1010 WR5
    .DB 0xCF
    .DB 0x87

; A : n
;R0 0x00000-0x1FFF
;R1 0x02000-0x3FFF
;R2 0x04000-0x5FFF
;R3 0x06000-0x7FFF
;
;Rn 0x02000*n - 

; @param A  ページ番号
; @param HL 転送先のアドレス
; 破壊
; HL
_copy8KiBFromEmm0:
.if 0
    PUSH AF
    PUSH BC
    PUSH DE
        ; アドレス設定
        LD BC,#0x0D00 ; EMM0
        LD E,C
        ADD A
        .rept 4
            RLA
            RL E
        .endm
        OUT (C),C ; LOW
        INC C
        OUT (C),A ; MIDDLE
        INC C
        OUT (C),E ; HIGH
        INC C
        ; 8KiBコピーする
        LD DE,#0x800
copyEmm0ToMainMemory_LOOP:
            IN A,(C)
            LD (HL),A
            INC L
            IN A,(C)
            LD (HL),A
            INC L
            IN A,(C)
            LD (HL),A
            INC L
            IN A,(C)
            LD (HL),A
            INC HL
        DEC DE
        LD A,E
        OR D
        JP NZ,copyEmm0ToMainMemory_LOOP
    POP DE
    POP BC
    POP AF
    ;EI
    RET
.else
    PUSH AF
    PUSH BC
    PUSH DE
        ; アドレス設定
        LD BC,#0x0D00 ; EMM0
        LD E,C
        ADD A
        .rept 4
            RLA
            RL E
        .endm
        OUT (C),C ; LOW
        INC C
        OUT (C),A ; MIDDLE
        INC C
        OUT (C),E ; HIGH

;        LD BC,#0x1FA0+3
;        IN D,(C) ; Ch3の値を保存
;        LD A,#0x03
;        OUT (C),A ; Ch3をリセット

        ; DMAでコピー
        LD (dmaCommand_EMM0toMem_Address),HL
        LD HL,#dmaCommand_EMM0toMem
        LD BC,#0x1F80 + 0x0100
        OUTI
        .rept 12+3
        INC B
        OUTI
        .endm

        ; Ch3を再設定
;        LD BC,#0x1FA0+3
;        LD A,#0xD7
;        OUT (C),A
;        OUT (C),D

    POP DE
    POP BC
    POP AF
    RET
.endif

_copy8KiBFromEmm0ToMem4000:
    PUSH HL
        LD HL,#0x4000
        CALL _copy8KiBFromEmm0
    POP HL
    RET

_copy8KiBFromEmm0ToMem6000:
    PUSH HL
        LD HL,#0x6000
        CALL _copy8KiBFromEmm0
    POP HL
    RET

_copy8KiBFromEmm0ToMem8000:
    PUSH HL
        LD HL,#0x8000
        CALL _copy8KiBFromEmm0
    POP HL
    RET

_copy8KiBFromEmm0ToMemA000:
    PUSH HL
        LD HL,#0xA000
        CALL _copy8KiBFromEmm0
    POP HL
    RET




















;HL	転送元のメインメモリのアドレス
;DE	転送先のバンクメモリ0のアドレス
;BC	転送する長さ(単位はバイト)
_copyMainToBankMemory0:
    PUSH DE
    EXX
        POP HL
        LD BC,#0x0B00
        LD E,#0x10
    EXX
copyMainToBankMemory0_LOOP:
        ; 読み込んで
        LD A,(HL)
        INC HL
        ; 書き込む
        EXX
            ; バンクメモリ0に切り替え
            OUT (C),C
                LD (HL),A
            ; メインメモリに切り替え
            OUT (C),E ; E:0x10
            INC HL
        EXX
    DEC BC
    LD A,C
    OR B
    JR NZ,copyMainToBankMemory0_LOOP
    RET




copyMainToBankMemory0_:
;    if(0x8000 <= HL) {
;        copyMainToBankMemory0_sub2();
;    } else {
;        copyMainToBankMemory0_sub1();
;    }
    LD A,H
    CP #0x80
    JR NC,copyMainToBankMemory0_sub2
    ;JR copyMainToBankMemory0_sub1
;;
; バンクメモリ0へコピーする
; @param HL 転送元のメインメモリのアドレス
; @param DE 転送先のバンクメモリ0のアドレス(0x0000～0x7FFF)
; @param BC 転送する長さ(単位はバイト)
; @note 破壊 AF,BC,DE,HL
;;
copyMainToBankMemory0_sub1:
;    while(BC > 0x100) {
;        memcpy(TEMP_WORK,HL,0x100);
;        BANK0(); memcpy(DE,TEMP_WORK,0x100); MAIN_MEM();
;        HL+=0x100;
;        DE+=0x100;
;        BC-=0x100;
;    }
;    if(BC > 0) {
;        memcpy(TEMP_WORK,HL,BC);
;        BANK0(); memcpy(DE,TEMP_WORK,BC); MAIN_MEM();
;    }
    INC B
    DEC B
    JR Z,SKIP
LOOP:
        PUSH BC
        PUSH DE
        PUSH HL
            ; memcpy(TEMP_WORK,HL,0x100);
            PUSH DE
                LD DE,#TEMP_WORK ; コピー先
                LD BC,#0x0100 ; コピーするサイズ
                LDIR
            POP DE
            ; BANK0(); memcpy(DE,TEMP_WORK,0x100); MAIN_MEM();
            LD HL,#TEMP_WORK ; コピー元
            LD BC,#0x0100 ; コピーするサイズ
            CALL copyMainToBankMemory0_sub2
        POP HL
        POP DE
        POP BC
        INC H ; HL += 0x100;
        INC D ; DE += 0x100;
    DJNZ LOOP ; BC -= 0x100;
SKIP:
    INC C
    DEC C
    RET Z
    ; memcpy(TEMP_WORK,HL,BC);
    PUSH BC
    PUSH DE
        LD DE,#TEMP_WORK ; コピー先
        LDIR
    POP DE
    POP BC
    ; BANK0(); memcpy(DE,TEMP_WORK,0x100); MAIN_MEM();
    LD HL,#TEMP_WORK ; コピー元
    CALL copyMainToBankMemory0_sub2
    RET

;;
; バンクメモリ0へコピーする（転送元が範囲外のとき用）
; @param HL 転送元のメインメモリのアドレス(0x8000～0xFFFF)
; @param DE 転送先のバンクメモリ0のアドレス(0x0000～0x7FFF)
; @param BC 転送する長さ(単位はバイト)
; @note 破壊 AF,BC,DE,HL
; @note バンクメモリ(0x0000～0x7FFF)の範囲外にこのプロシージャを置くこと
;;
copyMainToBankMemory0_sub2:
    ; バンクメモリ0に切り替え
    EXX
        PUSH BC
        LD BC,#0x0B00
        OUT (C),C
    EXX
    ; バンクメモリ0へコピー
    LDIR
    ; メインメモリに切り替え
    EXX
        LD A,#0x10
        OUT (C),A
        POP BC
    EXX
    RET

;;
; @brief プログラムを読み込んで実行する
; @param HL 読み込むプログラム名
;;
_copyProgram::
    DI
    LDIR
    LD SP,#STACK_POINTER
    JP 0x1000
