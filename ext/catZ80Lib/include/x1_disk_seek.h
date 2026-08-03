#ifndef INCL_x1_disk_seek__h
#define INCL_x1_disk_seek__h

#include "catBasicTypes.h"

/**
 * @brief トラックを移動する
 * @note 移動元と移動先から最適な移動方法でトラックを移動させます。
 * @param[in] destinationTrackNo    移動先のトラック番号
 * @param[in] currentTrackNo        現在のトラック番号
 */
void x1_diskSeek(const u8 destinationTrackNo, const u8 currentTrackNo);

#endif // INCL_x1_disk_seek__h
