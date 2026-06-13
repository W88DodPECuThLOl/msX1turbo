#if __WIN32
#include <stdint.h>
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint16_t u32;
#else
#include <catZ80Lib.h>
#include <string.h>
#endif // __WIN32
#include "x1VDP.h"
#include "x1VdpSprite.h"

#define USE_DMA (1)

#define VRAM ((u8*)0x8000)
#define LINE_ADDRESS_TABLE ((u16*)0x1000)
#define SPRITE_ATTRIBUTE_BUFFER 0x2000
#define SPRITE_ERACE_LIST (0x1800)
static u8* eraseList;

extern u16 SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS;

// VDPレジスタ
u8 vdp[8];
// スクリーンモード
static u8 screenMode = 0;

static void
pcgInit() __naked
{
    __asm
;    ; PCG高速アクセス
;	ld  bc, #0x1fd0
;	in  a,(c)
;	or  #0x20
;    ld  a,#0x20
;	out (c),a

	; 漢字
	ld bc, #0x3FFF
	.db #0xED, #0x71 ; out (c),#0 ; Output 0 to port BC.
	; 属性
	ld b, #0x27		; bc: 0x27FF
	ld a, #0x20
	out (c),a

    ret
    __endasm;
}

static void
setPcg(u16 pcgPattern, u16 charNo) __naked
{
    (void)pcgPattern;
    (void)charNo;
    __asm

    ; 設定する文字
    ld bc, #0x37FF
    out (c),e

    ; pcg書き込む 
    ; 0x000-0x0FF : 青色に書き込む
    ; 0x100-0x1FF : 赤色に書き込む
    ; 0x200-0x2FF : 緑色に書き込む
    LD A,#0x15 + 1
    ADD A,D
    LD B,A
    INC C

    ; b
    ;ld bc, #(0x1500 + 0x100)
    ;call pcgWriteSub
    ; r
    ;ld bc, #(0x1600 + 0x100)
    ;call pcgWriteSub
    ; g
    ;ld bc, #(0x1700 + 0x100)
    ;call pcgWriteSub

	;ret

pcgWriteSub:
	outi
	ld e, #7
loop1:
		inc c
		inc c
		inc	b
		outi
	dec e
	jr nz,loop1
	ret

    __endasm;
}

#if defined(USE_DMA) && !USE_DMA
static void
renderTextLine(u16 src, u16 dst) __naked
{
    (void)src;
    (void)dst;
    // HL : src
    // DE : dst
    __asm
    LD B,D
    LD C,E
    LD D,#24
LOOP1:
    LD E,#16
LOOP2:
    INC B
    OUTI
    INC BC
    INC B
    OUTI
    INC BC
    DEC E
    JP NZ,LOOP2

    LD A,C
    ADD #8
    LD C,A
    JR NC,SKIP ; 7/12
    INC B      ; 4
SKIP:
    DEC D
    JP NZ,LOOP1
    RET
    __endasm;
}
#endif

static void
renderGraphic1()
{
    // name table 768byte
#if defined(USE_DMA) && USE_DMA
    u16 nameTableAddress = (u16)VRAM + (((u16)vdp[2] & 0x7F) << 10);
    u16 x1TextVramAddress = 0x3000 + 4; // メモ)32ドット分右にずらしておく
    for(u8 y = 0; y < 24; ++y) {
        x1_dmaCopyMemoryToVRAM(nameTableAddress, x1TextVramAddress, 32);
        nameTableAddress  += 32;
        x1TextVramAddress += 40;
    }
#else
    u16 nameTableAddress = (u16)VRAM + (((u16)vdp[2] & 0x7F) << 10);
    u16 x1TextVramAddress = 0x3000 + 4; // メモ)32ドット分右にずらしておく
    renderTextLine(nameTableAddress, x1TextVramAddress);
#endif
}

