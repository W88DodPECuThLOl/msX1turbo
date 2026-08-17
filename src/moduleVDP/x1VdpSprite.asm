    .z80
    .module sprite
    .area _CODE
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /x1VdpSprite.inc/

; 軽量なスプライト
; .define LIGHT_SPRITE /1/

    .globl _LINE_ADDRESS_TABLE

    .globl _SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS

    ; スプライト消去用
    .globl _eraseList

.ifdef BANK_MEMORY_VRAM
.else
    .globl _SPRITE_ERACE_LIST0
    .globl _SPRITE_ERACE_LIST1
.endif

;;
; @brief 消去リスト生成用のマクロ
;
; 消去リストは↓みたいな感じで１個につき8バイト。
; スプライト32個で256バイトとなる。
; +0 LD E,nn    ; 0x1E ((x >> 3) or (x >> 3)+4)
; +2 LD HL,nnmm ; 0x21 (u16)lineAdr
; +5 CALL xxxx  ; 0xCD _erase16x8 or _erase8x8
; +8
;
; @param[in]    v   書き込む値
; @note 変更レジスタ HL
;;
    .macro GENERATE_ERACE v
        LD (HL),v
.ifdef BANK_MEMORY_VRAM
        INC L ; 256バイトアライメントされていると仮定
.else
        INC HL
.endif
    .endm

    .macro GENERATE_ERACE_SKIP v
.ifdef BANK_MEMORY_VRAM
        INC L ; 256バイトアライメントされていると仮定
.else
        INC HL
.endif
    .endm

;;
; @brief 消去リスト初期化
;
; @param[in]    HL  消去リストの開始アドレス
; @note 変更レジスタ AF,BC,HL
;;
initEraceList:
.ifdef BANK_MEMORY_VRAM
    ; バンクメモリ0へ切り替え
    LD BC,#0x0B00
    OUT (C),C
.endif
    LD B,#32
initEraceList_LOOP:
        GENERATE_ERACE #0x1E
        GENERATE_ERACE_SKIP #0x00
        GENERATE_ERACE #0x21
        GENERATE_ERACE_SKIP #0x00
        GENERATE_ERACE_SKIP #0x00
        GENERATE_ERACE #0xCD
        GENERATE_ERACE_SKIP #0x00
        GENERATE_ERACE_SKIP #0x00
    DJNZ initEraceList_LOOP
.ifdef BANK_MEMORY_VRAM
    ; メインメモリへ切り替え
    LD BC,#0x0B00
    LD A,#0x10
    OUT (C),A
.endif
    RET

;------------------------------------------------
; 8x8スプライト描画
;------------------------------------------------

;;
; 8x1のシフト描画
; ・8x8サイズのスプライト描画用
; HL : line address
; IY : パターンデータアドレス
; IXL : Xオフセット
; IXH : シフト回数
;;
    .macro draw8x1_shift_next ?rand
    LD A,IXL
    ADD (HL)
    LD C,A
    INC HL
    LD A,#0x00
    ADC (HL)
    INC HL
    LD D,A

    ; パターンデータ取得
    LD E,0(IY)
    INC IYL

    ; パターンデータをシフト
    ; A : 左側
    ; E : 右側
    XOR A
    LD B,IXH ; シフト回数
draw8x1_shift_loop'rand:
    SLA E
    RLA
    DJNZ draw8x1_shift_loop'rand

    ; 描画
    ; A : 左側のパターンデータ
    ; E : 右側のパターンデータ
    LD B,D
.ifdef LIGHT_SPRITE
    ;IN D,(C)
    ;OR D
    OUT (C),A
    INC BC
    ;IN A,(C)
    ;OR E
    OUT (C),E
.else
    IN D,(C)
    OR D
    OUT (C),A
    INC BC
    IN A,(C)
    OR E
    OUT (C),A
.endif
    .endm

;;
; シフト無しの8x8サイズのスプライト描画
; HL : line address
;;
draw8x8_no_shift:
    EX DE,HL
draw8x1_pattern_address:
    LD HL,#0x0000
    LD IXL,#8
draw8x1_next:
        ; BC = (DE) + offset
        LD A,(DE)
        INC DE
