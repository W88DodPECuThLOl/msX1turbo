    .z80
    .module msx1Bios
    .area _CODE
    .allow_undocumented

    ; 8x8サイズのスプライト描画用
    .globl _setSpritePatternAddress8x8
    .globl _setShiftCountAndOffset8x8
    .globl _draw8x8
    ; 16x16サイズのスプライト描画用
;    .globl _setSpritePatternAddress16x16
    .globl _setShiftCountAndOffset16x16
    .globl _draw16x16
    .globl _draw16x16_shift

    ; スプライト消去用
;    .globl _setEraseOffset8x8
;    .globl _setEraseOffset16x16
    .globl _erase8x8
    .globl _erase16x8
    .globl _erase16x16
    .globl _erase24x16

;------------------------------------------------
; 8x8スプライト描画
;------------------------------------------------

; スプライトパターンアドレスを設定
; HL : スプライトパターンアドレス
; ・8x8サイズのスプライト描画用
_setSpritePatternAddress8x8:
    LD (draw8x1_pattern_address + 1),HL
    LD (draw8x1_shift_pattern_address + 1),HL
    RET    

_setShiftCountAndOffset8x8:
    LD A,L
    LD (draw8x1_shift_count + 1),A
    LD A,E
    LD (draw8x1_offset + 1),A
    LD (draw8x1_shift_offset + 1),A
    RET

; 8x1描画
; ・8x8サイズのスプライト描画用
; HL : line address
draw8x1:
    EX DE,HL
draw8x1_pattern_address:
    LD HL,#0x0000
draw8x1_next:
    ; BC = (DE) + offset
    LD A,(DE)
    INC E
draw8x1_offset:
    ADD A,#0x00
    LD C,A
    LD A,(DE)
    JR NC,draw8x1_SKIP
    INC A
draw8x1_SKIP:
    LD B,A
    INC DE

    IN A,(C)
    OR (HL)
    INC L
    OUT (C),A
    RET

; 8x1のシフト描画
; ・8x8サイズのスプライト描画用
; HL : line address
draw8x1_shift:
draw8x1_shift_pattern_address:
    LD DE,#0x0000

draw8x1_shift_next:
    LD C,(HL)
    INC L
    LD B,(HL)
    INC HL
    PUSH HL
draw8x1_shift_offset:
        LD HL,#0x0000
        ADD HL,BC
        LD C,L

        LD A,(DE)
        INC E
        LD L,A
        XOR A
draw8x1_shift_count:
        LD B,#0x00
draw8x1_shift_loop:
        SLA L
        RLA
        DJNZ draw8x1_shift_loop
        ;
        ;LD C,L
        LD B,H

        IN H,(C)
        OR H
        OUT (C),A
        INC BC
        IN A,(C)
        OR L
        OUT (C),A
    POP HL
    RET










;;;; 8x1のシフト描画
;;;; ・8x8サイズのスプライト描画用
;;;; HL : line address
;;;draw8x1_shift:
;;;    EXX
;;;draw8x1_shift_pattern_address:
;;;        LD DE,#0x0000
;;;draw8x1_shift_count:
;;;        LD L,#0x00
;;;draw8x1_shift_offset:
;;;        LD H,#0x00
;;;    EXX
;;;
;;;draw8x1_shift_next:
;;;    EXX
;;;        LD A,(DE)
;;;        INC E
;;;        LD C,A
;;;        XOR A
;;;        LD B,L
;;;draw8x1_shift_loop:
;;;        SLA C
;;;        RLA
;;;        DJNZ draw8x1_shift_loop
;;;        LD B,A
;;;    EXX
;;;
;;;    LD A,(HL)
;;;    INC L
;;;    EXX
;;;        ADD H
;;;    EXX
;;;    LD C,A
;;;    LD B,(HL)
;;;    JR NC,draw8x1_shift_SKIP
;;;    INC B
;;;draw8x1_shift_SKIP:
;;;    INC HL
;;;
;;;    IN A,(C)
;;;    EXX
;;;        OR B
;;;    EXX
;;;    OUT (C),A
;;;    INC BC
;;;    IN A,(C)
;;;    EXX
;;;        OR C
;;;    EXX
;;;    OUT (C),A
;;;    RET





; HL : スプライトパターンアドレス
;  E : シフトしないかどうか
_draw8x8:
    LD A,E
    OR A
    JR Z,draw8x8_shift
    CALL draw8x1_shift
    CALL draw8x1_shift_next
    CALL draw8x1_shift_next
    CALL draw8x1_shift_next
    CALL draw8x1_shift_next
    CALL draw8x1_shift_next
    CALL draw8x1_shift_next
    JP draw8x1_shift_next
