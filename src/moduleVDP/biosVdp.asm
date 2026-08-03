; ・主にバンクメモリへアクセスする為のサブルーチンを配置する

    .z80
    .module biosVdp
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /ioHook.inc/
.include /biosVdp.inc/

    .globl _vdpWriteHook

    .area _CODE

; Neko Sys Work

; 連続して読み書きするときのポインタ
VRAM_ACCESS_POINTER:
.ifdef VRAM_8000
    .DW 0x8000
.else
    .DW 0x4000
.endif

; スプライトパターンジェネレータテーブル
_SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS:
.ifdef VRAM_8000
    .DW 0x8000
.else
    .DW 0x4000
.endif

;;
; @brief WRTVDP (0047H/MAIN)
; VDPのレジスタに値を書き込みます。
;
; @param[in]    C  VDPのレジスタ番号（レジスタ番号は0～23、32～46）
; @param[in]    B  書き込む値
; @note 変更レジスタ AF,BC
;;
_WRTVDP:
    DI
    PUSH BC
    PUSH HL
        LD A,C
        AND #7      ; レジスタ番号を0～7までに
        ; MSX WORK(RG0SAV～RG7SAV)に書き込む値を保存
        LD C,A
        ADD #0xDF  ; #RG0SAV ; 0xF3DF
        LD L,A
        LD H,#0xF3 ; #(RG0SAV >> 8)
        LD (HL),B
        ;
        LD A,C
        CP #6
        CALL Z,WRTVDP_R6
WRTVDP_EXIT:
    POP HL
    POP BC
    ; メモ）VDPのレジスタを設定するときに割り込みを無効にし、その後有効にしているので
    EI
    RET

    ; R#6への書き込み
WRTVDP_R6:
    LD A,B
calcSpritePatternGeneratorTableAddress:
    ; スプライトパターンジェネレータテーブル
    ; VRAM + ((u16)(vdp[6] & 0x1F) << 11)
	AND #0x1F
	ADD A
	ADD A
	ADD A
.ifdef VRAM_8000
	ADD	#0x80 ; VRAM 0x8000～0xBFFF
.else
	ADD	#0x40 ; VRAM 0x4000～0x7FFF
.endif
    LD (_SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS+1),A
    RET


;;
; @brief RDVRM (004AH/MAIN)
; VRAMの指定したアドレスの内容を読み出します。
; ただし、このルーチンはTMS9918(MSX1のVDP)に対するもので、
; VRAMのアドレスは下位14ビットのみが有効です。
; 全ビットを使うときは、NRDVRM(0174H/MAIN)を使います。
;
; @param[in]    HL  VRAMのアドレス
; @return       A   読み出した値
; @note 変更レジスタ AF
;;
_RDVRM:
    PUSH HL
.ifdef VRAM_8000
        RES 6,H ; VRAM 0x8000～0xBFFF
        SET 7,H
.else
        SET 6,H ; VRAM 0x4000～0x7FFF
        RES 7,H
.endif
        DI
.ifdef BANK_MEMORY_VRAM
        PUSH BC
        ; バンクメモリ0
        LD BC,#0x0B00
        OUT (C),C
.endif

        LD A,(HL)

        ; VDPのポインタを更新しておく
        INC HL
        LD (VRAM_ACCESS_POINTER),HL
.ifdef BANK_MEMORY_VRAM
        ; メインメモリ
        LD L,#0x10
        OUT (C),L
        POP BC
.endif
        ; メモ）VDPのレジスタを設定するときに割り込みを無効にし、その後有効にしているので
        EI
    POP HL
    RET

;;
; @brief WRTVRM (004DH/MAIN)
; VRAMにデータを書き込みます。
; ただし、このルーチンはTMS9918に対するもので、
; VRAMのアドレスは下位14ビットのみが有効です。
; 全ビットを使うときは、NVRVRM(0177H/MAIN)を使います。
;
; @param[in]    HL  VRAMのアドレス
; @param[in]    A   書き込むデータ
; @note 変更レジスタ AF
;;
_WRTVRM:
    PUSH AF ; メモ）AFレジスタ変わっていない
    PUSH HL
.ifdef VRAM_8000
        RES 6,H ; VRAM 0x8000～0xBFFF
        SET 7,H
.else
        SET 6,H ; VRAM 0x4000～0x7FFF
        RES 7,H
.endif
        DI
.ifdef BANK_MEMORY_VRAM
        PUSH BC
        ; バンクメモリ0
        LD BC,#0x0B00
        OUT (C),C
.endif

        LD (HL),A

        ; VDPのポインタを更新しておく
        ; @todo 必要？
        ;INC HL
        ;LD (VRAM_ACCESS_POINTER),HL