static void
renderSpriteMode1_size16x16(u8* spriteAttributeTableAddress)
{
    u8 patternNo = spriteAttributeTableAddress[2];
    patternNo &= 0xFC;
    const u8* spritePatternAddress = (const u8*)(SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS + ((u16)patternNo << 3));
//    setSpritePatternAddress16x16(spritePatternAddress);

    u8 y = spriteAttributeTableAddress[0];
    const u16* lineAdr = LINE_ADDRESS_TABLE + y;
*eraseList++ = 0x21; *((u16*)eraseList) = (u16)lineAdr; eraseList += 2;
*eraseList++ = 0x1E;
    u8 x = spriteAttributeTableAddress[1];
    if(spriteAttributeTableAddress[3] & 0x80) {
        // EC
*eraseList++ = (x >> 3); // LD E,nn
*eraseList++ = 0xCD;
        if(x & 7) {
            //setShiftCountAndOffset16x16(8 - (x & 7), (x >> 3));
            setShiftCountAndOffset16x16(x & 7, (x >> 3));
            draw16x16_shift(lineAdr, spritePatternAddress);
*((u16*)eraseList) = (u16)erase24x16;
        } else {
            setShiftCountAndOffset16x16(0, (x >> 3));
            draw16x16(lineAdr, spritePatternAddress);
*((u16*)eraseList) = (u16)erase16x16;
        }
    } else {
*eraseList++ = (x >> 3) + 4; // LD E,nn
*eraseList++ = 0xCD;
        if(x & 7) {
//            setShiftCountAndOffset16x16(8 - (x & 7), (x >> 3) + 4);
            setShiftCountAndOffset16x16(x & 7, (x >> 3) + 4);
            draw16x16_shift(lineAdr, spritePatternAddress);
*((u16*)eraseList) = (u16)erase24x16;
        } else {
            setShiftCountAndOffset16x16(0, (x >> 3) + 4);
            draw16x16(lineAdr, spritePatternAddress);
*((u16*)eraseList) = (u16)erase16x16;
        }
    }
    eraseList += 2;
}

static void
renderSpriteMode1_size8x8(const u8* spriteAttributeTableAddress)
{
    u8 patternNo = spriteAttributeTableAddress[2];
    //u8 color = spriteAttributeTableAddress[3] & 0x0F;
    //const u8* spritePatternAddress = VRAM + ((u16)(vdp[6] & 0x3F) << 11) + ((u16)patternNo << 3);
    const u8* spritePatternAddress = (const u8*)(SPRITE_PATTERN_GENERATOR_TABLE_ADDRESS + ((u16)patternNo << 3));
    setSpritePatternAddress8x8(spritePatternAddress);
    u8 x = spriteAttributeTableAddress[1];
*eraseList++ = 0x1E;
    if(spriteAttributeTableAddress[3] & 0x80) {
        // EC
        setShiftCountAndOffset8x8(8 - (x & 7), (x >> 3));
*eraseList++ = (x >> 3); // LD E,nn
    } else {
        setShiftCountAndOffset8x8(8 - (x & 7), (x >> 3) + 4);
*eraseList++ = (x >> 3) + 4; // LD E,nn
    }
    u8 y = spriteAttributeTableAddress[0];
    const u16* lineAdr = LINE_ADDRESS_TABLE + y;
*eraseList++ = 0x21; *((u16*)eraseList) = (u16)lineAdr; eraseList += 2;
    draw8x8(lineAdr, x & 7);
*eraseList++ = 0xCD;
    if(x & 7) {
        *((u16*)eraseList) = (u16)erase16x8;
    } else {
        *((u16*)eraseList) = (u16)erase8x8;
    }
eraseList += 2;
}

#if 0

static void
eraseSpriteSize8x8(const u8* spriteAttributeTableAddress)
{
    u8 x = spriteAttributeTableAddress[1];
    setEraseOffset8x8((x >> 3)
        + ((spriteAttributeTableAddress[3] & 0x80) ? 0 : 4) // EC
    );
    if(x & 7) {
        u8 y = spriteAttributeTableAddress[0];
        const u16* lineAdr = LINE_ADDRESS_TABLE + y;
        erase16x8(lineAdr);
    } else {
        u8 y = spriteAttributeTableAddress[0];
        const u16* lineAdr = LINE_ADDRESS_TABLE + y;
        erase8x8(lineAdr);
    }
}

