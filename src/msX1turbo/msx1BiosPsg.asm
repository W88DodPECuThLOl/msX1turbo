    .z80
    .module msx1Bios
    .area _CODE
    .allow_undocumented

.include /setting.inc/
.include /nekoSys.inc/
.include /msx1BiosPsg.inc/

; PSGレジスタ7の値
PSG_REG7:
    .DB 0x00

; PSGレジスタ15の値
PSG_REG15:
    .DB 0xFF

; ジョイスティックの状態
JOY_STICK0_STATS:
    .DB 0xFF
JOY_STICK1_STATS:
    .DB 0xFF

;;
; @brief ジョイスティック読み込み
;;
JOY_STICK_UPDATA:
    PUSH AF
    PUSH BC
        ; ジョイスティック1読み込み
        LD BC,#0x1C0E
        OUT (C),C
        DEC B
        IN A,(C)
        LD (JOY_STICK0_STATS),A
        ; ジョイスティック2読み込み
        INC B
        INC C
        OUT (C),C
        DEC B
        IN A,(C)
        LD (JOY_STICK1_STATS),A
    POP BC
    POP AF
    RET

;;
; @brief GICINI (0090H/MAIN)
; PSGを初期化し、PLAY文のための初期値を設定する。
;
; @note 変更レジスタ すべて
;;
_GICINI:
    DI
        CALL x1_psgReset
    EI
    RET

;;
; @brief WRTPSG (0093H/MAIN)
; PSGのレジスタにデータを書き込む。
;
; @param[in]    A   PSGのレジスタ番号
; @param[in]    E   書き込むデータ
; @note 呼び出し後に割り込み許可になる
;;
_WRTPSG:
    PUSH AF
        CP A,#0x07
        JR Z,WRTPSG_REGISTER7 ; PSGレジスタ7番への書き込み
        CP A,#0x0F
        JR Z,WRTPSG_PORT_B ; PSGレジスタ15番への書き込み
        PUSH BC
            LD B,#0x1C
            DI
                OUT	(C),A ; PSGレジスタ番号
                DEC B
                OUT	(C),E ; データ書き込み
            EI
        POP BC
    POP AF
    RET
; PSGレジスタ15番への書き込み
; ・X1では書き込まない
; ・ジョイスティック読み込みの時に参照
WRTPSG_PORT_B:
        LD A,E
        LD (PSG_REG15),A
        EI
    POP AF
    RET
; PSGレジスタ7番への書き込み
; ・X1ではIOポートの設定を常に入力にしておく
WRTPSG_REGISTER7:
        PUSH BC
            LD B,#0x1C
            DI
                OUT	(C),A ; PSGレジスタ番号
                DEC B
                LD A,E
                LD (PSG_REG7),A
                AND #0x3F ; IOポートを常に読み込みにしておく
                OUT	(C),A ; データ書き込み
            EI
        POP BC
    POP AF
    RET

;;
; @brief RDPSG (0096H/MAIN)
; PSGレジスタの値を読み出します。
;
; @param[in]    A   PSGのレジスタ番号
; @return       A   読み出した値
;;
_RDPSG:
    CP A,#0x0E
    JR Z,RDPSG_PORT_A ; ジョイスティックの読み込み
    CP A,#0x07
    JR Z,RDPSG_REGISTER7 ; PSGレジスタ7番の読み込み
RDPSG_SUB:
    PUSH BC
        LD B,#0x1C
        OUT	(C),A ; PSGレジスタ番号
        DEC B
        IN A,(C) ; データ読み込み
    POP BC
    RET
RDPSG_PORT_A:
    ; レジスタ15の内容でどちらから入力するかを決める
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
    ; 読み込んでMSX用に加工
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

RDPSG_REGISTER7:
    LD A,(PSG_REG7)
    RET

;;
; @brief GTSTCK (00D5H/MAIN)
; ジョイスティックまたはカーソルキーの状態を調べます。
;
; @param[in]    A   調べるジョイスティックの番号（0=カーソルキー、1～2=ジョイスティック）
; @return       A   ジョイスティックまたはカーソルキーの押された方向
; @retval       0: どの方向にも向いていない（押されていない）
; @retval       1: 上
; @retval       2: 右上
; @retval       3: 右
; @retval       4: 右下
; @retval       5: 下
; @retval       6: 左下
; @retval       7: 左
; @retval       8: 左上
;;
_GTSTCK:
    OR A
    RET Z ; カーソルキーは未対応
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

