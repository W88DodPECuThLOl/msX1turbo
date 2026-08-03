;;
; @brief VDP書き込みのIN/OUT命令のフック処理
; 「RST 0x00」+1バイトの「機能番号」で呼び出す。
;;
    .globl _IN_OUT_HOOK

;;
; @brief OUTI命令のフック処理
; OUTI
;   DEC B
;   OUT (C),(HL)
;   INC HL
;;
    .globl _BLOCK_IN_OUT_HOOK