draw8x1_offset:
        ADD A,#0x00
        LD C,A
        LD A,(DE)   ; 7
        ADC #0x00   ; 7
        LD B,A      ; 4
        INC DE      ; 6   24

        ; 描画
.ifdef LIGHT_SPRITE
        INC B
        OUTI
        ;LD A,(HL)
        ;INC L
        ;OUT (C),A
.else
        IN A,(C)
        OR (HL)
        INC L
        OUT (C),A
.endif
    DEC IXL ; 8
    JP NZ,draw8x1_next ; 10
    RET

;;
; 8x8描画
; HL : line address
;  B : シフトしないかどうか
;;
_draw8x8:
    LD A,B
    OR A
    JR Z,draw8x8_no_shift
draw8x8_shift:
draw8x1_shift_pattern_address:
    LD IY,#0x0000
draw8x1_shift_offset:
draw8x1_shift_count:
    LD IX,#0x0000
    draw8x1_shift_next
    draw8x1_shift_next
    draw8x1_shift_next
    draw8x1_shift_next
    draw8x1_shift_next
    draw8x1_shift_next
    draw8x1_shift_next
    draw8x1_shift_next
    RET

_renderSpriteMode1_size8x8:
    ; パターン
    PUSH HL
        INC L
        INC L
        LD L,(HL) ; patternNo
        LD H,#0x00
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL
        LD DE,(_SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS)
        ADD HL,DE
        LD (draw8x1_pattern_address + 1),HL
        LD (draw8x1_shift_pattern_address + 2),HL
    POP HL
    ; X
    PUSH HL
        INC L
        LD A,(HL) ; x
        LD B,A
        RRCA
        RRCA
        RRCA
        AND #0x1F ; x >> 3
        INC L
        INC L
        BIT 7,(HL) ; EC
        JR NZ,renderSpriteMode1_size8x8_SKIP1
        ADD #4 ; メモ）ECがビットが立ってないので+4しておく
renderSpriteMode1_size8x8_SKIP1:
        ;LD E,A ; E : offset
        LD (draw8x1_offset + 1),A
        LD (draw8x1_shift_offset + 2),A

        ; *eraseList++ = 0x1E; LD E,nn
        ; *eraseList++ = (x >> 3); or (x >> 3)+4
        LD HL,(_eraseList)
        GENERATE_ERACE #0x1E
        GENERATE_ERACE A
        LD (_eraseList),HL

        LD A,B
        AND #0x07
        LD B,A

        LD A,#8
        SUB B
        LD (draw8x1_shift_count + 3),A
    POP HL

    ; HL : LINE_ADDRESS_TABLE + y
    LD L,(HL) ; y
    LD H,#0x00
    ADD HL,HL
    LD DE,#_LINE_ADDRESS_TABLE
    ADD HL,DE

    ; *eraseList++ = 0x21; *((u16*)eraseList) = (u16)lineAdr; eraseList += 2;
    EX DE,HL
        LD HL,(_eraseList)
        GENERATE_ERACE_SKIP #0x21
        GENERATE_ERACE E
        GENERATE_ERACE D
        GENERATE_ERACE_SKIP #0xCD
        ; *((u16*)eraseList) = (u16)erase16x8;
        LD A,B
        OR A
        JR Z,renderSpriteMode1_erase8x8
renderSpriteMode1_erase16x8:
        GENERATE_ERACE #_erase16x8
        LD (HL),#_erase16x8 >> 8
        JR renderSpriteMode1_SKIP3
        ; 
renderSpriteMode1_erase8x8:
        GENERATE_ERACE #_erase8x8
        LD (HL),#_erase8x8 >> 8
renderSpriteMode1_SKIP3:
        INC HL
        LD (_eraseList),HL
    EX DE,HL

    ; HL : line address
    ;  B : シフトしないかどうか
    JP _draw8x8

;------------------------------------------------
; 16x16スプライト描画
;------------------------------------------------

; HL : パターンアドレス
; E : offset
.macro draw16x1_next_mac_sp ?rand
    POP BC  ; 10
    LD A,C  ; 4
    ADD A,E ; 4  offset
    LD C,A  ; 4
    JR NC,draw16x1_SKIP'rand ; 7/12
    INC B   ; 4
draw16x1_SKIP'rand: ; 34

