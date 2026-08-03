    .z80
    .module vdp
    .area _CODE
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /nekoSys.inc/
.include /msx1BiosVdp.inc/

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
_SETRD:

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
_SETWRT:
    PUSH HL
.ifdef VRAM_8000
        RES 6,H ; VRAM 0x8000～0xBFFF
        SET 7,H
.else
        SET 6,H ; VRAM 0x4000～0x7FFF
        RES 7,H
.endif
        ; VDPのポインタを更新
        DI
        LD (VRAM_ACCESS_POINTER),HL
        ; メモ）VDPのレジスタを設定するときに割り込みを無効にし、その後有効にしているので
        EI
    POP HL
    RET

;;
; @brief RDVDP (013EH/MAIN)
; VDPのステータスレジスタを読み出します。
; このルーチンはTMS9918に対するものです。
;
; @return   A     読み込んだ値
; @note 変更レジスタ A
;;
_RDVDP:
    PUSH HL
        LD HL,#STATFL
        LD A,(HL)
        RES 7,(HL)
    POP HL
    RET