.if 0
        ; 書き換えの監視
        PUSH BC
        PUSH DE
        PUSH IX
        PUSH IY
            CALL _vdpWriteHook
        POP IY
        POP IX
        POP DE
        POP BC
.endif

.ifdef BANK_MEMORY_VRAM
        ; メインメモリ
        LD L,#0x10
        OUT (C),L
        POP BC
.endif
        ; メモ）VDPのレジスタを設定するときに割り込みを無効にし、その後有効にしているので
        EI
    POP HL
    POP AF
    RET

;;
; @brief FILVRM (0056H/MAIN)
; VRAMの指定領域を同一のデータで埋めます。
; ただし、このルーチンはTMS9918に対するもので、
; VRAMのアドレスは下位14ビットのみが有効です。
; 全ビットを使うときは、BIGFIL(016BH/MAIN)を使います。
;
; @param[in]    HL  書き込みを開始するVRAMアドレス
; @param[in]    BC  書き込む領域の長さ(バイト数)
; @param[in]    A   書き込む値
; @note 変更レジスタ AF,BC
;;
_FILVRM:
    PUSH AF ; メモ）AFレジスタ変わっていない
    PUSH DE ; メモ）DEレジスタ変わっていない
    PUSH HL ; メモ）HLレジスタ変わっていない
.ifdef VRAM_8000
        RES 6,H ; VRAM 0x8000～0xBFFF
        SET 7,H
.else
        SET 6,H ; VRAM 0x4000～0x7FFF
        RES 7,H
.endif

.ifdef BANK_MEMORY_VRAM
        PUSH BC ; メモ）スタックがバンクメモリ範囲外にあること
            ; バンクメモリ0
            LD BC,#0x0B00
            DI
            OUT (C),C
        POP BC

        LD (HL),A
        ; @todo VDPのポインタ更新
        DEC BC
        LD A,B
        OR C
        JR Z,FILVRM_EXIT2
        LD D,H
        LD E,L
        INC DE
        LDIR
        ; VDPのポインタを更新しておく
        LD (VRAM_ACCESS_POINTER),HL

FILVRM_EXIT2:
        ; メインメモリ
        LD BC,#0x0B00
        LD A,#0x10
        OUT (C),A
        EI
.else
        LD (HL),A
        ; @todo VDPのポインタ更新
        DEC BC
        LD A,B
        OR C
        JR Z,FILVRM_EXIT
        EI
        LD D,H
        LD E,L
        INC DE
        LDIR

        ; VDPのポインタを更新しておく
        DI
        LD (VRAM_ACCESS_POINTER),HL
FILVRM_EXIT:
        ; メモ）VDPのレジスタを設定するときに割り込みを無効にし、その後有効にしているので
        EI
.endif
    POP HL
    POP DE
    POP AF
    RET

;;
; @brief LDIRMV (0059H/MAIN)
; VRAMからメモリへデータをブロック転送します。
;
; @param[in]    HL  転送元のVRAMアドレス(指定するVRAMアドレスは全ビットが有効)
; @param[in]    DE  転送先のRAMアドレス
; @param[in]    BC  転送する長さ(バイト数)
; @note 変更レジスタ すべて
;;
_LDIRMV:
    PUSH HL ; HLレジスタ変わっていない
.ifdef VRAM_8000
        RES 6,H ; VRAM 0x8000～0xBFFF
        SET 7,H
.else
        SET 6,H ; VRAM 0x4000～0x7FFF
        RES 7,H
.endif

.ifdef BANK_MEMORY_VRAM
        LD A,D
        CP #0x80
        JR NC,LDIRMV_NOT_OVERLAP
; 転送先がバンクメモリと重なっている
LDIRMV_OVERLAP:
        EX AF,AF'
            PUSH AF
            LD A,#0x10
        EX AF,AF'
LDIRMV_OVERLAP_LOOP:
            ; バンクメモリから読み込み
            PUSH BC
                ; バンクメモリへ切り替え
                LD BC,#0x0B00
                DI
                OUT (C),C

                ; バンクメモリから読み込む
                LD A,(HL)
                INC HL

                ; メインメモリへ切り替え
                EX AF,AF'
                    OUT (C),A ; A:0x10
                    EI
                EX AF,AF'
            POP BC
            ; 書き込み
            LD (DE),A
            INC DE
        DEC BC
        LD A,B
        OR C
        JR NZ,LDIRMV_OVERLAP_LOOP
        EX AF,AF'
            POP AF
        EX AF,AF'

        ; VDPのポインタを更新しておく
        DI
        LD (VRAM_ACCESS_POINTER),HL
        EI

        JR LDIRMV_EXIT