static void
eraseSpriteSize16x16(u8* spriteAttributeTableAddress)
{
    u8 x = spriteAttributeTableAddress[1];
    setEraseOffset16x16((x >> 3)
        + ((spriteAttributeTableAddress[3] & 0x80) ? 0 : 4) // EC
    );
    if(x & 7) {
        u8 y = spriteAttributeTableAddress[0];
        const u16* lineAdr = LINE_ADDRESS_TABLE + y;
        erase24x16(lineAdr);
    } else {
        u8 y = spriteAttributeTableAddress[0];
        const u16* lineAdr = LINE_ADDRESS_TABLE + y;
        erase16x16(lineAdr);
    }
}

#endif

static void
eraseSprite() __naked
{
    __asm
        .DB 0xC3,0x00,0x18
    __endasm;

//     __asm
//         LD HL,#SPRITE_ATTRIBUTE_BUFFER
//         LD A,(#(_vdp + 1))
//         BIT	1,A
//         JR Z,3000010$
// 3000000$:
//             LD A,(HL)
//             CP #208
//             RET Z
//             CP #(192-8)
//             JR NC,3000001$
// 
//             PUSH HL
//             CALL _eraseSpriteSize16x16
//             POP HL
// 
// 3000001$:
//             LD A,L
//             ADD #4
//             LD L,A
//             CP #(0x04*32)
//             JR NZ,3000000$
//         RET
// 
// 3000010$:
//             LD A,(HL)
//             CP #208
//             RET Z
//             CP #(192-8)
//             JR NC,3000011$
// 
//             PUSH HL
//             CALL _eraseSpriteSize8x8
//             POP HL
// 
// 3000011$:
//             LD A,L
//             ADD #4
//             LD L,A
//             CP #(0x04*32)
//             JR NZ,3000010$
//         RET
//     __endasm;
}

