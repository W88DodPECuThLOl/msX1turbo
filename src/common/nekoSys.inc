; NekoSys
CTC_RESET       .equ 0x0300
CRTC_WIDTH40    .equ 0x0303
CRTC_WIDTH80    .equ 0x0306
WRITE_OUTPUT    .equ 0x0309
x1_psgReset     .equ 0x030C

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
_IN_OUT_HOOK .equ 0xC181
IN_OUT_HOOK_OUT_0x98_A .equ 0xC1FD
IN_OUT_HOOK_OUT_0x99_A .equ 0xC208
IN_OUT_HOOK_IN_A_0x99 .equ 0xC238
_BLOCK_IN_OUT_HOOK .equ 0xC241

_vdpInit .equ 0xC2FA
_vdpRender .equ 0xC337
.endif

; -----------------------------------
; msX1turboZ
; ・VRAMの開始アドレス 0x4000用
; ・バンクメモリ使用
; -----------------------------------
; module lnk
.ifdef VRAM_4000
_CLRSPR .equ 0xC000
_FILVRM .equ 0xC04A
_INIGRP .equ 0xC073
_INIT32 .equ 0xC0DB
_LDIRMV .equ 0xC12F
_LDIRVM .equ 0xC175
_RDVRM .equ 0xC1B7
VRAM_ACCESS_POINTER .equ 0xC1D0
_WRTVDP .equ 0xC1D4
_WRTVRM .equ 0xC216
_IN_OUT_HOOK .equ 0xC22F
IN_OUT_HOOK_OUT_0x98_A .equ 0xC2BF
IN_OUT_HOOK_OUT_0x99_A .equ 0xC2FF
IN_OUT_HOOK_IN_A_0x99 .equ 0xC32F
_BLOCK_IN_OUT_HOOK .equ 0xC338

_vdpInit .equ 0xC3FF
_vdpRender .equ 0xC448
.endif
