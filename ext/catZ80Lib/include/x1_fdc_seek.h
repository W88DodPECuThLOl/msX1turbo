#ifndef INCL_x1_fdc_seek__h
#define INCL_x1_fdc_seek__h

#include "catBasicTypes.h"

/**
 * @brief トラックを移動する
 * @param[in] destinationTrackNo    移動先のトラック番号
 * @param[in] currentTrackNo        現在のトラック番号
 */
void x1_fdcSeek(const u8 destinationTrackNo, const u8 currentTrackNo);

#endif // INCL_x1_fdc_seek__h
