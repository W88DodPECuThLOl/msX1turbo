#ifndef INCL_msg__h
#define INCL_msg__h

#include <catZ80Lib.h>

/**
 * @brief 画面の横幅
 */
#define SCREEN_WIDTH (40)

/**
 * @brief メッセージを表示する
 * 
 * @param[in]   pos     表示する位置
 * @param[in]   attr    アトリビュート
 * @param[in]   text    表示する文字列
 */
void msg(u16 pos, const u8 attr, const char* text);

/**
 * @brief メッセージを表示する
 * 
 * @param[in]   text    表示する文字列
 */
void dispMsg(const char* text);

/**
 * @brief エラーメッセージを表示する
 * 
 * @param[in]   text    表示する文字列
 */
void errMsg(const char* text);

#endif // INCL_msg__h