;;
; @brief GTTRIG (00D8H/MAIN)
; トリガボタンの状態を調べます。
;
; @param A 調べるトリガボタンの番号
;           0: スペースキー
;           1: ポート1のトリガボタンA
;           2: ポート2のトリガボタンA
;           3: ポート1のトリガボタンB
;           4: ポート2のトリガボタンB
;
; A	0		トリガボタンは押されていない
; FFH		トリガボタンは押されている
; 変更レジスタ
; AF
;;
_GTTRIG:
    OR A
    RET Z ; スペースキーは未対応
    DI
    CALL JOY_STICK_UPDATA
    EI
    DEC A
    JR Z,GTTRIG_PORT1_BUTTON_A
    DEC A
    JR Z,GTTRIG_PORT2_BUTTON_A
    DEC A
    JR Z,GTTRIG_PORT1_BUTTON_B
GTTRIG_PORT2_BUTTON_B:
    LD A,(JOY_STICK1_STATS)
    BIT 6,A
    JR Z,GTTRIG_ON
GTTRIG_OFF:
    XOR A
    RET
GTTRIG_ON:
    LD A,#0xFF
    RET
GTTRIG_PORT2_BUTTON_A:
    LD A,(JOY_STICK1_STATS)
    BIT 5,A
    JR Z,GTTRIG_ON
    JR GTTRIG_OFF
GTTRIG_PORT1_BUTTON_A:
    LD A,(JOY_STICK0_STATS)
    BIT 5,A
    JR Z,GTTRIG_ON
    JR GTTRIG_OFF
GTTRIG_PORT1_BUTTON_B:
    LD A,(JOY_STICK0_STATS)
    BIT 6,A
    JR Z,GTTRIG_ON
    JR GTTRIG_OFF


;;
; OUT (0xA0),A
;;
IN_OUT_HOOK_OUT_0xA0_A:
    LD A,(SAVE_A)
    LD (PSG_REGISTER_NO),A
    RET
PSG_REGISTER_NO:
    .DB 0x00

;;
; OUT (0xA1),A
;;
IN_OUT_HOOK_OUT_0xA1_A:
    LD A,(SAVE_A)
    PUSH DE
        LD E,A
        LD A,(PSG_REGISTER_NO)
        CALL _WRTPSG
    POP DE
    LD A,(SAVE_A)
    RET

;;
; IN A,(0xA2)
;;
IN_OUT_HOOK_IN_A_0xA2:
    LD A,(PSG_REGISTER_NO)
    JP _RDPSG

;;
; PPI
;;
IN_OUT_HOOK_OUT_0xAA_A:
    LD A,(SAVE_A)
    LD (PPI_REGISTER_NO),A
    RET
PPI_REGISTER_NO:
    .DB 0x00

;;
; PPI
;;
IN_OUT_HOOK_IN_A_0xA9:
    ;LD A,(SAVE_A)
    LD A,(PPI_REGISTER_NO)
    OR A
    RET NZ
    ; 0行
    PUSH HL
        ; 「1」キー押下チェック
        LD A,(GAME_KEY_STATE+2)
        LD L,A
        LD A,#0xFF
        BIT 6,L
        JR Z,SKIP_KEY1
        XOR #0x02
SKIP_KEY1:
    POP HL
    RET

;;
; RST 0x28
; 
;   RST 0x28
;   .DB 機能番号
;;
IN_OUT_HOOK_PSG_AND_PPI:
    EX (SP),HL
    LD (SAVE_A),A
    LD A,(HL) ; 機能番号
    INC HL
    EX (SP),HL
    ; PSG
    SUB #0xA0 ;CP #0xA0
    JP Z,IN_OUT_HOOK_OUT_0xA0_A
    DEC A ;CP #0xA1
    JP Z,IN_OUT_HOOK_OUT_0xA1_A
    DEC A ;CP #0xA2
    JP Z,IN_OUT_HOOK_IN_A_0xA2
    ; PPI
    SUB #0x07 ;CP #0xA9
    JP Z,IN_OUT_HOOK_IN_A_0xA9
    DEC A ;CP #0xAA
    JP Z,IN_OUT_HOOK_OUT_0xAA_A
    ;
