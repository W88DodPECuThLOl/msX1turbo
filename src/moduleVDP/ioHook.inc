;;
; @brief VDP書き込みのIN/OUT命令のフック処理
; 「RST 0x00」+1バイトの「機能番号」で呼び出す。
;;
    .globl _IN_OUT_HOOK

;;
; @brief OUT (0x98),A命令のフック処理
;;
    .globl IN_OUT_HOOK_OUT_0x98_A

;;
; @brief OUT (0x99),A命令のフック処理
;;
    .globl IN_OUT_HOOK_OUT_0x99_A

;;
; @brief IN A,(0x99)命令のフック処理
;;
    .globl IN_OUT_HOOK_IN_A_0x99

;;
; @brief OUTI命令のフック処理
; OUTI
;   DEC B
;   OUT (C),(HL)
;   INC HL
;;
    .globl _BLOCK_IN_OUT_HOOK
