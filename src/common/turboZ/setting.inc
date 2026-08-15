; 定義すると描画のフレームスキップが有効になる
.define ENABLE_FRAME_SKIP /1/

; 定義するとSCCが有効になる
.define ENABLE_SCC /1/

; VRAMの開始アドレス
.define VRAM_4000 /0x4000/
;.define VRAM_8000 /0x8000/

; ROMのアドレス
.define ROM_ADDRESS /0x4000/

.ifdef VRAM_8000
VRAM .equ 0x8000    ; VRAMアドレス
.else
VRAM .equ 0x4000    ; VRAMアドレス
.endif

.ifdef VRAM_8000
; VRAMはメインメモリにある
.define MAIN_MEMORY_VRAM /1/
.else
; VRAMはバンクメモリ0にある
.define BANK_MEMORY_VRAM /1/
.endif

.ifdef BANK_MEMORY_VRAM
    ; バンクメモリ0
    _SPRITE_ERACE_LIST .equ 0x0000
.endif
