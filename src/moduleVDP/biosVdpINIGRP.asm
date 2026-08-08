    .z80
    .module biosVdp
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /ioHook.inc/
.include /biosVdp.inc/
.include /misc.inc/

    .area _CODE

;;
; @brief INIGRP (0072H/MAIN)
; 画面をGRAPHIC1モード（SCREEN 2）に初期化します。
; このルーチンはパレットを初期化しません。
; パレットの初期化が必要であれば、このルーチンを実行した後、
; INIPLT（0141H/SUB）を実行します。
; 
; @note 変更レジスタ すべて
;;
_INIGRP:
    ; パターンネームテーブルのアドレス
    LD HL,(GRPNAM)
    LD (NAMBAS),HL
    CALL setPatternNameTable
    ; カラーテーブルのアドレス
    LD HL,(GRPCOL)
    CALL setColorTable
    ; パターンジェネレータテーブルのアドレス
    LD HL,(GRPCGP)
    LD (CGPBAS),HL
    CALL setPatternGeneratorTable
    ; スプライトアトリビュートテーブルのアドレス
    LD HL,(GRPATR)
    LD (ATRBAS),HL
    CALL setSpriteAttributeTable
    ; スプライトジェネレータテーブルのアドレス
    LD HL,(GRPPAT)
    LD (PATBAS),HL
    CALL setSpriteGeneretorTable
    ; スクリーンモード
    LD A,#0x02
    LD (SCRMOD),A
    ; モード設定
    LD A,(RG0SAV)
    OR #0x02
    LD B,A
    LD C,#0x00
    CALL _WRTVDP
    LD A,(RG1SAV)
    AND #0xE7
    LD B,A
    LD C,#0x01
    CALL _WRTVDP
    ; スプライトの初期化
    CALL _CLRSPR
    ; パターンネームテーブルの初期化
    LD HL,(GRPNAM)
.ifdef VRAM_8000
    RES 6,H ; VRAM 0x8000～0xBFFF
    SET 7,H
.else
    SET 6,H ; VRAM 0x4000～0x7FFF
    RES 7,H
.endif
.ifdef BANK_MEMORY_VRAM
    LD BC,#0x0B00
    DI
    OUT (C),C
.endif
    LD BC,#0x0300
INIGRP_LOOP1:
        LD (HL),C
        INC HL
    INC C
    JR NZ,INIGRP_LOOP1
    DJNZ INIGRP_LOOP1
.ifdef BANK_MEMORY_VRAM
    LD BC,#0x0B00
    LD A,#0x10
    OUT (C),A
    EI
.endif
    RET
