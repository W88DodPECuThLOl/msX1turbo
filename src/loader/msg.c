#include "msg.h"

void
msg(u16 pos, const u8 attr, const char* text)
{
    const char* p = text;
    while(*p) {
        outp(0x2000 | pos, attr); // アトリビュート
        outp(0x3000 | pos, *p++); // キャラクタ
        ++pos;
    }
}

void
errMsg(const char* text)
{
    msg(1 + 24*SCREEN_WIDTH, 7, "                              ");
    msg(1 + 24*SCREEN_WIDTH, 2, text);
}

void
dispMsg(const char* text)
{
    msg(1 + 23*SCREEN_WIDTH, 7, "                              ");
    msg(1 + 23*SCREEN_WIDTH, 4, text);
}
