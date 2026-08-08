; ・主にバンクメモリへアクセスする為のサブルーチンを配置する

    .z80
    .module vdpModule
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /PCG.inc/
.include /renderGraphic.inc/
.include /x1VdpSprite.inc/
.include /misc.inc/

.ifdef USE_DMA
    ; catZ80lib
    .globl _x1_dmaFillVRAM
.endif

    ; C++
    .globl _pcg1
    .globl _pcg2

    ; export
    .globl _eraseList
    .globl _vdpInit
    .globl _vdpRender
    .globl _LINE_ADDRESS_TABLE
.ifdef BANK_MEMORY_VRAM
.else
    .globl _SPRITE_ERACE_LIST
.endif

_vdpInit:
    ; 200ラインモード、2本ラスタ/ドット、バンク0表示、バンク0アクセス
    ; PCG高速アクセス
    LD BC,#0x1FD0
    LD A,#0x22
    OUT (C),A
    ; グラフィックパレット
    LD BC,#0x1000
    LD A,#0xAA
    OUT (C),A
    INC B
    LD A,#0xCC
    OUT (C),A
    INC B
    LD A,#0xF0
    OUT (C),A
    ; プライオリティ
    INC B
    LD A,#0xFE
    OUT (C),A

    ; テキスト初期化
.ifdef USE_DMA
    ;x1_dmaFillVRAM(0x2000, 0xE000, 0x00); // TEXT & GCLS
    XOR A
    PUSH AF
    INC SP
    LD DE,#0xE000
    LD HL,#0x2000
    CALL _x1_dmaFillVRAM
.else
    LD BC,#0x2000
    LD DE,#0xE000
vdpInit_LOOP2:
        .DB 0xED,0x71 ; OUT (C),F
        INC BC
    DEC DE
    LD A,D
    OR E
    JR NZ,vdpInit_LOOP2
.endif
    CALL _setupGraphic1

    ; PCG初期化
    CALL _pcgInit

    ; 消去リスト初期化
    LD HL,#_SPRITE_ERACE_LIST
    CALL initEraceList
.ifdef BANK_MEMORY_VRAM
    ; バンクメモリ0へ切り替え
    LD BC,#0x0B00
    OUT (C),C
.endif
    ;eraseList = (u8*)SPRITE_ERACE_LIST;
    ;*eraseList = 0xC9; // RET
    LD A,#0xC9
    LD (_SPRITE_ERACE_LIST),A
.ifdef BANK_MEMORY_VRAM
    ; メインメモリへ切り替え
    LD BC,#0x0B00
    LD A,#0x10
    OUT (C),A
.endif

    RET

_vdpRender:
.ifdef BANK_MEMORY_VRAM
    ; バンクメモリ0へ切り替え
    LD BC,#0x0B00
    OUT (C),C

    CALL vdpRenderSub

    ; メインメモリへ切り替え
    LD BC,#0x0B00
    LD A,#0x10
    OUT (C),A
    RET
vdpRenderSub:
.endif

    ; 必要なら画面モードの切り替え
    CALL _IS_GRA1
    LD A,(screenMode)
    JR NZ,vdpRender_GRAPHIC2
    ; GRAPHIC1モード
vdpRender_GRAPHIC1:
    DEC A
    CALL NZ,_setupGraphic1
    ; GRAPHIC1用のPCG設定
    LD A,(PcgCharNo)
    INC A
    LD (PcgCharNo),A
    CALL _pcg1
    JR vdpRender_SKIP0

    ; GRAPHIC2モード
vdpRender_GRAPHIC2:
    CP #2
    CALL NZ,_setupGraphic2
    ; GRAPHIC2用のPCG設定
    LD A,(PcgCharNo)
    INC A
    LD (PcgCharNo),A
    CALL _pcg2
vdpRender_SKIP0:

.ifdef ENABLE_FRAME_SKIP
    ; フレームスキップ
    LD HL,#frameSkip
    RRC (HL) ; 15
    RET C
