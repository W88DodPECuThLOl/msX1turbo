#ifndef INCL_sos_loc__h
#define INCL_sos_loc__h

#include "catBasicTypes.h"

/**
 * @brief カーソル位置を設定する
 * @param[in] pos カーソル位置(上位8bitがY座標で、下位8ビットがX座標)
 */
void sos_loc(u16 pos);

#endif // INCL_sos_loc__h
