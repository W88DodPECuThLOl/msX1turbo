; NekoSys
CTC_RESET       .equ 0x0300
CRTC_WIDTH40    .equ 0x0303
CRTC_WIDTH80    .equ 0x0306
WRITE_OUTPUT    .equ 0x0309
x1_psgReset     .equ 0x030C
readBankMemory0Byte .equ 0x030F
writeBankMemory0Byte .equ 0x0312
copy8KiBFromEmm0ToMem6000 .equ 0x0315
copy8KiBFromEmm0ToMem8000 .equ 0x0318
copy8KiBFromEmm0ToMemA000 .equ 0x031B
copy8KiBFromEmm0ToMem4000 .equ 0x031E
reserve1  .equ 0x0321
reserve2  .equ 0x0324
reserve3  .equ 0x0327
reserve4  .equ 0x032A
reserve5  .equ 0x032D
reserve6  .equ 0x0330
SUB_CPU_SEND    .equ 0x0333
SUB_CPU_RECEIVE .equ 0x0336

; -----------------------------------
; msX1turbo
; ・VRAMの開始アドレス 0x8000用
; ・バンクメモリ未使用
; -----------------------------------
; module lnk
.ifdef VRAM_8000
_CLRSPR .equ 0xC000
_FILVRM .equ 0xC035
_INIGRP .equ 0xC051
_INIT32 .equ 0xC0AB
_LDIRMV .equ 0xC0FF
_LDIRVM .equ 0xC10E
_RDVRM .equ 0xC11F
VRAM_ACCESS_POINTER .equ 0xC12D
_WRTVDP .equ 0xC131
_WRTVRM .equ 0xC173
IN_HOOK .equ 0xC181
OUT_HOOK .equ 0xC19A
IN_OUT_HOOK_OUT_0x98_A .equ 0xC1FE
IN_OUT_HOOK_OUT_0x99_A .equ 0xC209
IN_OUT_HOOK_IN_A_0x99 .equ 0xC239
_BLOCK_IN_OUT_HOOK .equ 0xC242

_vdpInit .equ 0xC2FB
_vdpRender .equ 0xC338
.endif

; -----------------------------------
; msX1turboZ
; ・VRAMの開始アドレス 0x4000用
; ・バンクメモリ使用
; -----------------------------------
; module lnk
.ifdef VRAM_4000
_CLRSPR .equ 0xC000
_FILVRM .equ 0xC050
_INIGRP .equ 0xC079
_INIT32 .equ 0xC0E1
_LDIRMV .equ 0xC135
_LDIRVM .equ 0xC17B
_RDVRM .equ 0xC1BD
VRAM_ACCESS_POINTER .equ 0xC1D6
_WRTVDP .equ 0xC1DA
_WRTVRM .equ 0xC21C
IN_HOOK .equ 0xC235
OUT_HOOK .equ 0xC262
IN_OUT_HOOK_OUT_0x98_A .equ 0xC2D8
IN_OUT_HOOK_OUT_0x99_A .equ 0xC318
IN_OUT_HOOK_IN_A_0x99 .equ 0xC348
_BLOCK_IN_OUT_HOOK .equ 0xC351

_vdpInit .equ 0xC418
_vdpRender .equ 0xC461
.endif
