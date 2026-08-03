#include "fileSelect.h"
#include "msx1BiosPsg.h"
#include "msg.h"
#include <string.h>

/**
 * @brief キー入力のコンテキスト
 */
typedef struct KeyContext {
    /**
     * @brief １つ前の入力の状態
     */
    u8 previous;
    /**
     * @brief 現在の入力の状態
     */
    u8 current;
    /**
     * @brief 変化のあったキーの状態
     */
    u8 trigger;
    /**
     * @brief 押下されたキーの状態
     */
    u8 pressed;
    /**
     * @brief 離されたキーの状態
     */
    u8 released;
} KeyContext;

//! 上押された
#define INPUT_UP   (0x01)
//! 下押された
#define INPUT_DOWN (0x02)
//! 右押された
#define INPUT_RIGHT (0x04)
//! TRIGGER1押された
#define INPUT_TRIGGER1 (0x10)
//! TRIGGER2押された
#define INPUT_TRIGGER2 (0x20)

//! 最大ファイル数
#define FILE_SELECT_MAX (19)
/**
 * @brief ファイル選択のコンテキスト
 */
typedef struct FileSelectContext {
    /**
     * @brief ドライブ番号(0～)
     */
    u8 driveNo;

    /**
     * @brief 全体のファイル数
     */
    u16 filenameSize;

    /**
     * @brief 入力情報
     */
    KeyContext key;

    /**
     * @brief ファイル名の記録場所
     */
    const char filename[FILE_SELECT_MAX][FILE_SYSTEM_FILE_NAME_LENGTH + FILE_SYSTEM_FILE_EXTENTION_LENGTH + 1];
} FileSelectContext;

/**
 * @brief ファイルの列挙時に呼び出される物
 * @param ib インフォメーションブロック
 * @param userData1 
 * @param userData2 
 * @param userData3 
 * @return 処理結果
 */
static u8
callbackEnumFile(const u8* ib, void* userData1, void* userData2, void* userData3)
{
    (void)userData2;
    (void)userData3;

    // 拡張子がROMのファイルを処理する
    if((ib[0x0E] != 'R' && ib[0x0E] != 'r')
        || (ib[0x0F] != 'O' && ib[0x0F] != 'o')
        || (ib[0x10] != 'M' && ib[0x10] != 'm')) {
        return 0;
    }

    FileSelectContext* ctx = (FileSelectContext*)userData1;
    char* filename = ctx->filename[ctx->filenameSize];
    memcpy(filename, ib + 1, FILE_SYSTEM_FILE_NAME_LENGTH + FILE_SYSTEM_FILE_EXTENTION_LENGTH);
    filename[FILE_SYSTEM_FILE_NAME_LENGTH + FILE_SYSTEM_FILE_EXTENTION_LENGTH] = 0;
    ctx->filenameSize++;
    if(ctx->filenameSize >= FILE_SELECT_MAX) {
        // ファイル数オーバー
        return 1; // 列挙終わり
    }
    return 0;
}

/**
 * @brief ジョイスティックの状態を取得する
 */
static u8
GetKey() __naked
{
    __asm
    LD A,#1
    JP _GTSTCK
    __endasm;
}

/**
 * @brief ジョイスティックのトリガーAの状態を取得する
 */
static u8
GetTriggerA() __naked
{
    __asm
    LD A,#1
    JP _GTTRIG
    __endasm;
}

/**
 * @brief ジョイスティックのトリガーBの状態を取得する
 */
static u8
GetTriggerB() __naked
{
    __asm
    LD A,#3
    JP _GTTRIG
    __endasm;
}

/**
 * @brief 入力を取得する
 * 
 * @param[in,out]   ctx 入力のコンテキスト
 */
static void
input(KeyContext* ctx)
{
    const u8 trigger1 = GetTriggerA() ? INPUT_TRIGGER1 : 0x00;
    const u8 trigger2 = GetTriggerB() ? INPUT_TRIGGER2 : 0x00;
    const u8 key = GetKey();
    const u8 keyUp = ((key == 8) || (key == 1) || (key == 2)) ? INPUT_UP : 0x00;
    const u8 keyDown = ((key == 4) || (key == 5) || (key == 6)) ? INPUT_DOWN : 0x00;
    const u8 keyRight = (key == 3) ? INPUT_RIGHT : 0x00;

    ctx->previous = ctx->current;
    ctx->current = keyUp | keyDown | keyRight | trigger1 | trigger2;
    ctx->trigger = ctx->previous ^ ctx->current;
    ctx->pressed = ctx->trigger & ctx->current;
    ctx->released = ctx->trigger & ~ctx->current;
}