.ifdef LIGHT_SPRITE
    LD A,(HL)
    INC L
    OUT (C),A
    INC BC

    EXX
        LD A,(HL)
        INC L
    EXX
    OUT (C),A
.else
    IN A,(C)
    OR (HL)
    INC L
    OUT (C),A
    INC BC

    IN A,(C)
    EXX
        OR (HL)
        INC L
    EXX
    OUT (C),A
.endif
.endm

.macro draw16x1_next_mac_sp_last ?rand
    POP BC
    LD A,C
    ADD A,E ; offset
    LD C,A
    JR NC,draw16x1_SKIP'rand
    INC B
draw16x1_SKIP'rand:

.ifdef LIGHT_SPRITE
    LD A,(HL)
    OUT (C),A
    INC BC

    EXX
        LD A,(HL)
    EXX
    OUT (C),A
.else
    IN A,(C)
    OR (HL)
    OUT (C),A
    INC BC

    IN A,(C)
    EXX
        OR (HL)
    EXX
    OUT (C),A
.endif
.endm

; 16x16描画
; ・16x16サイズのスプライト描画用
; HL : line address
; DE : pattern address
_draw16x16:
    LD IX,#0x0000
    ADD IX,SP
    LD SP,HL

    EX DE,HL
    LD A,L
    ADD #16
    EXX
        LD L,A
    EXX
    LD A,H
    EXX
        LD H,A
        LD A,E ; draw16x1_offset
    EXX

    LD E,A ; offset
draw16x1_next:
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp
    draw16x1_next_mac_sp_last
    LD SP,IX
    RET


.macro draw16x1_shift_sub_mac shift_count ?rand
    EXX
    LD B,#8
draw16x1_shift_LOOP'rand:
    EXX
        POP HL
        XOR A
        LD D,A
        ADD HL,DE
        LD C,L
        LD B,H

        ; 右シフト
        ; H L A
        LD H,0(IX)
        LD L,16(IX)
        ;INC IX
        INC IXL
        .rept shift_count
            SRL H
            RR L
            RRA
        .endm
        ; VRAMへ書き込み
.ifdef LIGHT_SPRITE
        OUT (C),H
        INC BC
        OUT (C),L
        INC BC
        OUT (C),A
.else
        LD D,A
        IN A,(C)
        OR H
        OUT (C),A
        INC BC
        IN A,(C)
        OR L
        OUT (C),A
        INC BC
        IN A,(C)
        OR D
        OUT (C),A
.endif
        ; -----

        POP HL
        XOR A
        LD D,A
        ADD HL,DE
        LD C,L
        LD B,H

        ; 右シフト
        ; H L A
        LD H,0(IX)
        LD L,16(IX)
        ;INC IX
        INC IXL
        .rept shift_count
            SRL H
            RR L
            RRA
        .endm
.ifdef LIGHT_SPRITE
        ; VRAMへ書き込み
        OUT (C),H
        INC BC
        OUT (C),L
        INC BC
        OUT (C),A
.else
        LD D,A
        ; VRAMへ書き込み
        IN A,(C)
        OR H
        OUT (C),A
        INC BC
        IN A,(C)
        OR L
        OUT (C),A
        INC BC
        IN A,(C)
        OR D
        OUT (C),A
.endif
    EXX
    DJNZ draw16x1_shift_LOOP'rand
;    EXX
.endm

.macro draw16x1_left_shift_sub_mac shift_count ?rand
    EXX
    LD B,#8
draw16x1_shift_LOOP'rand:
    EXX
        POP HL
        XOR A
        LD D,A
        ADD HL,DE
        LD C,L
        LD B,H

        ; 左シフト
        ; A H L
        LD H,0(IX)
        LD L,16(IX)
        ;INC IX
        INC IXL
        .rept shift_count
            SLA L
            RL H
            RLA
        .endm
.ifdef LIGHT_SPRITE
        ; VRAMへ書き込み
        OUT (C),A
        INC BC
        OUT (C),H
        INC BC
        OUT (C),L
.else
        ; VRAMへ書き込み
        IN D,(C)
        OR D
        OUT (C),A
        INC BC
        IN A,(C)
        OR H
        OUT (C),A
        INC BC
        IN A,(C)
        OR L
        OUT (C),A
