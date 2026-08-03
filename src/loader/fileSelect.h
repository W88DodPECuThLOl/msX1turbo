#ifndef INCL_fileSelect__h
#define INCL_fileSelect__h

#include <catZ80Lib.h>

/**
 * @brief ファイルを選択する
 * @param[out]      filename ファイル名
 * @param[in,out]   driveNo  ドライブ番号
 * @return 処理結果
 * @retval 0: ファイルが選択された
 * @retval 0以外: 選択されなかった
 */
u8 fileSelect(char* filename, u8* driveNo);

#endif // INCL_fileSelect__h
