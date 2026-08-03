#include "ipsPatch.h"

#define IPS_EOF_MARKER (((u32)'E' << 16) | ((u32)'O' << 8) | (u32)'F')

static u32
read24(const u8* source)
{
    return ((u32)source[0] << 16) | ((u32)source[1] << 8) | (u32)source[2];
}

static u16
read16(const u8* source)
{
    return ((u16)source[0] << 8) | (u16)source[1];
}

u8
ipsPatch(u8* target, const u8* ipsSource, const u32 ipsSourceSize)
{
    // IPS File Format
    // https://gist.github.com/ravener/95aac30eb7d2fdc5e983bc143a7cfdf0

    // ファイルをチェックする
    u32 sourceSize = ipsSourceSize;
    if((sourceSize < 8) || (ipsSource[0] != 'P') || (ipsSource[1] != 'A') || (ipsSource[2] != 'T') || (ipsSource[3] != 'C') || (ipsSource[4] != 'H')) {
        return 1; // IPSのパッチファイルではない
    }
    ipsSource += 5; sourceSize -= 5;

    // パッチを当てる
    for(;;) {
        if(sourceSize < 3) {
            return 1; // ファイルが途中で終わっている
        }
        const u32 offset = read24(ipsSource);
        if(offset == IPS_EOF_MARKER) {
            break; // 最後までパッチを当てた
        }
        if(sourceSize < 5) {
            return 1; // ファイルが途中で終わっている
        }
        const u32 length = read16(ipsSource + 3);
        if(length != 0) {
            // 普通のパッチ
            ipsSource += 5; sourceSize -= 5;
            if(sourceSize < length) {
                return 1; // ファイルが途中で終わっている
            }
            for(u32 i = 0; i < length; ++i) {
                target[offset + i] = ipsSource[i];
            }
            ipsSource += length; sourceSize -= length;
        } else {
            // ランレングスのパッチ
            if(sourceSize < 7) {
                return 1; // ファイルが途中で終わっている
            }
            const u32 runLength = read16(ipsSource + 5);
            const u8 value = ipsSource[7];
            for(u32 i = 0; i < runLength; ++i) {
                target[offset + i] = value;
            }
            ipsSource += 7; sourceSize -= 7;
        }
    }
    return 0;
}