.endif

        ; ------

        POP HL
        XOR A
        LD D,A
        ADD HL,DE
        LD C,L
        LD B,H

        ; 左シフト
        ; A H L
        LD H,0(IX)
        LD L,16(IX)
        ;INC IX ; 10
        INC IXL ; 8
        .rept shift_count
            SLA L
            RL H
            RLA
        .endm

.ifdef LIGHT_SPRITE
        ; VRAMへ書き込み
        OUT (C),A
        INC BC
        OUT (C),H
        INC BC
        OUT (C),L
.else
        ; VRAMへ書き込み
        IN D,(C)
        OR D
        OUT (C),A
        INC BC
        IN A,(C)
        OR H
        OUT (C),A
        INC BC
        IN A,(C)
        OR L
        OUT (C),A
.endif
    EXX
    DJNZ draw16x1_shift_LOOP'rand
;    EXX
.endm

; 16x1のシフト描画
; ・16x16サイズのスプライト描画用
; HL : line address
; DE : pattern address
.macro draw16x16_right_shift shift_count
    PUSH DE
    POP IX
    EXX
        LD HL,#0x0000
        ADD HL,SP

        LD A,E ; E : draw16x1_offset
    EXX
    LD E,A

    LD SP,HL

        draw16x1_shift_sub_mac shift_count

;   EXX
        LD SP,HL
    EXX
    RET
.endm

; 16x1のシフト描画
; ・16x16サイズのスプライト描画用
; HL : line address
; DE : pattern address
.macro draw16x16_left_shift shift_count
;    PUSH IX
        PUSH DE
        POP IX
        EXX
            LD HL,#0x0000
            ADD HL,SP

            LD A,E ; E : draw16x1_offset
        EXX
        LD E,A


        LD SP,HL

            draw16x1_left_shift_sub_mac shift_count

;        EXX
            LD SP,HL
        EXX
;    POP IX

    RET
.endm


_draw16x16_shift0:
    POP HL
    JP _draw16x16
_draw16x16_shift1:
    POP HL
    draw16x16_right_shift 1
_draw16x16_shift2:
    POP HL
    draw16x16_right_shift 2
_draw16x16_shift3:
    POP HL
    draw16x16_right_shift 3
_draw16x16_shift4:
    POP HL
    draw16x16_right_shift 4
_draw16x16_shift5: ; left
    POP HL
    draw16x16_left_shift 3
_draw16x16_shift6: ; left
    POP HL
    draw16x16_left_shift 2
_draw16x16_shift7: ; left
    POP HL
    draw16x16_left_shift 1















.macro draw16x1_shift_sub_no_overflow shift_count ?rand
    EXX
    LD B,#8
draw16x1_shift_LOOP'rand:
    EXX
;        POP HL ; 10
;        XOR A
;        LD D,A
;        ADD HL,DE
;        LD C,L
;        LD B,H

        POP BC ; 10
        LD A,C ; 4
        ADD E  ; 4
        LD C,A ; 4
        XOR A  ; 4

        ; 右シフト
        ; H L A
        LD H,0(IX)
        LD L,16(IX)
        ;INC IX
        INC IXL
        .rept shift_count
            SRL H
            RR L
            RRA
        .endm
.ifdef LIGHT_SPRITE
        ; VRAMへ書き込み
        OUT (C),H
        INC C
        OUT (C),L
        INC C
        OUT (C),A
.else
        LD D,A
        ; VRAMへ書き込み
        IN A,(C)
        OR H
        OUT (C),A
        INC C
        IN A,(C)
        OR L
        OUT (C),A
        INC C
        IN A,(C)
        OR D
        OUT (C),A
.endif
        ; -----

;        POP HL
;        XOR A
;        LD D,A
;        ADD HL,DE
;        LD C,L
;        LD B,H

        POP BC ; 10
        LD A,C ; 4
        ADD E  ; 4
        LD C,A ; 4
        XOR A  ; 4

        ; 右シフト
        ; H L A
        LD H,0(IX)
        LD L,16(IX)
        ;INC IX
        INC IXL
        .rept shift_count
            SRL H
            RR L
            RRA
        .endm
.ifdef LIGHT_SPRITE
        ; VRAMへ書き込み
        OUT (C),H
        INC C
        OUT (C),L
        INC C
        OUT (C),A
