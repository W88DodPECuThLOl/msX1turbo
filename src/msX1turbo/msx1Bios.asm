    .z80
    .module msx1Bios
    .area _CODE
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /nekoSys.inc/
.include /msx1Bios.inc/
.include /msx1BiosPsg.inc/
.include /msx1BiosVdp.inc/

SYSTEM_STACK    .equ    0x4000 ; システム用のスタックアドレス

    .macro MSX_BIOS address, routine
    LD A,#0xC3
    LD (address),A
    LD HL,#routine
    LD (address+1),HL
    .endm

    .macro MSX_BIOS_NOT_IMPL address, routine
    LD A,#0xC9
    LD (address),A
    .endm

; ユーザー側のスタックポインタ保存用
SP_SAVE:
    .DW 0x0000

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

;;
; @brief CTCを設定する
;;
_CTC_SETUP:
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
	LD BC,#0x1FA0
    LD  HL,#0x1700 + 25
;	LD  HL,#0x1700 + 250 ; test 10倍
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

;;
; 初期化
;;
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
    ; パターンネームテーブルのアドレス
    LD HL,#0x1800
    LD (T32NAM),HL
    LD (GRPNAM),HL ; パターンネームテーブルの先頭アドレス
    LD (NAMBAS),HL
    ; カラーテーブルのアドレス
    LD HL,#0x2000
    LD (T32COL),HL
    LD (GRPCOL),HL ; カラーテーブルの先頭アドレス
    ; パターンジェネレータテーブルのアドレス
    LD HL,#0x0000
    LD (T32CGP),HL
    LD (GRPCGP),HL ; パターンジェネレータテーブルの先頭アドレス
    LD (CGPBAS),HL
    ; スプライトアトリビュートテーブルのアドレス
    LD HL,#0x1B00
    LD (T32ATR),HL
    LD (GRPATR),HL ; スプライトアトリビュートテーブルの先頭アドレス
    LD (ATRBAS),HL
    ; スプライトジェネレータテーブルのアドレス
    LD HL,#0x3800
    LD (T32PAT),HL
    LD (GRPPAT),HL ; スプライトジェネレータテーブルの先頭アドレス
    LD (PATBAS),HL
    ;
    LD A,#39
    LD (LINL40),A
    LD A,#29
    LD (LINL32),A
    LD (LINLEN),A
    LD A,#24
    LD (CRTCNT),A
    LD A,#14
    LD (CLMLST),A
    ; メインROMの先頭領域に配置されているシステム変数（ID Byte 1）のアドレスです。このアドレスの1バイトは、起動時のシステム情報をハードウェアの仕様に合わせて保持しています。ビット構成（b7 ~ b0）による意味は以下の通りです：ビット 7（b7）：デフォルトの割り込み周波数0 = 60Hz (NTSC圏など)1 = 50Hz (PAL圏など)ビット 5～6（b6-b5）：日付フォーマット00 = 年-月-日 (Y-M-D)01 = 月-日-年 (M-D-Y)10 = 日-月-年 (D-M-Y)ビット 0～4（b4-b0）：キャラクタセット（フォント）の種類0 = 日本語1 = インターナショナル2 = 韓国語この変数の値を取得することで、稼働しているMSXマシンの地域仕様をソフトウェア側で判別することが可能です
    ; https://map.grauw.nl/resources/msxsystemvars.php
    ;
    ; 60Hz Y-M-D 日本語
    ; 0    00    00000
    LD A,#0
    LD (0x002B),A
    ; Basic version Keyboard type
    ; Japanese      Japanese
    LD (0x002C),A
    ; MSX 1
    LD (0x002D),A

    ; ------------------------------
    ; キーボード関連の初期設定
    ; ------------------------------
    ; 旧キーの状態
    ; 新キーの状態
    LD HL,#OLDKEY ; 11バイト 旧キーの状態
    LD DE,#OLDKEY+1
    LD BC,#22-1
    LD (HL),#0xFF
    LDIR
    ;
    LD A,#1
    LD (SCNCNT),A  ; 1バイト キースキャンの時間間隔
    ;
    LD HL,#KEYBUF
    LD (PUTPNT),HL ; 2バイト キーバッファへの書き込みを行う番地を指す
    LD (GETPNT),HL ; 2バイト キーバッファからの読み込みを行う番地を指す

    ; ------------------------------
    LD HL,#0x0000
    LD (JIFFY),HL
    ;
    LD (0x0036),HL
    ; 
    LD A,#VDP_DR
    LD (0x0006),A
    LD A,#VDP_WR
    LD (0x0007),A
    ; MSX BIOS
    MSX_BIOS 0x000C, _RDSLT
    MSX_BIOS 0x0020, _DCOMPR
    MSX_BIOS 0x0024, _ENASLT