.endif

    ; テキスト描画
    CALL _renderGraphic
    ; スプライト消去
    CALL eraseSprite
    ; スプライト描画
    LD HL,#_SPRITE_ERACE_LIST
    LD (_eraseList),HL
    CALL renderSprite
    ; *eraseList = 0xC9; // RET
    LD HL,(_eraseList)
    LD (HL),#0xC9
    RET

.ifdef ENABLE_FRAME_SKIP
; フレームスキップ用のカウンタ
frameSkip:
.ifdef BANK_MEMORY_VRAM
    .DB 0x55
.else
    .DB 0x49
.endif
.endif

;    // グラフィックのY軸のアドレスの事前計算
;    for(int y = 0; y < 256 + 16; ++y) {
;        int yy = (1 + y) & 0xFF;
;        if(yy < 192) {
;            LINE_ADDRESS_TABLE[y] = 0xC000 | (((yy & 7) << 11) + (yy / 8) * 40);
;        } else {
;            yy = 200; // 非表示
;            LINE_ADDRESS_TABLE[y] = 0xC000 | (((yy & 7) << 11) + (yy / 8) * 40);
;        }
;    }
_LINE_ADDRESS_TABLE:
    .DW 0xC800 ; 0
    .DW 0xD000 ; 1
    .DW 0xD800 ; 2
    .DW 0xE000 ; 3
    .DW 0xE800 ; 4
    .DW 0xF000 ; 5
    .DW 0xF800 ; 6
    .DW 0xC028 ; 7
    .DW 0xC828 ; 8
    .DW 0xD028 ; 9
    .DW 0xD828 ; 10
    .DW 0xE028 ; 11
    .DW 0xE828 ; 12
    .DW 0xF028 ; 13
    .DW 0xF828 ; 14
    .DW 0xC050 ; 15
    .DW 0xC850 ; 16
    .DW 0xD050 ; 17
    .DW 0xD850 ; 18
    .DW 0xE050 ; 19
    .DW 0xE850 ; 20
    .DW 0xF050 ; 21
    .DW 0xF850 ; 22
    .DW 0xC078 ; 23
    .DW 0xC878 ; 24
    .DW 0xD078 ; 25
    .DW 0xD878 ; 26
    .DW 0xE078 ; 27
    .DW 0xE878 ; 28
    .DW 0xF078 ; 29
    .DW 0xF878 ; 30
    .DW 0xC0A0 ; 31
    .DW 0xC8A0 ; 32
    .DW 0xD0A0 ; 33
    .DW 0xD8A0 ; 34
    .DW 0xE0A0 ; 35
    .DW 0xE8A0 ; 36
    .DW 0xF0A0 ; 37
    .DW 0xF8A0 ; 38
    .DW 0xC0C8 ; 39
    .DW 0xC8C8 ; 40
    .DW 0xD0C8 ; 41
    .DW 0xD8C8 ; 42
    .DW 0xE0C8 ; 43
    .DW 0xE8C8 ; 44
    .DW 0xF0C8 ; 45
    .DW 0xF8C8 ; 46
    .DW 0xC0F0 ; 47
    .DW 0xC8F0 ; 48
    .DW 0xD0F0 ; 49
    .DW 0xD8F0 ; 50
    .DW 0xE0F0 ; 51
    .DW 0xE8F0 ; 52
    .DW 0xF0F0 ; 53
    .DW 0xF8F0 ; 54
    .DW 0xC118 ; 55
    .DW 0xC918 ; 56
    .DW 0xD118 ; 57
    .DW 0xD918 ; 58
    .DW 0xE118 ; 59
    .DW 0xE918 ; 60
    .DW 0xF118 ; 61
    .DW 0xF918 ; 62
    .DW 0xC140 ; 63
    .DW 0xC940 ; 64
    .DW 0xD140 ; 65
    .DW 0xD940 ; 66
    .DW 0xE140 ; 67
    .DW 0xE940 ; 68
    .DW 0xF140 ; 69
    .DW 0xF940 ; 70
    .DW 0xC168 ; 71
    .DW 0xC968 ; 72
    .DW 0xD168 ; 73
    .DW 0xD968 ; 74
    .DW 0xE168 ; 75
    .DW 0xE968 ; 76
    .DW 0xF168 ; 77
    .DW 0xF968 ; 78
    .DW 0xC190 ; 79
    .DW 0xC990 ; 80
    .DW 0xD190 ; 81
    .DW 0xD990 ; 82
    .DW 0xE190 ; 83
    .DW 0xE990 ; 84
    .DW 0xF190 ; 85
    .DW 0xF990 ; 86
    .DW 0xC1B8 ; 87
    .DW 0xC9B8 ; 88
    .DW 0xD1B8 ; 89
    .DW 0xD9B8 ; 90
    .DW 0xE1B8 ; 91
    .DW 0xE9B8 ; 92
    .DW 0xF1B8 ; 93
    .DW 0xF9B8 ; 94
    .DW 0xC1E0 ; 95
    .DW 0xC9E0 ; 96
    .DW 0xD1E0 ; 97
    .DW 0xD9E0 ; 98
    .DW 0xE1E0 ; 99
    .DW 0xE9E0 ; 100
    .DW 0xF1E0 ; 101
    .DW 0xF9E0 ; 102
    .DW 0xC208 ; 103
    .DW 0xCA08 ; 104
    .DW 0xD208 ; 105
    .DW 0xDA08 ; 106
    .DW 0xE208 ; 107
    .DW 0xEA08 ; 108
    .DW 0xF208 ; 109
    .DW 0xFA08 ; 110
    .DW 0xC230 ; 111
    .DW 0xCA30 ; 112
    .DW 0xD230 ; 113
    .DW 0xDA30 ; 114
    .DW 0xE230 ; 115
    .DW 0xEA30 ; 116
    .DW 0xF230 ; 117
    .DW 0xFA30 ; 118
    .DW 0xC258 ; 119
    .DW 0xCA58 ; 120
    .DW 0xD258 ; 121
    .DW 0xDA58 ; 122
    .DW 0xE258 ; 123
    .DW 0xEA58 ; 124
    .DW 0xF258 ; 125
    .DW 0xFA58 ; 126
    .DW 0xC280 ; 127
    .DW 0xCA80 ; 128
    .DW 0xD280 ; 129
    .DW 0xDA80 ; 130
    .DW 0xE280 ; 131
    .DW 0xEA80 ; 132
    .DW 0xF280 ; 133
    .DW 0xFA80 ; 134
    .DW 0xC2A8 ; 135
    .DW 0xCAA8 ; 136
    .DW 0xD2A8 ; 137
    .DW 0xDAA8 ; 138
    .DW 0xE2A8 ; 139
    .DW 0xEAA8 ; 140
    .DW 0xF2A8 ; 141
    .DW 0xFAA8 ; 142
    .DW 0xC2D0 ; 143
    .DW 0xCAD0 ; 144
    .DW 0xD2D0 ; 145
    .DW 0xDAD0 ; 146
    .DW 0xE2D0 ; 147
    .DW 0xEAD0 ; 148
    .DW 0xF2D0 ; 149
    .DW 0xFAD0 ; 150
    .DW 0xC2F8 ; 151
    .DW 0xCAF8 ; 152
    .DW 0xD2F8 ; 153
    .DW 0xDAF8 ; 154
    .DW 0xE2F8 ; 155
    .DW 0xEAF8 ; 156
    .DW 0xF2F8 ; 157
    .DW 0xFAF8 ; 158
    .DW 0xC320 ; 159
    .DW 0xCB20 ; 160
    .DW 0xD320 ; 161
    .DW 0xDB20 ; 162
    .DW 0xE320 ; 163
    .DW 0xEB20 ; 164
    .DW 0xF320 ; 165
    .DW 0xFB20 ; 166
    .DW 0xC348 ; 167
    .DW 0xCB48 ; 168
    .DW 0xD348 ; 169
    .DW 0xDB48 ; 170
    .DW 0xE348 ; 171
    .DW 0xEB48 ; 172
    .DW 0xF348 ; 173
    .DW 0xFB48 ; 174
    .DW 0xC370 ; 175
    .DW 0xCB70 ; 176
    .DW 0xD370 ; 177
    .DW 0xDB70 ; 178
    .DW 0xE370 ; 179
    .DW 0xEB70 ; 180
    .DW 0xF370 ; 181
    .DW 0xFB70 ; 182
    .DW 0xC398 ; 183
    .DW 0xCB98 ; 184
    .DW 0xD398 ; 185
    .DW 0xDB98 ; 186
    .DW 0xE398 ; 187
    .DW 0xEB98 ; 188
    .DW 0xF398 ; 189
    .DW 0xFB98 ; 190
    .DW 0xC3E8 ; 191
    .DW 0xC3E8 ; 192
    .DW 0xC3E8 ; 193
    .DW 0xC3E8 ; 194
    .DW 0xC3E8 ; 195
    .DW 0xC3E8 ; 196
    .DW 0xC3E8 ; 197
    .DW 0xC3E8 ; 198
    .DW 0xC3E8 ; 199
    .DW 0xC3E8 ; 200
    .DW 0xC3E8 ; 201
    .DW 0xC3E8 ; 202
    .DW 0xC3E8 ; 203
    .DW 0xC3E8 ; 204
    .DW 0xC3E8 ; 205
    .DW 0xC3E8 ; 206
    .DW 0xC3E8 ; 207
    .DW 0xC3E8 ; 208
    .DW 0xC3E8 ; 209
    .DW 0xC3E8 ; 210
    .DW 0xC3E8 ; 211
    .DW 0xC3E8 ; 212
    .DW 0xC3E8 ; 213
    .DW 0xC3E8 ; 214
    .DW 0xC3E8 ; 215
    .DW 0xC3E8 ; 216
    .DW 0xC3E8 ; 217
    .DW 0xC3E8 ; 218
    .DW 0xC3E8 ; 219
    .DW 0xC3E8 ; 220
    .DW 0xC3E8 ; 221
    .DW 0xC3E8 ; 222
    .DW 0xC3E8 ; 223
    .DW 0xC3E8 ; 224
    .DW 0xC3E8 ; 225
    .DW 0xC3E8 ; 226
    .DW 0xC3E8 ; 227
    .DW 0xC3E8 ; 228
    .DW 0xC3E8 ; 229
    .DW 0xC3E8 ; 230
    .DW 0xC3E8 ; 231
    .DW 0xC3E8 ; 232
    .DW 0xC3E8 ; 233
    .DW 0xC3E8 ; 234
    .DW 0xC3E8 ; 235
    .DW 0xC3E8 ; 236
    .DW 0xC3E8 ; 237
    .DW 0xC3E8 ; 238
    .DW 0xC3E8 ; 239
    .DW 0xC3E8 ; 240
    .DW 0xC3E8 ; 241
    .DW 0xC3E8 ; 242
    .DW 0xC3E8 ; 243
    .DW 0xC3E8 ; 244
    .DW 0xC3E8 ; 245
    .DW 0xC3E8 ; 246
    .DW 0xC3E8 ; 247
    .DW 0xC3E8 ; 248
    .DW 0xC3E8 ; 249
    .DW 0xC3E8 ; 250
    .DW 0xC3E8 ; 251
    .DW 0xC3E8 ; 252
    .DW 0xC3E8 ; 253
    .DW 0xC3E8 ; 254
    .DW 0xC000 ; 255
    .DW 0xC800 ; 256
    .DW 0xD000 ; 257
    .DW 0xD800 ; 258
    .DW 0xE000 ; 259
    .DW 0xE800 ; 260
    .DW 0xF000 ; 261
    .DW 0xF800 ; 262
    .DW 0xC028 ; 263
    .DW 0xC828 ; 264
    .DW 0xD028 ; 265
    .DW 0xD828 ; 266
    .DW 0xE028 ; 267
    .DW 0xE828 ; 268
    .DW 0xF028 ; 269
    .DW 0xF828 ; 270
    .DW 0xC050 ; 271

_eraseList:
    .DW 0
PcgCharNo:
    .DB 0

.ifndef BANK_MEMORY_VRAM
_SPRITE_ERACE_LIST:
    .rept 32*8+16
    .DB 0xC3
    .endm
.endif