.else
        LD D,A
        ; VRAMへ書き込み
        IN A,(C)
        OR H
        OUT (C),A
        INC C
        IN A,(C)
        OR L
        OUT (C),A
        INC C
        IN A,(C)
        OR D
        OUT (C),A
.endif
    EXX
    DJNZ draw16x1_shift_LOOP'rand
;    EXX
.endm

.macro draw16x1_left_shift_sub_no_overflow shift_count ?rand
    EXX
    LD B,#8
draw16x1_shift_LOOP'rand:
    EXX
;        POP HL
;        XOR A
;        LD D,A
;        ADD HL,DE
;        LD C,L
;        LD B,H

        POP BC ; 10
        LD A,C ; 4
        ADD E  ; 4
        LD C,A ; 4
        XOR A  ; 4

       ; 左シフト
        ; A H L
        LD H,0(IX)
        LD L,16(IX)
        ;INC IX
        INC IXL
        .rept shift_count
            SLA L
            RL H
            RLA
        .endm

.ifdef LIGHT_SPRITE
        ; VRAMへ書き込み
        OUT (C),A
        INC C
        OUT (C),H
        INC C
        OUT (C),L
.else
        ; VRAMへ書き込み
        IN D,(C)
        OR D
        OUT (C),A
        INC C
        IN A,(C)
        OR H
        OUT (C),A
        INC C
        IN A,(C)
        OR L
        OUT (C),A
.endif

        ; ------

;        POP HL
;        XOR A
;        LD D,A
;        ADD HL,DE
;        LD C,L
;        LD B,H

        POP BC ; 10
        LD A,C ; 4
        ADD E  ; 4
        LD C,A ; 4
        XOR A  ; 4

        ; 左シフト
        ; A H L
        LD H,0(IX)
        LD L,16(IX)
        ;INC IX
        INC IXL
        .rept shift_count
            SLA L
            RL H
            RLA
        .endm
.ifdef LIGHT_SPRITE
        ; VRAMへ書き込み
        OUT (C),A
        INC C
        OUT (C),H
        INC C
        OUT (C),L
.else
        ; VRAMへ書き込み
        IN D,(C)
        OR D
        OUT (C),A
        INC C
        IN A,(C)
        OR H
        OUT (C),A
        INC C
        IN A,(C)
        OR L
        OUT (C),A
.endif
    EXX
    DJNZ draw16x1_shift_LOOP'rand
;    EXX
.endm

; 16x1のシフト描画
; ・16x16サイズのスプライト描画用
; HL : line address
; DE : pattern address
.macro draw16x16_right_shift_no_overflow shift_count
        PUSH DE
        POP IX
        EXX
            LD HL,#0x0000
            ADD HL,SP
            LD A,E ; E : draw16x1_offset
        EXX
        LD E,A

        LD SP,HL
            draw16x1_shift_sub_no_overflow shift_count
            LD SP,HL
        EXX
    RET
.endm

; 16x1のシフト描画
; ・16x16サイズのスプライト描画用
; HL : line address
; DE : pattern address
.macro draw16x16_left_shift_no_overflow shift_count
        PUSH DE
        POP IX
        EXX
            LD HL,#0x0000
            ADD HL,SP
            LD A,E ; E : draw16x1_offset
        EXX
        LD E,A

        LD SP,HL
            draw16x1_left_shift_sub_no_overflow shift_count
            LD SP,HL
        EXX
    RET
.endm








_draw16x16_shift0_no_overflow:
    POP HL
    JP _draw16x16
_draw16x16_shift1_no_overflow:
    POP HL
    draw16x16_right_shift_no_overflow 1
_draw16x16_shift2_no_overflow:
    POP HL
    draw16x16_right_shift_no_overflow 2
_draw16x16_shift3_no_overflow:
    POP HL
    draw16x16_right_shift_no_overflow 3
_draw16x16_shift4_no_overflow:
    POP HL
    draw16x16_right_shift_no_overflow 4
_draw16x16_shift5_no_overflow: ; left
    POP HL
    draw16x16_left_shift_no_overflow 3
_draw16x16_shift6_no_overflow: ; left
    POP HL
    draw16x16_left_shift_no_overflow 2