draw8x8_shift:
    CALL draw8x1
    CALL draw8x1_next
    CALL draw8x1_next
    CALL draw8x1_next
    CALL draw8x1_next
    CALL draw8x1_next
    CALL draw8x1_next
    JP draw8x1_next

;------------------------------------------------
; 16x16スプライト描画
;------------------------------------------------

; スプライトパターンアドレスを設定
; ・16x16サイズのスプライト描画用
; HL : スプライトパターンアドレス
;_setSpritePatternAddress16x16:
;    LD (draw16x1_pattern_address + 1),HL
;    LD (draw16x1_shift_pattern_address + 1),HL
;    RET

_setShiftCountAndOffset16x16:
    LD A,L
    LD (draw16x1_shift_count + 1),A
    LD A,E
    LD (draw16x1_shift_offset + 1),A
    LD (draw16x1_offset + 1),A
    RET






.macro draw16x1_next_mac ?rand
    ; BC = (DE) + offset
    LD A,(DE)
    INC E
    EXX ; 4
        ADD A,D ; offset ; 4
    EXX ; 4

    LD C,A
    LD A,(DE)
    JR NC,draw16x1_SKIP'rand
    INC A
draw16x1_SKIP'rand:
    LD B,A
    INC DE

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
.endm










; 16x16描画
; ・16x16サイズのスプライト描画用
; HL : line address
; DE : pattern address
_draw16x16:
;draw16x1:
    EX DE,HL
;draw16x1_pattern_address:
;    LD HL,#0x0000
    LD A,L
    ADD #16
    EXX
draw16x1_offset:
        LD D,#0x00
        LD L,A
    EXX
    LD A,H
    EXX
        LD H,A
    EXX

draw16x1_next:
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    draw16x1_next_mac
    RET

;    ; BC = (DE) + offset
;    LD A,(DE)
;    INC E
;    EXX
;;draw16x1_offset:
;;        LD D,#0x00
;        ADD A,D ; 7
;    EXX
;
;    LD C,A
;    LD A,(DE)
;    JR NC,draw16x1_SKIP
;    INC A
;draw16x1_SKIP:
;    LD B,A
;    INC DE
;
;    IN A,(C)
;    OR (HL)
;    INC L
;    OUT (C),A
;    INC BC
;
;    IN A,(C)
;    EXX
;        OR (HL)
;        INC L
;    EXX
;    OUT (C),A
;    RET

; 16x1のシフト描画
; ・16x16サイズのスプライト描画用
; HL : line address
; DE : pattern address
draw16x1_shift:
;draw16x1_shift_pattern_address:
;    LD DE,#0x0000
    LD A,E
    ADD #16
    EXX
;        LD E,A
        LD L,A
draw16x1_shift_count:
        LD C,#0x00
    EXX
    LD A,D
;    JR NC,draw16x1_shift_SKIP2
;    INC A
;draw16x1_shift_SKIP2:
    EXX
;        LD D,A
        LD H,A
    EXX

;;;;;draw16x1_shift_next:
;;;;;    LD A,(HL)
;;;;;    INC L
;;;;;draw16x1_shift_offset:
;;;;;    ADD #0x00
;;;;;    LD C,A
;;;;;    LD B,(HL)
;;;;;    JR NC,draw16x1_shift_SKIP
;;;;;    INC B
;;;;;draw16x1_shift_SKIP:
;;;;;    INC HL
;;;;;
;;;;;    PUSH HL
;;;;;        ; 左側
;;;;;        LD A,(DE)
;;;;;        INC E
;;;;;        LD H,A
;;;;;        EXX
;;;;;            ; 右側
;;;;;            LD A,(DE)
;;;;;            INC E
;;;;;        EXX
;;;;;        LD L,A
;;;;;        XOR A
;;;;;        ; 0 L R
;;;;;        ; A H L
;;;;;
;;;;;        EX AF,AF'
;;;;;        LD A,B
;;;;;        EX AF,AF'
;;;;;draw16x1_shift_count:
;;;;;        LD B,#0x00
;;;;;draw16x1_shift_loop:
;;;;;        SLA L
;;;;;        RL H
;;;;;        RLA
;;;;;        DJNZ draw16x1_shift_loop
;;;;;        EXX
;;;;;            LD L,A
;;;;;        EXX
;;;;;
;;;;;        EX AF,AF'
;;;;;        LD B,A
;;;;;        EX AF,AF'
;;;;;
;;;;;        IN A,(C)
;;;;;        EXX
;;;;;            OR L
;;;;;        EXX
;;;;;        OUT (C),A
;;;;;        INC BC
;;;;;
;;;;;        IN A,(C)
;;;;;        OR H
;;;;;        OUT (C),A
;;;;;        INC BC
;;;;;
;;;;;        IN A,(C)
;;;;;        OR L
;;;;;        OUT (C),A
;;;;;    POP HL
;;;;;    RET

























