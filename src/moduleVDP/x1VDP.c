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

#if defined(VRAM_8000) && VRAM_8000
#define VRAM ((u8*)0x8000)
#elif defined(VRAM_4000) && VRAM_4000
#define VRAM ((u8*)0x4000)
#endif

extern void setPcgB(u16 pcgPattern, u16 charNo);
extern void setPcgR(u16 pcgPattern, u16 charNo);
extern void setPcgG(u16 pcgPattern, u16 charNo);
extern void setPcgColorBlack(const u8 charNo);
extern void setPcgColorGreen(u16 pcgPattern, u16 charNo);
extern void setPcgColorBlue(u16 pcgPattern, u16 charNo);
extern void setPcgColorRed(u16 pcgPattern, u16 charNo);
extern void setPcgColorCyan(u16 pcgPattern, u16 charNo);
extern void setPcgColorYellow(u16 pcgPattern, u16 charNo);
extern void setPcgColorWhite(u16 pcgPattern, u16 charNo);

// VDPレジスタ
#define VDP_R0 (*(u8*)0xF3DF)
#define VDP_R1 (*(u8*)(0xF3DF + 1))
#define VDP_R3 (*(u8*)(0xF3DF + 3))
#define VDP_R4 (*(u8*)(0xF3DF + 4))

void
vdpWriteHook(u16 address)
{
    if(((VDP_R0 & 0x0E) == 0)
        && ((VDP_R1 & 0x18) == 0)) {
        const u16 patternAddress = (u16)VRAM + ((u16)(VDP_R4 & 0x3F) << 11);
        if(patternAddress <= address && address < (patternAddress + 8*256)) {
            // PCG書き換えられた
            u8 charNoD = (address - patternAddress) / 8;
            u8 lineNo  = (address - patternAddress) & 0x7;
            outp(0x37FF, charNoD);
            outp(0x1500 + lineNo * 2, *((u8*)address));
        }
    } else {
        const u16 patternAddress = (u16)VRAM + ((u16)(VDP_R4 & 0x3C) << 11);
        if(patternAddress <= address && address < (patternAddress + 8*256*3)) {
            // PCG書き換えられた
            u16 charNoD = ((address - patternAddress) / 8);
            u8 lineNo  = (address - patternAddress) & 0x7;
            outp(0x37FF, charNoD & 0xFF);
            if(charNoD < 0x100) {
                outp(0x1500 + lineNo * 2, *((u8*)address));
            } else if(charNoD < 0x200) {
                outp(0x1600 + lineNo * 2, *((u8*)address));
            } else {
                outp(0x1700 + lineNo * 2, *((u8*)address));
            }
        }
    }
}

void
pcg1(const u8 charNo)
{
    // GRAHIC1

    // Color table base address
    u16 colorTableBaseAddress = (u16)VRAM + ((u16)(VDP_R3) << 6);
    u8 color = *(u8*)(colorTableBaseAddress | (charNo >> 3));
    color >>= 4;

    u16 pcgPattern;
    pcgPattern = (u16)VRAM + ((u16)(VDP_R4 & 0x3F) << 11);
    pcgPattern += (u16)charNo * 8;

    switch(color) {
        case 0: // 透明
        case 1: // #000000
            setPcgColorBlack((u8)charNo);
            break;
        case 2: // #3eb849
        case 3: // #74d07d
            setPcgColorGreen(pcgPattern, charNo);
            break;
        case 4: // #5955e0
        case 5: // #8076f1
            setPcgColorBlue(pcgPattern, charNo);
            break;

        case 6: // #b95e51
            setPcgColorRed(pcgPattern, charNo);
            break;

        case 7: // #65dbef
            setPcgColorCyan(pcgPattern, charNo);
            break;

        case 8: // #db6559
        case 9: // #ff897d
            setPcgColorRed(pcgPattern, charNo);
            break;

            // 黄色
        case 10: // #ccc35e
        case 11: // #ded087
            setPcgColorYellow(pcgPattern, charNo);
            break;

        case 12: // #3aa241
            setPcgColorGreen(pcgPattern, charNo);
            break;

        case 14: // #cccccc
        case 15: // #ffffff
            setPcgColorWhite(pcgPattern, charNo);
            break;
    }
}

void
pcg2(const u8 charNo)
{
    // GRAHIC2,GRAHIC3
    u16 pcgPattern;
    // 上側
    pcgPattern = (u16)VRAM + ((u16)(VDP_R4 & 0x3C) << 11);
    pcgPattern += (u16)charNo * 8;
    setPcgB(pcgPattern, charNo);
    // 真ん中
    pcgPattern += 256*8;
    setPcgR(pcgPattern , charNo);
    // 下側
    pcgPattern += 256*8;
    setPcgG(pcgPattern , charNo);
}
