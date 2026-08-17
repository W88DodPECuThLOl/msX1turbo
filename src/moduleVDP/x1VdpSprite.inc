;;
; @brief 消去リスト初期化
;
; @param[in]    HL  消去リストの開始アドレス
; @note 変更レジスタ AF,BC,HL
;;
    .globl initEraceList

; スプライト消去
    .globl eraseSprite0
    .globl eraseSprite1

; スプライト描画
    .globl renderSprite

    ; スプライト消去用
;    .globl _erase8x8
;    .globl _erase16x8
