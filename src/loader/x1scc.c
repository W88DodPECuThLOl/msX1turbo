#if __WIN32
#include <stdint.h>
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint16_t u32;
#else
#include <catZ80Lib.h>
#include <string.h>
#endif // __WIN32
#include "fileSelect.h"
#include "ipsPatch.h"
#include "msg.h"

void initSCC()
{
    for(u8 i = 0; i < 5; ++i) {
        outp(0x0700, 0x20+i); // Channel No.
        //outp(0x0701, 0xC0 | (1<<3) | 0x07); // RL:11 FB:1 ALG:7
        outp(0x0701, 0xC0 | (1<<3) | 0x3); // RL:11 FB:1 ALG:3

        outp(0x0700, 0x38+i); // Channel No.
        outp(0x0701, 0x00 | 0x00); // PMS:0 AMS:0

        outp(0x0700, 0x40+i); // OP1
        outp(0x0701, 0x01 | 0x01); // DT1:1 MUL:1
        outp(0x0700, 0x50+i); // OP2
        outp(0x0701, 0x01 | 0x01); // DT1:1 MUL:1
        outp(0x0700, 0x48+i); // OP3
        outp(0x0701, 0x01 | 0x01); // DT1:1 MUL:1
        outp(0x0700, 0x58+i); // OP4
        outp(0x0701, 0x01 | 0x01); // DT1:1 MUL:1

        outp(0x0700, 0x80+i); // OP1
        outp(0x0701, 0x00 | 0x1E); // KS:0 AR:30
        outp(0x0700, 0x90+i); // OP2
        outp(0x0701, 0x00 | 0x1E); // KS:0 AR:30
        outp(0x0700, 0x88+i); // OP3
        outp(0x0701, 0x00 | 0x1E); // KS:0 AR:30
        outp(0x0700, 0x98+i); // OP4
        outp(0x0701, 0x00 | 0x1E); // KS:0 AR:30

        outp(0x0700, 0xA0+i); // OP1
        outp(0x0701, 0x00 | 0x00); // ASM-EN:0 D1R:0
        outp(0x0700, 0xB0+i); // OP1
        outp(0x0701, 0x00 | 0x00); // ASM-EN:0 D1R:0
        outp(0x0700, 0xA8+i); // OP1
        outp(0x0701, 0x00 | 0x00); // ASM-EN:0 D1R:0
        outp(0x0700, 0xB8+i); // OP1
        outp(0x0701, 0x00 | 0x00); // ASM-EN:0 D1R:0

        outp(0x0700, 0xC0+i); // OP1
        outp(0x0701, 0x00 | 0x00); // DT2:0なし D2R:0減衰しない
        outp(0x0700, 0xD0+i); // OP2
        outp(0x0701, 0x00 | 0x00); // DT2:0なし D2R:0減衰しない
        outp(0x0700, 0xC8+i); // OP3
        outp(0x0701, 0x00 | 0x00); // DT2:0なし D2R:0減衰しない
        outp(0x0700, 0xD8+i); // OP4
        outp(0x0701, 0x00 | 0x00); // DT2:0なし D2R:0減衰しない

        outp(0x0700, 0xE0+i); // OP1
        outp(0x0701, 0x00 | 0x0E); // D1L:0減衰無し RR:14
        outp(0x0700, 0xF0+i); // OP2
        outp(0x0701, 0x00 | 0x0E); // D1L:0減衰無し RR:14
        outp(0x0700, 0xE8+i); // OP3
        outp(0x0701, 0x00 | 0x0E); // D1L:0減衰無し RR:14
        outp(0x0700, 0xF8+i); // OP4
        outp(0x0701, 0x00 | 0x0E); // D1L:0減衰無し RR:14
    }
}
