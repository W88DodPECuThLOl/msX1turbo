    .z80
    .module renderGraphic
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /renderGraphic.inc/

.ifdef USE_DMA
    .globl _x1_dmaFillVRAM
.endif

    .area _CODE

;;
; スクリーンモード
;;
screenMode:
    .DB 0

;;
; @brief VDP R#2の値
; ・変更されたかどうかの判定用に使用している
;;
preVDP_R2:
    .DB 0xFF

;;
; @brief GRAHIC1モードのセットアップ
;
; @note 変更レジスタ すべて
;;
_setupGraphic1:
    LD HL,#screenMode
    LD (HL),#0x01

.ifdef USE_DMA
    LD A,#0x20 + 0x07 ; PCG 白
    PUSH AF
    INC SP
    LD DE,#40*24
    LD HL,#0x2000
    CALL _x1_dmaFillVRAM
.else
    LD L,#0x20 + 0x07 ; PCG 白
    LD BC,#0x2000
    LD DE,#40*24
setupGraphic1_LOOP:
        OUT (C),L
        INC BC
    DEC DE
    LD A,D
    OR E
    JR NZ,setupGraphic1_LOOP
.endif
    ;JP  _waku

;;
; @brief 枠部分を黒色に
;
; @note MSXは32x24でX1は40x25。
;       MSXの画面は中央に寄せて描画するので、
;       余っている周りの部分を黒色の枠にする。
;;
_waku:
    LD BC,#0x2000
    LD L,#24
waku_LOOP0:
        .rept 4
        .DB 0xED,0x71 ; OUT (C),0
        INC BC
        .endm
        LD A,C
        ADD #32
        LD C,A
        JR NC,waku_SKIP0
        INC B
waku_SKIP0:
        .rept 4
        .DB 0xED,0x71 ; OUT (C),0
        INC BC
        .endm
    DEC L
    JR NZ,waku_LOOP0
    ; 一番下の行
    LD L,#40
waku_LOOP1:
        .DB 0xED,0x71 ; OUT (C),0
        INC BC
    DEC L
    JR NZ,waku_LOOP1
	RET

;;
; @brief GRAHIC2モードのセットアップ
;
; @note 変更レジスタ すべて
;;
_setupGraphic2:
    LD HL,#screenMode
    LD (HL),#0x02

.ifdef USE_DMA
    LD A,#0x20 + 0x01 ; PCG 青
    PUSH AF
    INC SP
    LD DE,#40*8
    LD HL,#0x2000
    CALL _x1_dmaFillVRAM

    LD A,#0x20 + 0x02 ; PCG 赤
    PUSH AF
    INC SP
    LD DE,#40*8
    LD HL,#0x2000 + 40*8
    CALL _x1_dmaFillVRAM

    LD A,#0x20 + 0x04 ; PCG 緑
    PUSH AF
    INC SP
    LD DE,#40*8
    LD HL,#0x2000 + 40*16
    CALL _x1_dmaFillVRAM
.else
    LD L,#0x21 ; PCG 青
    LD BC,#0x2000
    LD DE,#40*8
setupGraphic2_LOOP1:
        OUT (C),L
        INC BC
    DEC DE
    LD A,D
    OR E
    JR NZ,setupGraphic2_LOOP1

    LD L,#0x22 ; PCG 赤
    LD DE,#40*8
setupGraphic2_LOOP2:
        OUT (C),L
        INC BC
    DEC DE
    LD A,D
    OR E
    JR NZ,setupGraphic2_LOOP2

    LD L,#0x24 ; PCG 緑
    LD DE,#40*8
setupGraphic2_LOOP3:
        OUT (C),L
        INC BC
    DEC DE
    LD A,D
    OR E
    JR NZ,setupGraphic2_LOOP3
.endif
    JP _waku

;;
; @brief メモリからVRAMへ転送するDMAコマンド
; ・32x24の矩形を40x24の矩形の中央部分(4～35)へ転送する
;;
dmaCommandMemToVRAM:
    .DB 0x65    ; 0110 0101    WR0
                ;       +----- 0:B->A 1:A->B
    .DB 0x1F    ; ブロックレングスL
    .DB 0x00    ; ブロックレングスH
    .DB 0x14    ; 0001 0100    WR1 PORT A
                ;   || +------ 0:メモリー 1:I/O
                ;   ++-------- 00:-- 01:++ 10/11:固定
    .DB 0x18    ; 0001 1000    WR2 PORT B
                ;   || +------ 0:メモリー 1:I/O
                ;   ++-------- 00:-- 01:++ 10/11:固定
    .DB 0x9A    ; 1001 1010    WR5 READYはH有効
                ;    | +------ 0:READY L 1:READY H
                ;    +-------- 0:CE 1:CE/WAIT
dmaCommand:
                            ; 1行分8バイト
    .DB 0x1D,0x00,0x00,0xAD ; PORT A アドレス 転送元メモリ
    .DW 0x3004              ; PORT B アドレス 転送先IO
    .DB 0xCF,0x87           ; LOAD, ENABLE DMA
    .DB 0x1D,0x00,0x00,0xAD ; 0xCD:バーストモード 0xAD:連続モード
    .DW 0x302C ; 0x3004+40*1
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3054 ; 0x3004+40*2
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*3
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*4
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*5
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*6
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*7
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*8
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*9
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*10
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*11
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*12
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*13
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*14
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*15
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*16
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*17
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*18
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*19
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*20
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3004+40*21
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0xAD
    .DW 0x3374 ; 0x3004+40*22
    .DB 0xCF,0x87
    .DB 0x1D,0x00,0x00,0x85 ; 0x85 バイトモード、PORT Bの下位8ビットのみ設定
    .DB 0x9C   ; 0x339C 0x3004+40*23
    .DB 0xCF,0x87

;;
; @brief GRAPHIC1の描画
;
; @note 変更レジスタ すべて
;;
_renderGraphic:
    LD A,(#RG2SAV) ; VDP R#2
	LD HL,#preVDP_R2
	CP (HL)
	JP Z,copyNameTable
	LD (HL),A
    ; ネームテーブルのアドレスが変わっていたら
    ; DMAコマンドを書き換える
    AND #0x7F
    ADD	A
    ADD	A
.ifdef VRAM_8000
    ADD #0x80   ; VRAM 0x8000
.else
    ADD #0x40   ; VRAM 0x4000
.endif
    ; DMAコマンドを準備
    LD E,#0x00
    LD D,A
    ;CALL prepareDMACommand
    ;JP copyNameTable

;;
; DMAコマンドを準備する
; @param[in]    DE  ネームテーブルの開始アドレス
;;
prepareDMACommand:
    LD HL,#dmaCommand + 1
    LD B,#24
    LD C,#32
prepareDMACommand_LOOP:
        ; DMA PORT A ADDRESS
        LD (HL),E
        INC HL
        LD (HL),D
        ; DE+=32;
        LD A,E
        ADD C ; C: #32
        LD E,A
        JR NC,prepareDMACommand_SKIP1
        INC D
prepareDMACommand_SKIP1:
        ; HL+=7;
        LD A,L
        ADD #7
        LD L,A
        JR NC,prepareDMACommand_SKIP2
        INC H
prepareDMACommand_SKIP2:
    DJNZ prepareDMACommand_LOOP
    ;RET

;;
; @brief ネームテーブルをDMA転送する
;;
copyNameTable:
    LD HL,#dmaCommandMemToVRAM
    LD BC,#0x1f80 + 0x100
    OUTI
    .rept 8*24+4
        INC B
        OUTI
    .endm
    RET
