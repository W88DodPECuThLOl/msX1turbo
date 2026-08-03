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
VRAM_ACCESS_POINTER .equ 0xC000
_WRTVDP .equ 0xC004
_RDVRM .equ 0xC027
_WRTVRM .equ 0xC035
_FILVRM .equ 0xC041
_LDIRMV .equ 0xC05D
_LDIRVM .equ 0xC06C
_CLRSPR .equ 0xC07D
_INIT32 .equ 0xC10D
_INIGRP .equ 0xC15E
_IN_OUT_HOOK .equ 0xC1B4
_BLOCK_IN_OUT_HOOK .equ 0xC230

_vdpInit .equ 0xC266
_vdpRender .equ 0xC29D
.endif

; -----------------------------------
; msX1turboZ
; ・VRAMの開始アドレス 0x4000用
; ・バンクメモリ使用
; -----------------------------------
; module lnk
.ifdef VRAM_4000
VRAM_ACCESS_POINTER .equ 0xC000
_WRTVDP .equ 0xC004
_RDVRM .equ 0xC027
_WRTVRM .equ 0xC040
_FILVRM .equ 0xC057
_LDIRMV .equ 0xC080
_LDIRVM .equ 0xC0C6
_CLRSPR .equ 0xC108
_INIT32 .equ 0xC1AD
_INIGRP .equ 0xC1FE
_IN_OUT_HOOK .equ 0xC262
_BLOCK_IN_OUT_HOOK .equ 0xC2F2

_vdpInit .equ 0xC336
_vdpRender .equ 0xC379
.endif
