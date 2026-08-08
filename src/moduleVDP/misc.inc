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

;;
; グラフィックパレット(コンパチモード)の初期化
; @note 破壊レジスタ BC
;;
    .globl GRAPHICS_PALETTE_INIT

;;
; グラフィックパレット(コンパチモード)をすべて黒にする
; @note 破壊レジスタ BC
;;
    .globl GRAPHICS_PALETTE_ALL_BLACK

;;
; @brief スプライトパターンジェネレータテーブルのアドレスを計算する
; @param[in]    A   VDP R#6の値
; @return       HL  スプライトパターンジェネレータテーブルのアドレス
; @return       A   上位8bitのアドレス
;;
    .globl calcSpritePatternGeneratorTableAddress

;;
; @brief スプライトアトリビュートテーブルのアドレスを計算する
; @param[in]    A   VDP R#5の値
; @return       HL  スプライトアトリビュートテーブルのアドレス
; @return       A   上位8bitのアドレス
;;
    .globl calcSpriteAttributeTableAddress



; @param[in]    HL  パターンネームテーブルのアドレス
    .globl setPatternNameTable

; @param[in]    HL  カラーテーブルのアドレス
    .globl setColorTable

; @param[in]    HL  パターンジェネレータテーブルのアドレス
    .globl setPatternGeneratorTable

; @param[in]    HL  スプライトアトリビュートテーブルのアドレス
    .globl setSpriteAttributeTable

; @param[in]    HL  スプライトジェネレータテーブルのアドレス
    .globl setSpriteGeneretorTable
