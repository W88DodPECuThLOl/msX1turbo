
;;
; @brief クリアパターン
;;
    .globl _patternZero

;;
; @brief PCGの初期化
; PCGの書き換えができるように、アトリビュートなどを設定する
;
; @note 変更レジスタ AF,BC
;;
    .globl _pcgInit

;;
; @brief 青のPCGを設定する
;
; @param[in]    HL  PCGデータ
; @param[in]    E   設定するPCG文字
; @note 変更レジスタ BC,HL
;;
    .globl _setPcgB

;;
; @brief 赤のPCGを設定する
;
; @param[in]    HL  PCGデータ
; @param[in]    E   設定するPCG文字
; @note 変更レジスタ BC,HL
;;
    .globl _setPcgR

;;
; @brief 緑のPCGを設定する
;
; @param[in]    HL  PCGデータ
; @param[in]    E   設定するPCG文字
; @note 変更レジスタ BC,HL
;;
    .globl _setPcgG

    .globl _setPcgColorBlack
    .globl _setPcgColorGreen
    .globl _setPcgColorBlue
    .globl _setPcgColorRed
    .globl _setPcgColorCyan
    .globl _setPcgColorYellow
    .globl _setPcgColorWhite