; 転送先がバンクメモリと重なっていない
LDIRMV_NOT_OVERLAP:
        PUSH BC
        LD BC,#0x0B00
        DI
        OUT (C),C
        POP BC

        LDIR

        ; VDPの読み込みポインタを更新しておく
        LD (VRAM_ACCESS_POINTER),HL

        LD BC,#0x0B00
        LD A,#0x10
        OUT (C),A
        EI
.else
        EI
        LDIR
        ; VDPの読み込みポインタを更新しておく
        DI
        LD (VRAM_ACCESS_POINTER),HL
        EI
.endif
LDIRMV_EXIT:
    POP HL
    ; A  : 0x00
    ; BC : 0x0000
    RET

;;
; @brief LDIRVM (005CH/MAIN)
; メモリからVRAMへデータをブロック転送します。
;
; @param[in]    HL  転送元のRAMアドレス
; @param[in]    DE	転送先のVRAMアドレス(指定するVRAMアドレスは全ビットが有効)
; @param[in]    BC	転送する長さ(単位はバイト)
; @note 変更レジスタ すべて
;;
_LDIRVM:
    PUSH DE ; 転送先のVRAMアドレス
.ifdef VRAM_8000
        RES 6,D ; VRAM 0x8000～0xBFFF
        SET 7,D
.else
        SET 6,D ; VRAM 0x4000～0x7FFF
        RES 7,D
.endif


.ifdef BANK_MEMORY_VRAM
        LD A,H
        CP #0x80
        JR NC,LDIRVM_NOT_OVERLAP
; 転送元がバンクメモリと重なっている
LDIRVM_OVERLAP:
LDIRVM_OVERLAP_LOOP:
        PUSH BC
            LD A,(HL)
            INC HL

            LD BC,#0x0B00
            DI
            OUT (C),C

            LD (DE),A
            INC DE

            LD A,#0x10
            OUT (C),A
            EI
        POP BC
        DEC BC
        LD A,B
        OR C
        JR NZ,LDIRVM_OVERLAP_LOOP

        ; VDPのポインタを更新しておく
        DI
        LD (VRAM_ACCESS_POINTER),DE
        EI
        EX DE,HL
        JR LDIRVM_EXIT
; 転送元がバンクメモリと重なっていない
LDIRVM_NOT_OVERLAP:
        PUSH BC
        LD BC,#0x0B00
        DI
        OUT (C),C
        POP BC

        LDIR

        LD BC,#0x0B00
        LD A,#0x10
        OUT (C),A

        ; VDPのポインタを更新しておく
        LD (VRAM_ACCESS_POINTER),DE
        EI
        EX DE,HL
.else
        ; メモ）VDPのレジスタを設定後、割り込みを許可しているので
        EI
        LDIR

        ; VDPのポインタを更新しておく
        DI
        LD (VRAM_ACCESS_POINTER),DE
        EI
        EX DE,HL
.endif
LDIRVM_EXIT:
    POP HL
    ; HL: 転送先のVRAMアドレス
    ; DE: 転送元のRAMアドレス + 転送する長さ(単位はバイト)
    RET

;;
; @brief CLRSPR (0069H/MAIN)
; すべてのスプライトを次のように初期化します。
;  スプライトパターン	ヌル
;  スプライト番号	スプライト面番号
;  スプライトカラー	前景色
;  スプライトの垂直位置(SCREEN 0～3)	209
;  スプライトの垂直位置(SCREEN 4～12)	217
;
; @note 変更レジスタ すべて
;;
_CLRSPR:
    ;-----------------------------------------------
    ; スプライトパターンをクリアする
    ;-----------------------------------------------

    ; アドレスを再計算
    LD A,(RG6SAV)
    CALL calcSpritePatternGeneratorTableAddress
.ifdef BANK_MEMORY_VRAM
    ; バンクメモリ0
    LD BC,#0x0B00
    DI
    OUT (C),C
.endif
        LD HL,(_SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS)
        LD E,L
        LD D,H
        INC DE
        LD BC,#0x0800-1
        LD (HL),#0
        LDIR
.ifdef BANK_MEMORY_VRAM
    ; メインメモリ
    LD A,#0x10
    OUT (C),A
    EI
.endif

    ;-----------------------------------------------
    ; スプライトアトリビュートの初期化
    ;-----------------------------------------------

    ; HL : spriteAttributeTableAddress = VRAM + ((u16)vdp[5] << 7);
    LD A,(RG5SAV)
    LD L,#0x00
    SRL A
    RR L
.ifdef VRAM_8000
    ADD #0x80 ; VRAM 0x8000～0xBFFF