_draw16x16_shift7_no_overflow: ; left
    POP HL
    draw16x16_left_shift_no_overflow 1




; HL : 描画するスプライトアトリビュートのアドレス
; DE : 描画するスプライトアトリビュートのアドレス + 3
renderSpriteMode1_size16x16:
    LD C,L
    LD B,H
    ;PUSH HL
        ;CALL _setShiftCountAndOffset16x16
        INC L
        LD A,(HL) ; x
        RRCA
        RRCA
        RRCA
        AND #0x1F ; x >> 3
        INC L
        INC L
        BIT 7,(HL) ; EC
        JR NZ,setShiftCountAndOffset16x16_SKIP1
        ADD #4
setShiftCountAndOffset16x16_SKIP1:
        EXX
            LD E,A ; E : draw16x1_offset
        EXX
    ;POP HL

    ; HL : LINE_ADDRESS_TABLE + y
    LD L,C
    ;LD H,B
    LD L,(HL) ; y
    LD H,#0x00
    ADD HL,HL
    LD DE,#_LINE_ADDRESS_TABLE
    ADD HL,DE
    INC C
    PUSH HL

    ; 消去リスト生成
    ; LD E,(x >> 3) / LD E,(x >> 3) + 4
    ; LD HL,#line address
    ; CALL _erase24x16 / CALL _erase16x16
    EX DE,HL
        LD HL,(_eraseList)
        GENERATE_ERACE #0x1E
        EXX
            LD A,E ; draw16x1_offset
        EXX
        GENERATE_ERACE A

        GENERATE_ERACE_SKIP #0x21
        GENERATE_ERACE E
        GENERATE_ERACE D
        GENERATE_ERACE_SKIP #0xCD
        LD A,(BC) ; x
        AND #0x07
        JR Z,S0
        ; shift
        GENERATE_ERACE #_erase24x16
        LD (HL),#(_erase24x16 >> 8)
        JP EXIT
        ; 16x16
S0:
        GENERATE_ERACE #_erase16x16
        LD (HL),#(_erase16x16 >> 8)
EXIT:
        INC HL
        LD (_eraseList),HL
    EX DE,HL

    ; DE : _SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS + (spriteAttributeTableAddress[2] & 0xFC) << 3)
        ; spriteAttributeTableAddress[2] & 0xFC) << 3
        INC C
        LD A,(BC)
        AND #0xFC
        LD H,#0
        LD L,A
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL
        LD DE,(_SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS)
        ADD HL,DE
        
        EX DE,HL
;    POP HL

    DEC C
    LD A,(BC) ; x
    AND #0x07
    ADD A
    LD HL,#tbl
    ADD L
    LD L,A
    JR NC,SKIP
    INC H
SKIP:
    LD A,(HL)
    INC HL
    LD H,(HL)
    LD L,A
    JP (HL)
tbl:
    .DW _draw16x16_shift0
    .DW _draw16x16_shift1
    .DW _draw16x16_shift2
    .DW _draw16x16_shift3
    .DW _draw16x16_shift4
    .DW _draw16x16_shift5
    .DW _draw16x16_shift6
    .DW _draw16x16_shift7

renderSpriteMode1_no_overflow_size16x16:
    LD C,L
    LD B,H
    ;PUSH HL
        ;CALL _setShiftCountAndOffset16x16
        INC L
        LD A,(HL) ; x
        RRCA
        RRCA
        RRCA
        AND #0x1F ; x >> 3
        INC L
        INC L
        BIT 7,(HL) ; EC
        JR NZ,renderSpriteMode1_no_overflow_size16x16_SKIP1
        ADD #4