IN_OUT_HOOK_PSG_EXIT:
    .DB 0x3E
SAVE_A:
    .DB 0x00
    RET

;;
; @brief ゲームキーを取得する
;
; @note 変更レジスタ AF,BC,HL
;;
GET_GAME_KEY_REQUEST:
    LD A,#0xE3 ; ゲームキー読み取り
    JP SUB_CPU_SEND

GET_GAME_KEY_RESPONSE:
    ; 3バイトゲームキーの情報を読み込み
    CALL SUB_CPU_RECEIVE
    LD HL,#GAME_KEY_STATE
    LD (HL),A
    INC HL
    CALL SUB_CPU_RECEIVE
    LD (HL),A
    INC HL
    CALL SUB_CPU_RECEIVE
    LD (HL),A
    RET
GAME_KEY_STATE:
    ; QWEADZXC
    .DB 0x00
    ; 74182963   全部テンキー側
    .DB 0x00
    ; ESC,1,-,+,*,TAB,SPACE,RET    「-,+,*」はテンキー側
    .DB 0x00
;; 
;; KEY_UPDATE:
;;     LD HL,#0xFFFF
;;     ; RETURN
;;     LD A,(GAME_KEY_STATE+2)
;;     BIT 0,A
;;     JR Z,GAME_KEY_STATE_SKIP0
;;     RES 7,L
;; GAME_KEY_STATE_SKIP0:
;;     ; SPACE
;;     BIT 1,A
;;     JR Z,GAME_KEY_STATE_SKIP1
;;     RES 0,H
;; GAME_KEY_STATE_SKIP1:
;;     ; TAB
;;     BIT 2,A
;;     JR Z,GAME_KEY_STATE_SKIP2
;;     RES 3,L
;; GAME_KEY_STATE_SKIP2:
;;     LD (NEWKEY+7),HL
;; 
;;     LD L,#0xFF
;;     ; 1
;;     BIT 6,A
;;     JR Z,GAME_KEY_STATE_SKIP6
;;     RES 1,L
;; GAME_KEY_STATE_SKIP6:
;;     LD A,L
;;     LD (NEWKEY+0),A
;; 
;;     LD HL,#0xFFFF
;;     ; 3
;;     LD A,(GAME_KEY_STATE+1)
;;     BIT 0,A
;;     JR Z,GAME_KEY_STATE_SKIP9_6
;;     RES 6,L
;; GAME_KEY_STATE_SKIP9_6:
;;     ; 6
;;     BIT 1,A
;;     JR Z,GAME_KEY_STATE_SKIP10_1
;;     RES 1,H
;; GAME_KEY_STATE_SKIP10_1:
;;     ; 9
;;     BIT 2,A
;;     JR Z,GAME_KEY_STATE_SKIP10_4
;;     RES 4,H
;; GAME_KEY_STATE_SKIP10_4:
;;     ; 2
;;     BIT 3,A
;;     JR Z,GAME_KEY_STATE_SKIP9_5
;;     RES 5,L
;; GAME_KEY_STATE_SKIP9_5:
;;     ; 8
;;     BIT 4,A
;;     JR Z,GAME_KEY_STATE_SKIP10_3
;;     RES 3,H
;; GAME_KEY_STATE_SKIP10_3:
;;     ; 1
;;     BIT 5,A
;;     JR Z,GAME_KEY_STATE_SKIP9_4
;;     RES 4,L
;; GAME_KEY_STATE_SKIP9_4:
;;     ; 4
;;     BIT 6,A
;;     JR Z,GAME_KEY_STATE_SKIP9_7
;;     RES 7,L
;; GAME_KEY_STATE_SKIP9_7:
;;     ; 7
;;     BIT 7,A
;;     JR Z,GAME_KEY_STATE_SKIP10_2
;;     RES 2,H
;; GAME_KEY_STATE_SKIP10_2:
;; 
;;     LD (NEWKEY+9),HL
;;     RET
