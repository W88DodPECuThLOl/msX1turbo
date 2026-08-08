    .z80
    .module vdp
    .area _CODE
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /nekoSys.inc/
.include /msx1BiosVdp.inc/

;;
; @brief DISSCR (0041H/MAIN)
; 画面表示を禁止します。
; 
; @note 変更レジスタ AF,BC
;;
_DISSCR:
    LD A,(RG1SAV)
    AND #0xBF
    LD B,A
    LD C,#0x01
    JP _WRTVDP

;;
; @brief ENASCR (0044H/MAIN)
; 画面を表示します。
; 
; @note 変更レジスタ AF,BC
;;
_ENASCR:
    LD A,(RG1SAV)
    OR #0x40
    LD B,A
    LD C,#0x01
    JP _WRTVDP

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
; @brief CALPAT (0084H/MAIN)
; スプライトジェネレータテーブルの開始アドレスを獲得します。
;
; @param[in]    A   スプライト番号
; @return       HL  アドレス
; @note 変更レジスタ AF,DE,HL
;;
_CALPAT:
    LD DE,(PATBAS)
    LD L,A
    LD H,#0x00
    LD A,(RG1SAV)
    AND #0x02 ; SI  0:8x8  1:16x16
    JR Z,CALPAT8x8
CALPAT16x16:
    ADD HL,HL
    ADD HL,HL
CALPAT8x8:
    ADD HL,HL
    ADD HL,HL
    ADD HL,HL
    ADD HL,DE
    RET

;;
; @brief CALATR (0087H/MAIN)
; スプライトアトリビュートテーブルの開始アドレスを獲得します。
;
; @param[in]    A   スプライト番号
; @return       HL  アドレス
; @note 変更レジスタ AF,DE,HL
;;
_CALATR:
    ; HL=ATRBAS + A * 4
    LD DE,(ATRBAS)
    LD L,A
    LD H,#0x00
    ADD HL,HL
    ADD HL,HL
    ADD HL,DE
    RET

;;
; @brief GSPSIZ (008AH/MAIN)
; 現在のスプライトサイズを獲得します。
;
; @return   A   スプライトサイズ（バイト数）
; @return   CF  16×16のサイズの場合のみセットし、それ以外のときはリセット
; @note 変更レジスタ AF
;;
_GSPSIZ:
    LD A,(RG1SAV) ; 
    RRCA
    RRCA
    JR NC,GSPSIZ8x8
; 16x16
GSPSIZ16x16:
    LD A,#0x20
    RET
; 8x8
GSPSIZ8x8:
    LD A,#0x08
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