static void
renderSprite() __naked
{
    __asm
        LD HL,#SPRITE_ATTRIBUTE_BUFFER
        LD A,(#(_vdp + 1))
        BIT	1,A
        JR Z,2000010$
2000000$:
            LD A,(HL)
            CP #208
            RET Z
            CP #(192-8)
            JR NC,2000001$

            PUSH HL
            CALL _renderSpriteMode1_size16x16
            POP HL

2000001$:
            LD A,L
            ADD #4
            LD L,A
            CP #(0x04*32)
            JR NZ,2000000$
        RET

2000010$:
            LD A,(HL)
            CP #208
            RET Z
            CP #(192-8)
            JR NC,2000011$

            PUSH HL
            CALL _renderSpriteMode1_size8x8
            POP HL

2000011$:
            LD A,L
            ADD #4
            LD L,A
            CP #(0x04*32)
            JR NZ,2000010$
        RET
    __endasm;
}

void
CLRSPR()
{
    u8* spriteAttributeTableAddress = VRAM + ((u16)vdp[5] << 7);
    for(u8 sprNo = 0; sprNo < 32; ++sprNo) {
        spriteAttributeTableAddress[0] = 209;
        spriteAttributeTableAddress[1] = 0;
        spriteAttributeTableAddress[2] = sprNo;
        spriteAttributeTableAddress[3] = 0x0F;
        spriteAttributeTableAddress += 4;
    }
}

static void
waku()
{
    // 枠部分を黒にしとく
    for(u8 y = 0; y < 24; ++y) {
        for(u8 x = 0; x < 4; ++x) { outp(0x2000 + y * 40 + x, 0x00); }
        for(u8 x = 36; x < 40; ++x) { outp(0x2000 + y * 40 + x, 0x00); }
    }
    for(u8 x = 0; x < 40; ++x) { outp(0x2000 + 24 * 40 + x, 0x00); }
}

static void
vdpSetGraphic1()
{
    screenMode = 1;
    x1_dmaFillVRAM(0x2000, 40*25,  0x20 + 0x01); // PCG Color1
    waku();
}

static void
vdpSetGraphic2()
{
    screenMode = 2;
    x1_dmaFillVRAM(0x2000,         40*8,  0x20 + 0x01); // PCG Color1
    x1_dmaFillVRAM(0x2000 + 40* 8, 40*8,  0x20 + 0x02); // PCG Color2
    x1_dmaFillVRAM(0x2000 + 40*16, 40*8,  0x20 + 0x04); // PCG Color4
    waku();
}

void
vdpInit()
{
    outp(0x1FD0, 0x22); // 200ラインモード、2本ラスタ/ドット、バンク0表示、バンク0アクセス
                        // PCG高速アクセス
    outp(0x1300, 0xFE); // プライオリティ
    outp(0x1000, 0xAA); // グラフィックパレット
    outp(0x1100, 0xCC); // グラフィックパレット
    outp(0x1200, 0xF0); // グラフィックパレット

    // グラフィックのY軸のアドレスの事前計算
    for(int y = 0; y < 256 + 15; ++y) {
        int yy = (1 + y) & 0xFF;
        LINE_ADDRESS_TABLE[y] = 0xC000 | (((yy & 7) << 11) + (yy / 8) * 40);
    }

    // テキスト初期化
    vdpSetGraphic1();
    for(u8 x = 0; x < 40; ++x) { outp(0x2000 + 24 * 40 + x, 0x00); }
    x1_dmaFillVRAM(0x3000, 0xD800, 0x00); // TEXT & GCLS

    // PCG初期化
    pcgInit();

    eraseList = (u8*)SPRITE_ERACE_LIST;
    *eraseList = 0xC9; // RET
}

void
vdpRender()
{
    // 表示とアクセスするバンクを切り替える
    // @todo
    //static u8 bank = 0x08 | 0x22;
    //outp(0x1fd0, bank);
    //bank ^= 0x18;

#if 1
    static u8 charNo = 0;
    u16 pcgPattern;
    if(((vdp[0] & 0x0E) == 0)
        && ((vdp[1] & 0x18) == 0)) {
        // GRAHIC1
        if(screenMode != 1) {
            vdpSetGraphic1();
        }
        pcgPattern = (u16)VRAM + ((u16)(vdp[4] & 0x3F) << 11);
        pcgPattern += (u16)charNo * 8;
        setPcg(pcgPattern, charNo);
    } else {
        // GRAHIC2,GRAHIC3
        if(screenMode != 2) {
            vdpSetGraphic2();
        }
        pcgPattern = (u16)VRAM + ((u16)(vdp[4] & 0x3C) << 11);
        pcgPattern += (u16)charNo * 8;
        // 上側
        setPcg(pcgPattern, charNo);
        // 真ん中
        pcgPattern += 256*8;
        setPcg(pcgPattern, 0x100 | charNo);
        // 下側
        pcgPattern += 256*8;
        setPcg(pcgPattern, 0x200 | charNo);
    }
    charNo++;
#else
    for(u16 charNo = 0; charNo < 256; ++charNo) {
        setPcg(pcgPattern, charNo);
        pcgPattern += 8;
    }
#endif
    // テキスト描画
    renderGraphic1();

    // スプライト消去
    eraseSprite(); // @todo 高速化すること

    // スプライト描画
    u8* spriteAttributeTableAddress = VRAM + ((u16)vdp[5] << 7);
    memcpy((u8*)SPRITE_ATTRIBUTE_BUFFER, spriteAttributeTableAddress, 4 * 32);
    eraseList = (u8*)SPRITE_ERACE_LIST;
    renderSprite(); // @todo 高速化すること
    *eraseList = 0xC9; // RET
}
