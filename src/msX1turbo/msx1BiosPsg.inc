; MSX BIOS

;;
; @brief GICINI (0090H/MAIN)
; PSGを初期化し、PLAY文のための初期値を設定する。
;
; @note 変更レジスタ すべて
;;
    .globl _GICINI

;;
; @brief WRTPSG (0093H/MAIN)
; PSGのレジスタにデータを書き込む。
;
; @param[in]    A   PSGのレジスタ番号
; @param[in]    E   書き込むデータ
; @note 呼び出し後に割り込み許可になる
;;
    .globl _WRTPSG

;;
; @brief RDPSG (0096H/MAIN)
; PSGレジスタの値を読み出します。
;
; @param[in]    A   PSGのレジスタ番号
; @return       A   読み出した値
;;
    .globl _RDPSG

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
    .globl _GTSTCK

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
    .globl _GTTRIG

;;
; PSGとPPI用のIOフック
;;
    .globl IN_OUT_HOOK_PSG_AND_PPI
