/**
 * ■ROM容量16Kib以下
 * 
 * MAIN   page0 slot0  s-os & msX1turbo
 * MEMROY page1 slot1  rom 16KiB
 *        page2 slot0  vram 16KiB
 *        page3 slot0  ram 16KiB
 * BANK#0 page0 未使用
 *        page1 未使用
 * 
 * ■ROM容量32Kib以下
 * MAIN   page0 slot0  s-os & msX1turboZ
 * MEMROY page1 slot1  rom
 *        page2 slot1  rom
 *        page3 slot0  ram 16KiB
 * BANK#0 page0 msX1turboZ
 *        page1 vram 16KiB
 */

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

#define ROM_ADDRESS 0x4000

extern void INITIALIZE();
extern void CTC_SETUP();
extern void IN_OUT_HOOK();

extern void ENASLT();
extern void WRTVDP();
extern void RDVRM();
extern void WRTVRM();
extern void SETRD();
extern void SETWRT();
extern void FILVRM();
extern void CLRSPR();
extern void LDIRMV();
extern void LDIRVM();
extern void GICINI();
extern void WRTPSG();
extern void RDPSG();
extern void GTSTCK();
extern void GTTRIG();
extern void RSLREG();
extern void RDVDP();
extern void SNSMAT();

u8
main()
{
    __asm__("di");
    INITIALIZE();
    vdpInit();
    GICINI();

    // MSX WORK
    *(u8*)0x006 = 0xC6; // VDP.DR
    *(u8*)0x007 = 0xC6; // VDP.WR
    // MSX BIOS
    *(u8*)0x0024 = 0xC3; *(u16*)(0x0024+1) = (u16)ENASLT;
    *(u8*)0x003B = 0xC9; // INITIO
    *(u8*)0x003E = 0xC9; // INIFNK
    *(u8*)0x0041 = 0xC9; // DISSCR 画面表示を禁止します。
    *(u8*)0x0044 = 0xC9; // ENASCR 画面を表示します。
    *(u8*)0x0047 = 0xC3; *(u16*)(0x0047+1) = (u16)WRTVDP;
    *(u8*)0x004A = 0xC3; *(u16*)(0x004A+1) = (u16)RDVRM;
    *(u8*)0x004D = 0xC3; *(u16*)(0x004D+1) = (u16)WRTVRM;
    *(u8*)0x0050 = 0xC3; *(u16*)(0x0050+1) = (u16)SETRD;
    *(u8*)0x0053 = 0xC3; *(u16*)(0x0053+1) = (u16)SETWRT;
    *(u8*)0x0056 = 0xC3; *(u16*)(0x0056+1) = (u16)FILVRM;
    *(u8*)0x0069 = 0xC3; *(u16*)(0x0069+1) = (u16)CLRSPR;
    *(u8*)0x0059 = 0xC3; *(u16*)(0x0059+1) = (u16)LDIRMV;
    *(u8*)0x005C = 0xC3; *(u16*)(0x005C+1) = (u16)LDIRVM;
    *(u8*)0x0090 = 0xC3; *(u16*)(0x0090+1) = (u16)GICINI;
    *(u8*)0x0093 = 0xC3; *(u16*)(0x0093+1) = (u16)WRTPSG;
    *(u8*)0x0096 = 0xC3; *(u16*)(0x0096+1) = (u16)RDPSG;
    *(u8*)0x0099 = 0xC9; // STRTMS
    *(u8*)0x00A2 = 0xC9; // CHPUT
    *(u8*)0x00A5 = 0xC9; // LPTOUT
    *(u8*)0x00A5 = 0xC9; // CHGMOD
    *(u8*)0x0062 = 0xC9; // CHGCLR
    *(u8*)0x00A8 = 0xC9; // LPTSTT
    *(u8*)0x00D5 = 0xC3; *(u16*)(0x00D5 + 1) = (u16)GTSTCK;
    *(u8*)0x00D8 = 0xC3; *(u16*)(0x00D8 + 1) = (u16)GTTRIG;
    *(u8*)0x0135 = 0xC9; // CHGSND
    *(u8*)0x0138 = 0xC3; *(u16*)(0x0138 + 1) = (u16)RSLREG;
    *(u8*)0x013E = 0xC3; *(u16*)(0x013E + 1) = (u16)RDVDP;
    *(u8*)0x0141 = 0xC3; *(u16*)(0x0141+1) = (u16)SNSMAT;
    // IO PATCH
    // @todo
    *(u8*)0x0000 = 0xC3; *(u16*)(0x0000+1) = (u16)IN_OUT_HOOK;
    for(u16 addr = ROM_ADDRESS + 0x0010; addr < ROM_ADDRESS + 0x4000; ++addr) {
        if(*(u16*)addr == 0x79ED || *(u16*)addr == 0x98D3) {
            // OUT (C),A
            // OUT (0x98),A
            *(u16*)addr = 0x77C7; // RST #0x00 : LD 0(IX),A
        } else if(*(u16*)addr == 0x78ED) {
            // IN A,(C)
            *(u16*)addr = 0x7EC7; // RST #0x00 : LD A,0(IX)
        }
#if 0
        else if(*(u16*)addr == 0x41ED) {
            // OUT (C),B
            *(u16*)addr = 0x70C7; // RST #0x00 : LD 0(IX),B
        } else if(*(u16*)addr == 0x49ED) {
            // OUT (C),C
            *(u16*)addr = 0x71C7; // RST #0x00 : LD 0(IX),C
        } else if(*(u16*)addr == 0x51ED) {
            // OUT (C),D
            *(u16*)addr = 0x72C7; // RST #0x00 : LD 0(IX),D
        } else if(*(u16*)addr == 0x59ED) {
            // OUT (C),E
            *(u16*)addr = 0x73C7; // RST #0x00 : LD 0(IX),E
        } else if(*(u16*)addr == 0x61ED) {
            // OUT (C),H
            *(u16*)addr = 0x74C7; // RST #0x00 : LD 0(IX),H
        } else if(*(u16*)addr == 0x69ED) {
            // OUT (C),L
            *(u16*)addr = 0x75C7; // RST #0x00 : LD 0(IX),L
        } else if(*(u16*)addr == 0xB3ED) {
            // OTIR
            *(u16*)addr = 0x0000; // NOP
        } else if(*(u16*)addr == 0xBBED) {
            // OTDR
            *(u16*)addr = 0x0000; // NOP
        } else if(*(u16*)addr == 0xA3ED) {
            // OUTI
            *(u16*)addr = 0x0000; // NOP
        } else if(*(u16*)addr == 0xABED) {
            // OUTD
            *(u16*)addr = 0x0000; // NOP
        } else if(*(u16*)addr == 0x40ED) {
            // IN B,(C)
            *(u16*)addr = 0x46C7; // RST #0x00 : LD B,0(IX)
        } else if(*(u16*)addr == 0x48ED) {
            // IN C,(C)
            *(u16*)addr = 0x4EC7; // RST #0x00 : LD C,0(IX)
        } else if(*(u16*)addr == 0x50ED) {
            // IN D,(C)
            *(u16*)addr = 0x56C7; // RST #0x00 : LD D,0(IX)
        } else if(*(u16*)addr == 0x58ED) {
            // IN E,(C)
            *(u16*)addr = 0x5EC7; // RST #0x00 : LD E,0(IX)
        } else if(*(u16*)addr == 0x60ED) {
            // IN H,(C)
            *(u16*)addr = 0x66C7; // RST #0x00 : LD H,0(IX)
        } else if(*(u16*)addr == 0x68ED) {
            // IN H,(C)
            *(u16*)addr = 0x6EC7; // RST #0x00 : LD L,0(IX)
        } else if(*(u16*)addr == 0x56ED) {
            // IM 1
            *(u16*)addr = 0x0000; // NOP
        }
#endif
    }
    CTC_SETUP();
    __asm__("ei");
    ((void (*)())*(u16*)(ROM_ADDRESS + 0x0002))();

    return 0;
}