/**
 * @brief ファイルリストを描画する
 * 
 * @param[in]   ctx ファイル選択のコンテキスト
 */
static void
renderFilenameList(const FileSelectContext* ctx)
{
    for(u16 i = 0; i < FILE_SELECT_MAX; ++i) {
        const u16 pos = 1 + SCREEN_WIDTH + i * SCREEN_WIDTH;
        if(i < ctx->filenameSize) {
            char* filename = ctx->filename[i];
            msg(pos, 0x07, filename);
        } else {
            msg(pos, 0x07, "                ");
        }
    }
}

static void
renderDriveNo(const u8 driveNo)
{
    outp(0x3000 + 18, '0' + driveNo);
    outp(0x3000 + 19, ':');
}

/**
 * @brief ファイルリストの再読み込み
 * 
 * @param[in]   ctx ファイル選択のコンテキスト
 */
static void
reload(FileSelectContext* ctx)
{
    ctx->filenameSize = 0;
    x1_fileEnumerateInfomationBlock(ctx->driveNo, callbackEnumFile, ctx, 0, 0);
    x1_diskMortorOff(ctx->driveNo);
    renderFilenameList(ctx);
    renderDriveNo(ctx->driveNo);

    if(ctx->filenameSize == 0) {
        dispMsg("The file does not exist.");
    } else {
        dispMsg("                             ");
    }
}

/**
 * @brief ファイルを選択する
 * @param[out]      filename ファイル名
 * @param[in,out]   driveNo  ドライブ番号
 * @return 処理結果
 * @retval 0: ファイルが選択された
 * @retval 0以外: 選択されなかった
 */
u8
fileSelect(char* filename, u8* driveNo)
{
    // ガイド
    msg(1,                 6, "FILE SELECT");
    msg(1+21*SCREEN_WIDTH, 7, "UP/DOWN:SELECT RIGHT:CHANGE DRIVE");
    msg(1+22*SCREEN_WIDTH, 7, "A:DECIDE B:RELOAD");
    dispMsg("");
    errMsg("");

    FileSelectContext* ctx = (FileSelectContext*)0x8000;
    ctx->driveNo = *driveNo;
    ctx->key.previous = 0;
    ctx->key.current = 0;
    ctx->key.trigger = 0;
    ctx->key.pressed = 0;
    ctx->key.released = 0;
    reload(ctx);
    u16 index = 0;
    u16 preIndex = 0xFFFF;
    for(;;) {
        // 入力
        input(&ctx->key);
        // 色々処理
        if(ctx->key.pressed & INPUT_TRIGGER2) {
            // 再読み込み
            reload(ctx);
            index = 0;
        }
        if(ctx->key.pressed & INPUT_RIGHT) {
            // 再読み込み
            ctx->driveNo = 1 - ctx->driveNo;
            reload(ctx);
            index = 0;
        }
        if(ctx->filenameSize) {
            if(ctx->key.pressed & INPUT_DOWN) {
                // 下
                if(index + 1 >= ctx->filenameSize) {
                    index = 0;
                } else {
                    ++index;
                }
            }
            if(ctx->key.pressed & INPUT_UP) {
                // 上
                if(index == 0) {
                    index = ctx->filenameSize - 1;
                } else {
                    --index;
                }
            }
            if(ctx->key.pressed & INPUT_TRIGGER1) {
                // 決定

                // ファイル名 + "." + 拡張子にして格納
                memcpy(filename, ctx->filename[index], FILE_SYSTEM_FILE_NAME_LENGTH);
                filename[FILE_SYSTEM_FILE_NAME_LENGTH] = '.';
                memcpy(filename + FILE_SYSTEM_FILE_NAME_LENGTH + 1, ctx->filename[index] + FILE_SYSTEM_FILE_NAME_LENGTH, FILE_SYSTEM_FILE_EXTENTION_LENGTH);
                filename[FILE_SYSTEM_FILE_NAME_LENGTH + FILE_SYSTEM_FILE_EXTENTION_LENGTH + 1] = 0;

                msg(20, 7, filename);
                *driveNo = ctx->driveNo;

                return 0;
            }
        }
        // カーソル表示
        if(preIndex != index) {
            if(preIndex <= FILE_SELECT_MAX) {
                outp(0x3000 + SCREEN_WIDTH + SCREEN_WIDTH*preIndex, ' ');
            }
            if(ctx->filenameSize) {
                if(index <= FILE_SELECT_MAX) {
                    outp(0x3000 + SCREEN_WIDTH + SCREEN_WIDTH*index, '*');
                }
                preIndex = index;
            }
        }
    }
}
