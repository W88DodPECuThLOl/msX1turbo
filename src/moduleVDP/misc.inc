;;
; @brief GRAPHIC1モードかどうかを調べる
;
; @return       GRAPHIC1モードかどうか
; @retval       Z  : GRAPHIC1モード
; @retval       NZ : GRAPHIC2またはGRAPHIC3モード
; @note 変更レジスタ AF
;;
    .globl _IS_GRA1

;;
; @brief パターンジェネレータテーブルのアドレスの上位８ビットを取得する
;
; @return       A : パターンジェネレータテーブルのアドレスの上位８ビット
; @note 変更レジスタ AF
;;
    .globl _GET_PATTERN_GENERATOR_TABLE_ADDRESS
