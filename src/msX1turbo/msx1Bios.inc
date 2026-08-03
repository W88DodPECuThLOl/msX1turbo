;;
; @brief 初期化
;;
    .globl _INITIALIZE

;;
; @brief CTCを設定する
;;
    .globl _CTC_SETUP

; MSX BIOS

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
    .globl _RDSLT

;;
; @brief ENASLT (0024H/MAIN)
; Aレジスタの値に対応するスロットを選択し、以降そのスロットを使用可能にします。
; このルーチンを呼ぶと、割り込みを禁止し、実行後も割り込みは解除されません。
;
; @param[in]    A   スロット操作（形式はRDSLTと同じ）
; @note 変更レジスタ すべて
;;
    .globl _ENASLT

;;
; @brief RSLREG (0138H/MAIN)
; 基本スロット選択レジスタに出力している内容を読み出します。
;
; @return   A   読み込んだ値
;;
    .globl _RSLREG

;;
; SNSMAT (0141H/MAIN)
; キーボードマトリックスから指定した行の値を読み出します。
;
; @param[in]    A   指定する行
; @note 変更レジスタ AF,C
;;
    .globl _SNSMAT