renderSpriteMode1_no_overflow_size16x16_SKIP1:
        EXX
            LD E,A ; E : draw16x1_offset
        EXX
    ;POP HL

    ; HL : LINE_ADDRESS_TABLE + y
    LD L,C
    ;LD H,B
    LD L,(HL) ; y
    LD H,#0x00
    ADD HL,HL
    LD DE,#_LINE_ADDRESS_TABLE
    ADD HL,DE
    INC C
    PUSH HL

    ; 消去リスト生成
    ; LD E,(x >> 3) / LD E,(x >> 3) + 4
    ; LD HL,#line address
    ; CALL _erase24x16 / CALL _erase16x16
    EX DE,HL
        LD HL,(_eraseList)
        GENERATE_ERACE #0x1E
        EXX
            LD A,E ; draw16x1_offset
        EXX
        GENERATE_ERACE A

        GENERATE_ERACE_SKIP #0x21
        GENERATE_ERACE E
        GENERATE_ERACE D
        GENERATE_ERACE_SKIP #0xCD
        LD A,(BC) ; x
        AND #0x07
        JR Z,S1
        ; shift
        GENERATE_ERACE #erase24x16_no_overflow
        LD (HL),#(erase24x16_no_overflow >> 8)
        JP EXIT1
        ; 16x16
S1:
        GENERATE_ERACE #_erase16x16
        LD (HL),#(_erase16x16 >> 8)
EXIT1:
        INC HL ; 最後はちゃんと加算すること
        LD (_eraseList),HL
    EX DE,HL

    ; DE : _SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS + (spriteAttributeTableAddress[2] & 0xFC) << 3)
        ; spriteAttributeTableAddress[2] & 0xFC) << 3
        INC C
        LD A,(BC)
        AND #0xFC
        LD H,#0
        LD L,A
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL
        LD DE,(_SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS)
        ADD HL,DE
        
        EX DE,HL
;    POP HL

    DEC C
    LD A,(BC) ; x
    AND #0x07
    ADD A
    LD HL,#tbl_no_overflow
    ADD L
    LD L,A
    JR NC,SKIP1
    INC H
SKIP1:
    LD A,(HL)
    INC HL
    LD H,(HL)
    LD L,A
    JP (HL)
tbl_no_overflow:
    .DW _draw16x16_shift0
    .DW _draw16x16_shift1_no_overflow
    .DW _draw16x16_shift2_no_overflow
    .DW _draw16x16_shift3_no_overflow
    .DW _draw16x16_shift4_no_overflow
    .DW _draw16x16_shift5_no_overflow
    .DW _draw16x16_shift6_no_overflow
    .DW _draw16x16_shift7_no_overflow

;------------------------------------------------
; スプライト消去
;------------------------------------------------

.macro ERASE_1BYTE_SP ?rand
    POP HL    ; 10
    ADD HL,DE ; 11
    LD C,L    ; 4
    LD B,H    ; 4
              ; 29

    OUT (C),D
.endm

.macro ERASE_2BYTE_SP ?rand
    POP HL    ; 10
    ADD HL,DE ; 11
    LD C,L    ; 4
    LD B,H    ; 4
              ; 29

    OUT (C),D
    INC BC
    OUT (C),D
.endm

.macro ERASE_3BYTE_SP ?rand
    POP HL    ; 10
    ADD HL,DE ; 11
    LD C,L    ; 4
    LD B,H    ; 4
              ; 29

    OUT (C),D
    INC BC
    OUT (C),D
    INC BC
    OUT (C),D
.endm

.macro ERASE_3BYTE_SP_no_overflow ?rand
;    POP HL    ; 10
;    ADD HL,DE ; 11
;    LD C,L    ; 4
;    LD B,H    ; 4
;              ; 29
    POP BC    ; 10
    LD A,C    ; 4
    ADD E     ; 4
    LD C,A    ; 4
              ; 22

    OUT (C),D
    INC C
    OUT (C),D
    INC C
    OUT (C),D
.endm


; 8x8消去
; ・8x8サイズのスプライト描画用
; HL ; line address pointer
; E  : offset
_erase8x8:
;    EXX
;    LD HL,#0x0000
;    ADD HL,SP
;    EXX
        LD SP,HL
        .rept 8
        ERASE_1BYTE_SP
        .endm
    EXX
    LD SP,HL
    EXX
    RET

; 16x8消去
; ・8x8サイズのスプライト描画用
; HL ; line address pointer
; E  : offset
_erase16x8:
;    EXX
;    LD HL,#0x0000
;    ADD HL,SP
;    EXX
        LD SP,HL
        .rept 8
        ERASE_2BYTE_SP
        .endm
    EXX
    LD SP,HL
    EXX
    RET