.else
    ADD #0x40 ; VRAM 0x4000～0x7FFF
.endif
    LD H,A

.ifdef BANK_MEMORY_VRAM
    ; バンクメモリ0
    LD BC,#0x0B00
    DI
    OUT (C),C
.endif

    LD A,(FORCLR) ; 前景色
    LD C,A

    ; スプライトのサイズでスプライト面番号のステップを決める
    LD A,(RG1SAV)
    AND #0x02
    LD D,#4 ; 16x16の時
    JR NZ,CLRSPR_SKIP1
    LD D,#1 ; 8x8の時
CLRSPR_SKIP1:

    XOR A
    LD B,#32
CLRSPR_LOOP:
        LD (HL),#209    ; Y座標
        INC L
        ; X座標は設定しない
        INC L
        LD (HL),A       ; スプライト面番号
        INC L
        ADD D
        LD (HL),C       ; 色
        INC L
    DJNZ CLRSPR_LOOP

.ifdef BANK_MEMORY_VRAM
    ; メインメモリ
    LD A,#0x10
    OUT (C),A
.endif

    ; メモ）VDPのレジスタを設定するときに割り込みを無効にし、その後有効にしているので
    EI
    RET


; @param[in]    HL  パターンネームテーブルのアドレス
setPatternNameTable:
    SRL H
    SRL H
    LD B,H ; 書き込む値
    LD C,#0x02 ; VDPのレジスタ番号
    JP _WRTVDP
; @param[in]    HL  カラーテーブルのアドレス
setColorTable:
    SLA L
    RL H
    SLA L
    RL H
    LD B,H ; 書き込む値
    LD C,#0x03 ; VDPのレジスタ番号
    JP _WRTVDP
; @param[in]    HL  パターンジェネレータテーブルのアドレス
setPatternGeneratorTable:
    SRL H
    SRL H
    SRL H
    LD B,H
    LD C,#0x04 ; VDPのレジスタ番号
    JP _WRTVDP
; @param[in]    HL  スプライトアトリビュートテーブルのアドレス
setSpriteAttributeTable:
    .rept 7
    SRL H
    RR L
    .endm
    LD B,L
    LD C,#0x05 ; VDPのレジスタ番号
    JP _WRTVDP
; @param[in]    HL  スプライトジェネレータテーブルのアドレス
setSpriteGeneretorTable:
    SRL H
    SRL H
    SRL H
    LD B,H
    LD C,#0x06 ; VDPのレジスタ番号
    JP _WRTVDP

;;
; @brief INIT32 (006FH/MAIN)
; 画面をTEXT2モード（SCREEN 1、32×24）に初期化します。
; このルーチンはパレットを初期化しません。
; パレットの初期化が必要であれば、このルーチンを実行した後、INIPLT（0141H/SUB）を実行します。
; コール手順
;【T32NAM(F3BDH)】	パターンネームテーブルのアドレス
;【T32COL(F3BFH)】	カラーテーブルのアドレス
;【T32CGP(F3C1H)】	パターンジェネレータテーブルのアドレス
;【T32ATR(F3C3H)】	スプライトアトリビュートテーブルのアドレス
;【T32PAT(F3C5H)】	スプライトジェネレータテーブルのアドレス
;【LINL32(F3AFH)】	1行の幅（WIDTH文によって設定する値）
;
; @note 変更レジスタ    すべて
;;
_INIT32:
    ; パターンネームテーブルのアドレス
    LD HL,(T32NAM)
    LD (NAMBAS),HL
    CALL setPatternNameTable
    ; カラーテーブルのアドレス
    LD HL,(T32COL)
    CALL setColorTable
    ; パターンジェネレータテーブルのアドレス
    LD HL,(T32CGP)
    LD (CGPBAS),HL
    CALL setPatternGeneratorTable
    ; スプライトアトリビュートテーブルのアドレス
    LD HL,(T32ATR)
    LD (ATRBAS),HL
    CALL setSpriteAttributeTable
    ; スプライトジェネレータテーブルのアドレス
    LD HL,(T32PAT)
    LD (PATBAS),HL
    CALL setSpriteGeneretorTable
    ; 1行の幅（WIDTH文によって設定する値）
    LD A,(LINL32)
    LD (LINLEN),A
    ; カーソル位置
    LD A,#1
    LD (CSRY),A
    LD (CSRX),A
    ; モード設定
    LD A,(RG0SAV)
    AND #0x01
    LD B,A
    LD C,#0x00
    CALL _WRTVDP
    LD A,(RG1SAV)
    AND #0xE7
    LD B,A
    LD C,#0x01
    CALL _WRTVDP
    ; スプライトの初期化
    JP _CLRSPR

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
