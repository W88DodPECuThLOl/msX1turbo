    .z80
    .module pcg
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /PCG.inc/

    .area _CODE

;;
; @brief クリアパターン
;;
_patternZero:
    .rept 16
    .DB 0x00
    .endm

;;
; @brief PCGの初期化
; PCGの書き換えができるように、アトリビュートなどを設定する
;
; @note 変更レジスタ AF,BC
;;
_pcgInit:
    ; 漢字
    LD BC,#0x3FFF
    .db #0xED, #0x71 ; out (c),0 ; Output 0 to port BC.
    ; 属性
    LD B,#0x27      ; bc: 0x27FF
    LD A,#0x20
    OUT (C),A
    RET

;;
; @brief 青のPCGを設定する
;
; @param[in]    HL  PCGデータ
; @param[in]    E   設定するPCG文字
; @note 変更レジスタ BC,HL
;;
_setPcgB:
    ; 設定する文字
    LD BC,#0x37FF ; 10
    OUT (C),E     ; 12
setPcgB_sub:
    ; pcg書き込む 
    LD BC,#0x1600 ; 10
    OUTI          ; 16
    LD BC,#0x1602 ; 10
    OUTI          ; 16
    LD BC,#0x1604 ; 10
    OUTI          ; 16
    LD BC,#0x1606 ; 10
    OUTI          ; 16
    LD BC,#0x1608 ; 10
    OUTI          ; 16
    LD BC,#0x160A ; 10
    OUTI          ; 16
    LD BC,#0x160C ; 10
    OUTI          ; 16
    LD BC,#0x160E ; 10
    OUTI          ; 16
             ; 26*8 = 208
    RET

;;
; @brief 赤のPCGを設定する
;
; @param[in]    HL  PCGデータ
; @param[in]    E   設定するPCG文字
; @note 変更レジスタ BC,HL
;;
_setPcgR:
    ; 設定する文字
    LD BC,#0x37FF ; 10
    OUT (C),E     ; 12
setPcgR_sub:
    ; pcg書き込む 
    LD BC,#0x1700 ; 10
    OUTI          ; 16
    LD BC,#0x1702 ; 10
    OUTI          ; 16
    LD BC,#0x1704 ; 10
    OUTI          ; 16
    LD BC,#0x1706 ; 10
    OUTI          ; 16
    LD BC,#0x1708 ; 10
    OUTI          ; 16
    LD BC,#0x170A ; 10
    OUTI          ; 16
    LD BC,#0x170C ; 10
    OUTI          ; 16
    LD BC,#0x170E ; 10
    OUTI          ; 16
             ; 26*8 = 208
    RET

;;
; @brief 緑のPCGを設定する
;
; @param[in]    HL  PCGデータ
; @param[in]    E   設定するPCG文字
; @note 変更レジスタ BC,HL
;;
_setPcgG:
    ; 設定する文字
    LD BC,#0x37FF ; 10
    OUT (C),E     ; 12
setPcgG_sub:
    ; pcg書き込む 
    LD BC,#0x1800 ; 10
    OUTI          ; 16
    LD BC,#0x1802 ; 10
    OUTI          ; 16
    LD BC,#0x1804 ; 10
    OUTI          ; 16
    LD BC,#0x1806 ; 10
    OUTI          ; 16
    LD BC,#0x1808 ; 10
    OUTI          ; 16
    LD BC,#0x180A ; 10
    OUTI          ; 16
    LD BC,#0x180C ; 10
    OUTI          ; 16
    LD BC,#0x180E ; 10
    OUTI          ; 16
             ; 26*8 = 208
    RET

_setPcgColorBlack:
    LD E,A
    LD HL,#_patternZero
    CALL _setPcgB
    LD HL,#_patternZero
    CALL setPcgG_sub
    JP setPcgR_sub

_setPcgColorGreen:
    CALL _setPcgG
    LD HL,#_patternZero
    CALL setPcgB_sub
    JP setPcgR_sub

_setPcgColorBlue:
    CALL _setPcgB
    LD HL,#_patternZero
    CALL setPcgG_sub
    JP setPcgR_sub

_setPcgColorRed:
    CALL _setPcgR
    LD HL,#_patternZero
    CALL setPcgB_sub
    JP setPcgG_sub

_setPcgColorCyan:
    PUSH HL
        CALL _setPcgB
    POP HL
    CALL setPcgG_sub
    LD HL,#_patternZero
    JP setPcgR_sub

_setPcgColorYellow:
    PUSH HL
        CALL _setPcgG
    POP HL
    CALL setPcgR_sub
    LD HL,#_patternZero
    JP setPcgB_sub

_setPcgColorWhite:
    PUSH HL
        CALL _setPcgB
    POP HL
    PUSH HL
        CALL setPcgG_sub
    POP HL
    JP setPcgR_sub