;    MSX_BIOS 0x0038, INT              ; 割り込み
    MSX_BIOS_NOT_IMPL 0x003B, _INITIO
    MSX_BIOS_NOT_IMPL 0x003E, _INIFNK
    MSX_BIOS 0x0041, _DISSCR ; 画面表示を禁止します。
    MSX_BIOS 0x0044, _ENASCR ; 画面を表示します。
    MSX_BIOS 0x0047, _WRTVDP
    MSX_BIOS 0x004A, _RDVRM
    MSX_BIOS 0x004D, _WRTVRM
    MSX_BIOS 0x0050, _SETRD
    MSX_BIOS 0x0053, _SETWRT
    MSX_BIOS 0x0056, _FILVRM
    MSX_BIOS 0x0059, _LDIRMV
    MSX_BIOS 0x005C, _LDIRVM
    MSX_BIOS_NOT_IMPL 0x0062, _CHGCLR
    MSX_BIOS 0x0069, _CLRSPR
    MSX_BIOS 0x006F, _INIT32
    MSX_BIOS 0x0072, _INIGRP
    MSX_BIOS 0x0084, _CALPAT
    MSX_BIOS 0x0087, _CALATR
    MSX_BIOS 0x008A, _GSPSIZ
    MSX_BIOS_NOT_IMPL 0x008D, _GRPPRT ; グラフィック画面に文字を表示します。
    MSX_BIOS 0x0090, _GICINI
    MSX_BIOS 0x0093, _WRTPSG
    MSX_BIOS 0x0096, _RDPSG
    MSX_BIOS_NOT_IMPL 0x0099, _STRTMS
    MSX_BIOS_NOT_IMPL 0x00A2, _CHPUT
    MSX_BIOS_NOT_IMPL 0x00A5, _LPTOUT
    MSX_BIOS_NOT_IMPL 0x00A8, _LPTSTT
    MSX_BIOS_NOT_IMPL 0x00D1, _CHGMOD
    MSX_BIOS 0x00D5, _GTSTCK
    MSX_BIOS 0x00D8, _GTTRIG
    MSX_BIOS_NOT_IMPL 0x0132, _CHGCAP
    MSX_BIOS_NOT_IMPL 0x0135, _CHGSND
    MSX_BIOS 0x0138, _RSLREG
    MSX_BIOS_NOT_IMPL 0x013B, _WSLREG ; 基本スロット選択レジスタにデータを書き出します。
    MSX_BIOS 0x013E, _RDVDP
    MSX_BIOS 0x0141, _SNSMAT
    ; IO PATCH
    MSX_BIOS 0x0000, OUT_HOOK
    MSX_BIOS 0x0008, _BLOCK_IN_OUT_HOOK
    MSX_BIOS 0x0010, IN_OUT_HOOK_OUT_0x99_A ; CHRGTR (0010H/MAIN) ; BASICテキストから文字（またはトークン）を取り出します。
    MSX_BIOS 0x0018, IN_OUT_HOOK_IN_A_0x99  ; OUTDO (0018H/MAIN) 現在使っているデバイスに値を出力します。
    MSX_BIOS 0x0028, IN_OUT_HOOK_PSG_AND_PPI ; GETYPR (0028H/MAIN)
    MSX_BIOS 0x0030, IN_OUT_HOOK_OUT_0x98_A
    MSX_BIOS 0x0038, IN_HOOK

    ; VDPレジスタ初期化
    LD HL,#VDP_INIT_DATA
    LD C,#0x00
vdpInit_LOOP1:
        LD B,(HL)
        INC HL
        CALL _WRTVDP  ; VDP R#0-R#7
        INC C
    BIT 3,C
    JR Z,vdpInit_LOOP1
    RET

VDP_INIT_DATA:
    .DB 0x00,0xE0,0x06,0x80,0x00,0x36,0x07,0xF7

; https://ngs.no.coocan.jp/doc/wiki.cgi/datapack?page=3%BE%CF+%A5%EC%A5%B8%A5%B9%A5%BF%A4%CE%B5%A1%C7%BD
; VDP
; Status register 0
; F     垂直帰線割り込みフラグ
;       S#0を読み出すとリセットされる
; 5S    第5スプライトフラグ
;       1水平線上にスプライトが5個(GRAPHIC3～GRAPHIC7モードは9個)並ぶとリセットされる
; C     衝突フラグ
;       スプライトが衝突するとセットされる
; 5th sprite#   第5(第9)スプライトの番号がセットされる
;


