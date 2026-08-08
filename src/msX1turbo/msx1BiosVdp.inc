; MSX BIOS

;;
; @brief DISSCR (0041H/MAIN)
; 画面表示を禁止します。
; 
; @note 変更レジスタ AF,BC
;;
    .globl _DISSCR

;;
; @brief ENASCR (0044H/MAIN)
; 画面を表示します。
; 
; @note 変更レジスタ AF,BC
;;
    .globl _ENASCR

;;
; @brief SETRD (0050H/MAIN)
; VDPにVRAMアドレスをセットして、読み出せる状態にします。
; このルーチンはVDPのアドレスオートインクリメントの機能を使って、
; 連続したVRAM領域からデータを読み出すときに使います。
; このルーチンの実行後はポートから直接VRAMから読み出します。
; したがって、RDVRMをループ中で使うより高速な読み出しができます。
; ただし、このルーチンはTMS9918に対するもので、
; VRAMのアドレスは下位14ビットのみが有効です。
; 全ビットを使うときは、NSETRD(016EH/MAIN)を使います。
;
; @param[in]    HL  VRAMアドレス
; @note 変更レジスタ AF
;;
    .globl _SETRD

;;
; @brief SETWRT (0053H/MAIN)
; VDPにVRAMアドレスをセットして、書き込める状態にします。
; 使用目的はSETRDと同じです。
; ただし、このルーチンはTMS9918に対するもので、
; VRAMのアドレスは下位14ビットのみが有効です。
; 全ビットを使うときは、NSTWRT(0171H/MAIN)を使います。
;
; @param[in]    HL  VRAMアドレス
; @note 変更レジスタ AF
;;
    .globl _SETWRT

;;
; @brief CALPAT (0084H/MAIN)
; スプライトジェネレータテーブルの開始アドレスを獲得します。
;
; @param[in]    A   スプライト番号
; @return       HL  アドレス
; @note 変更レジスタ AF,DE,HL
;;
    .globl _CALPAT

;;
; @brief CALATR (0087H/MAIN)
; スプライトアトリビュートテーブルの開始アドレスを獲得します。
;
; @param[in]    A   スプライト番号
; @return       HL  アドレス
; @note 変更レジスタ AF,DE,HL
;;
    .globl _CALATR

;;
; @brief GSPSIZ (008AH/MAIN)
; 現在のスプライトサイズを獲得します。
;
; @return   A   スプライトサイズ（バイト数）
; @return   CF  16×16のサイズの場合のみセットし、それ以外のときはリセット
; @note 変更レジスタ AF
;;
    .globl _GSPSIZ

;;
; @brief RDVDP (013EH/MAIN)
; VDPのステータスレジスタを読み出します。
; このルーチンはTMS9918に対するものです。
;
; @return   A     読み込んだ値
; @note 変更レジスタ A
;;
    .globl _RDVDP
