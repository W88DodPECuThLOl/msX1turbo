#ifndef INCL_x1_crtc_setWidth40__h
#define INCL_x1_crtc_setWidth40__h

/**
 * @brief CRTを40x25の200ラインモードに設定する
 * 
 * - 0x1Ax3 8255 PC6のセット 40桁モード
 * - 0x1FDx 画面管理 低解像モード、25行200ライン
 */
void x1_crtcSetWidth40();

#endif // INCL_x1_crtc_setWidth40__h