; 割り込み処理
INT:
    DI
    PUSH AF
        ; 垂直帰線割り込みフラグをセット
        LD A,#0x80
        LD (STATFL),A

        LD A,(RG1SAV) ; VDPレジスタ1の保存場所
        BIT 5,A
        JP Z,INT_EXIT ; IRQが無効になっている

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
                ; キーボード読み込みリクエスト
                CALL GET_GAME_KEY_REQUEST ; リクエストを出して

                ; 描画
                LD A,(RG1SAV) ; VDPレジスタ1の保存場所
                BIT 6,A ; VDP表示かどうか
                CALL NZ,_vdpRender

                ; CTC 再設定
            	LD  BC,#0x1FA0 + 3
            	LD  HL,#0xD700 + 167
                OUT (C),H
                OUT (C),L

                ; 垂直帰線割り込みフラグをセット
                ;LD A,#0x80
                ;LD (STATFL),A

                ; キーボード受信
                CALL GET_GAME_KEY_RESPONSE ; 後で受信する
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

            LD HL,(SP_SAVE)
            LD SP,HL
        POP HL

;        LD A,(RG1SAV) ; VDPレジスタ1の保存場所
;        BIT 5,A
;        JP Z,INT_EXIT ; IRQが無効になっている
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

; https://ngs.no.coocan.jp/doc/wiki.cgi/datapack?page=2%BE%CF+%B3%E4%A4%EA%B9%FE%A4%DF
INT_HOOK:
    DI
    PUSH HL
    PUSH DE
    PUSH BC
    PUSH AF
    EXX
    EX AF,AF'
    PUSH HL
    PUSH DE
    PUSH BC
    PUSH AF
    PUSH IY
    PUSH IX
        ; H.KEYIを呼ぶ
        CALL #H_KEYI
        NOP
        NOP

        ; VDPレジスタがすでに読み込まれていたらスキップする
        ; メモ）読むことによって、VDPの垂直同期割り込み信号がクリアされる。
        CALL _RDVDP
        OR A
        JP P,INT_HOOK_SKIP1
        ; H.TIMIを呼ぶ
        CALL #H_TIMI

        ;
        LD HL,(JIFFY)
        INC HL
        LD (JIFFY),HL
        ; 
        LD HL,#SCNCNT
        DEC (HL)
        JR NZ,INT_HOOK_SKIP1
        LD (HL),#2
INT_HOOK_SKIP1:
    POP IX
    POP IY
    POP AF
    POP BC
    POP DE
    POP HL
    EX AF,AF'
    EXX
    POP AF
    POP BC
    POP DE
    POP HL
    EI
    RET

;;
; @brief RDSLT (000CH/MAIN)
; Aレジスタの値に対応するスロットを選択し、
; そのスロットのメモリを1バイト読み出します。
; このルーチンを呼ぶと、割り込みを禁止し、実行後も割り込みは解除されません。
;
; @param[in]    A   スロット操作
; @param[in]    HL  読み込むメモリの番地
; @return       A   読み込んだメモリの値
; @note 変更レジスタ AF、BC、DE
;;
_RDSLT:
    DI ; 割り込み禁止。実行後も許可しない。
    CP #0x01
    JR NZ,RDSLT_SKIP
    ; 自分のスロット（基本スロット番号1）
    LD A,(HL)
    RET
RDSLT_SKIP:
    ; 他のスロット
    LD A,#0xFF
    RET

;;
; @brief DCOMPR (0020H/MAIN)
; HLレジスタとDEレジスタの内容を比較します。
;
; @param[in]    HL  比較する値1
; @param[in]    DE  比較する値2
; @return 比較結果
; @note 変更レジスタ AF
;;
_DCOMPR:
    LD A,H
    SUB D
    RET NZ
    LD A,L
    SUB E
    RET

;;
; @brief ENASLT (0024H/MAIN)
; Aレジスタの値に対応するスロットを選択し、以降そのスロットを使用可能にします。
; このルーチンを呼ぶと、割り込みを禁止し、実行後も割り込みは解除されません。
;
; @param[in]    A   スロット操作（形式はRDSLTと同じ）
; @note 変更レジスタ すべて
;;
_ENASLT:
    DI ; 割り込み禁止。実行後も許可しない。
    RET

;;
; @brief RSLREG (0138H/MAIN)
; 基本スロット選択レジスタに出力している内容を読み出します。
;
; @return   A   読み込んだ値
;;
_RSLREG:
    LD A,#0xF4 ; @todo
    RET

;;
; SNSMAT (0141H/MAIN)
; キーボードマトリックスから指定した行の値を読み出します。
;
; @param[in]    A   指定する行
; @note 変更レジスタ AF,C
;;
_SNSMAT:
    LD A,#0xFF
    EI ; 割り込み許可状態になる
    RET
