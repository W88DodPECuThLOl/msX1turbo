#ifndef INCL_x1VdpSprite__h
#define INCL_x1VdpSprite__h

// 8x8サイズのスプライト描画用
extern void setShiftCountAndOffset8x8(u16 shiftCount, u16 offsetAddress);
extern void setSpritePatternAddress8x8(const u8* spritePatternAddress);
extern void draw8x8(const u16* address, u16 x);

// 16x16サイズのスプライト描画用
extern void setShiftCountAndOffset16x16(u16 shiftCount, u16 offsetAddress);
//extern void setSpritePatternAddress16x16(const u8* spritePatternAddress);
extern void draw16x16(const u16* address, const u8* spritePatternAddress);
extern void draw16x16_shift(const u16* address, const u8* spritePatternAddress);

// スプライト消去用
//extern void setEraseOffset8x8(u16 offsetAddress);
//extern void setEraseOffset16x16(u16 offsetAddress);
extern void erase8x8(const u16* address);
extern void erase16x8(const u16* address);
extern void erase16x16(const u16* address);
extern void erase24x16(const u16* address);

#endif // INCL_x1VdpSprite__h