draw16x1_shift_next:
    LD A,(HL)
    INC L
draw16x1_shift_offset:
    ADD #0x00
    LD C,A
    LD B,(HL)
    JR NC,draw16x1_shift_SKIP
    INC B
draw16x1_shift_SKIP:
    INC HL

;    PUSH HL
        ; 左側
        LD A,(DE)
        INC E
        EXX
            LD D,A
            ; 右側
            LD E,(HL)
            INC L

            ; L R 0
            ; D E A
            XOR A
            LD B,C
draw16x1_shift_loop:
;            SLA E
;            RL D
;            RLA
            SRL D
            RR E
            RRA
            DJNZ draw16x1_shift_loop
            LD B,A
        EXX

        IN A,(C)
        EXX
            OR D
        EXX
        OUT (C),A
        INC BC

        IN A,(C)
        EXX
            OR E
        EXX
        OUT (C),A
        INC BC

        IN A,(C)
        EXX
            OR B
        EXX
        OUT (C),A
;    POP HL
    RET






































;_draw16x16:
;    CALL draw16x1
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    CALL draw16x1_next
;    JP draw16x1_next

_draw16x16_shift:
    CALL draw16x1_shift
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    CALL draw16x1_shift_next
    JP draw16x1_shift_next

;------------------------------------------------
; スプライト消去
;------------------------------------------------

.macro ERASE_1BYTE ?rand
    ; BC = (HL) + DE
    LD A,(HL)
    INC L
    ADD A,E
    LD C,A
    LD B,(HL)
    JR NC,SKIP'rand
    INC B
SKIP'rand:
    INC HL

    .DB 0xED,0x71 ; OUT (C),F
.endm

.macro ERASE_2BYTE ?rand
    ; BC = (HL) + DE
    LD A,(HL)
    INC L
    ADD A,E
    LD C,A
    LD B,(HL)
    JR NC,SKIP'rand
    INC B
SKIP'rand:
    INC HL

    .DB 0xED,0x71 ; OUT (C),F
    INC BC
    .DB 0xED,0x71 ; OUT (C),F
.endm

.macro ERASE_3BYTE ?rand
    ; BC = (HL) + DE
    LD A,(HL)
    INC L
    ADD A,E
    LD C,A
    LD B,(HL)
    JR NC,SKIP'rand
    INC B
SKIP'rand:
    INC HL

    .DB 0xED,0x71 ; OUT (C),F
    INC BC
    .DB 0xED,0x71 ; OUT (C),F
    INC BC
    .DB 0xED,0x71 ; OUT (C),F
.endm

;_setEraseOffset8x8:
;    LD A,L
;    LD (erase8x8_offset + 1),A
;    LD (erase16x8_offset + 1),A
;    RET    

;_setEraseOffset16x16:
;    LD A,L
;    LD (erase16x8_offset + 1),A
;    LD (erase24x16_offset + 1),A
;    RET    

; 8x8消去
; ・8x8サイズのスプライト描画用
; HL ; line address pointer
; E  : offset
_erase8x8:
;erase8x8_offset:
;    LD E,#0x00
	.rept 8
    ERASE_1BYTE
	.endm
    RET

; 16x16消去
; ・16x16サイズのスプライト描画用
; HL ; line address pointer
; E  : offset
_erase16x16:
    CALL _erase16x8
    ;JP _erase16x8

; 16x8消去
; ・8x8サイズのスプライト描画用
; HL ; line address pointer
; E  : offset
_erase16x8:
;erase16x8_offset:
;    LD E,#0x00
	.rept 8
    ERASE_2BYTE
	.endm
    RET

; 24x16消去
; ・16x16サイズのスプライト描画用
; HL : line address pointer
; E  : offset
_erase24x16:
;    LD (erase24x16_offset + 1),A
;erase24x16_offset:
;    LD E,#0x00
	.rept 16
    ERASE_3BYTE
	.endm
    RET