; 16x16消去
; ・16x16サイズのスプライト描画用
; HL ; line address pointer
; E  : offset
_erase16x16:
;    EXX
;    LD HL,#0x0000
;    ADD HL,SP
;    EXX
        LD SP,HL
        .rept 16
        ERASE_2BYTE_SP
        .endm
    EXX
    LD SP,HL
    EXX
    RET

; 24x16消去
; ・16x16サイズのスプライト描画用
; HL : line address pointer
; E  : offset
_erase24x16:
;    EXX
;    LD HL,#0x0000
;    ADD HL,SP
;    EXX
        LD SP,HL
        .rept 16
        ERASE_3BYTE_SP
        .endm
    EXX      ; 4
    LD SP,HL ; 6
    EXX      ; 4
    RET

erase24x16_no_overflow:
;    EXX
;    LD HL,#0x0000
;    ADD HL,SP
;    EXX
        LD SP,HL
        .rept 16
        ERASE_3BYTE_SP_no_overflow
        .endm
    EXX      ; 4
    LD SP,HL ; 6
    EXX      ; 4
    RET











































;;
; @brief スプライト消去
;;
eraseSprite0:
    LD D,#0x00
    EXX
    LD HL,#0xFFFE
    ADD HL,SP
    EXX
    JP _SPRITE_ERACE_LIST0

eraseSprite1:
    LD D,#0x00
    EXX
    LD HL,#0xFFFE
    ADD HL,SP
    EXX
    JP _SPRITE_ERACE_LIST1

;;
;;
renderSprite:
    LD A,(RG5SAV) ; VDP R#5
    LD L,#0x00
    SRL A
    RR L
.ifdef VRAM_8000
    ADD A,#0x80 ; VRAM 0x8000
.else
    ADD A,#0x40 ; VRAM 0x4000
.endif
    LD H,A

    LD E,L
    LD D,H
    INC E
    INC E
    INC E

    LD A,(RG1SAV) ; VDP R#1
    BIT	1,A
    JR Z,renderSprite8x8
2000000$:
        LD A,(HL)   ; y
        CP #208
        RET Z
        CP #255
        JR Z,2000003$ ; NO_OVERFLOW_BC
        CP #191+1
        JR NC,2000001$

        ;桁上り無し
        ; 0-31      255,0-30
        ; 55-79     54-78
        ; 103-135   102-134
        ; 159-175   158-174

        CP #30+1
        JR C,2000003$ ; NO_OVERFLOW_BC
        CP #54+1
        JR C,2000004$ ; OVERFLOW_BC
        CP #78+1
        JR C,2000003$ ; NO_OVERFLOW_BC
        CP #102+1
        JR C,2000004$ ; OVERFLOW_BC
        CP #134+1
        JR C,2000003$ ; NO_OVERFLOW_BC
        CP #158+1
        JR C,2000004$ ; OVERFLOW_BC
        CP #174+1
        JR C,2000003$ ; NO_OVERFLOW_BC
2000004$: ; OVERFLOW_BC
        LD A,(DE) ; 色が0なら描画しない
        OR A
        JR Z,2000001$

        PUSH DE
        PUSH HL
            CALL renderSpriteMode1_size16x16
        POP HL
        POP DE
        JR 2000001$

2000003$: ; NO_OVERFLOW_BC
        LD A,(DE) ; 色が0なら描画しない
        OR A
        JR Z,2000001$

        PUSH DE
        PUSH HL
            CALL renderSpriteMode1_no_overflow_size16x16
        POP HL
        POP DE
2000001$:
        LD A,E ; 4
        ADD #4 ; 7
        LD E,A ; 4
        LD A,L
        ADD #4
        LD L,A
        CP #(0x04*32)
        JR NZ,2000000$
    RET

    ; 8x8
renderSprite8x8:
        LD A,(HL) ; Y座標
        CP #208
        RET Z ; Y座標が208だったらスプライト描画終わり
        CP #255 ; 255は一番上
        JR Z,renderSprite8x8_SKIP1
        CP #191+1
        JR NC,renderSprite8x8_SKIP2
renderSprite8x8_SKIP1:
        PUSH HL
        CALL _renderSpriteMode1_size8x8
        POP HL

renderSprite8x8_SKIP2:
        LD A,L
        ADD #4
        LD L,A
        CP #(0x04*32)
        JR NZ,renderSprite8x8
    RET
