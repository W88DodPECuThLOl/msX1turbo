#ifndef INCL_x1_joy_readJoyStick__h
#define INCL_x1_joy_readJoyStick__h

#include "catBasicTypes.h"

/**
 * @brief ジョイスティックから読み込む
 * @param index ジョイスティックの番号(0:ポートA, 1:ポートB)
 * @return ジョイスティックの値(負論理)
 * @retval   0bit : 上
 * @retval   1bit : 下
 * @retval   2bit : 左
 * @retval   3bit : 右
 * @retval   4bit : ---
 * @retval   5bit : トリガ1
 * @retval   6bit : トリガ2
 * @retval   7bit : ---
 */
u8 x1_readJoyStick(u8 index);

#endif // INCL_x1_joy_readJoyStick__h
