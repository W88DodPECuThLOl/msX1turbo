/**
 * ■ROM容量16Kib以下
 * 
 * MAIN   page0 slot0  NEKO SYSTEM & msX1turbo
 * MEMROY page1 slot1  MSX rom 16KiB
 *        page2 slot0  VDP vram 16KiB
 *        page3 slot0  NEKO SYSTEM 8KiB + MSX ram 8KiB
 * BANK#0 page0        未使用
 *        page1        未使用
 * 
 * ■ROM容量32Kib以下
 * MAIN   page0 slot0  NEKO SYSTEM & msX1turboZ
 * MEMROY page1 slot1  MSX rom 16KiB
 *        page2 slot1  MSX rom 16KiB
 *        page3 slot0  NEKO SYSTEM 8KiB + MSX ram 8KiB
 * BANK#0 page0        NEKO SYSTEM & msX1turboZ
 *        page1        vram 16KiB
 */

#if __WIN32
#include <stdint.h>
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint16_t u32;
#else
#include <catZ80Lib.h>
#include <string.h>
#endif // __WIN32
#include "fileSelect.h"
#include "ipsPatch.h"
#include "msg.h"

extern void copyProgram();

#define ROM_ADDRESS 0x4000
#define PATCH_ADDRESS 0xC000

#define MEGA_ROM (0)

/**
 * @brief FAT用のバッファ
 */
static u8 fatBuffer[FILE_SYSTEM_MAX_FAT_RECORD_COUNT * DISK_SECTOR_SIZE];

/**
 * @brief 読み書き用のバッファ
 */
static u8 readWriteBuffer[DISK_SECTOR_SIZE];

extern void executeProgram(const char* filename);

/**
 * @brief ファイルの列挙時に呼び出される物
 * @param ib インフォメーションブロック
 * @param[in] userData1 ファイル名と拡張子
 * @param[out] userData2 ファイルサイズ
 * @param userData3 
 * @return 処理結果
 */
static u8
callbackEnumFileSize(const u8* ib, void* userData1, void* userData2, void* userData3)
{
    if((memcmp(ib+1, userData1, FILE_SYSTEM_FILE_NAME_LENGTH) == 0)
        && (memcmp(ib+1 + FILE_SYSTEM_FILE_NAME_LENGTH, (u8*)userData1 + FILE_SYSTEM_FILE_NAME_LENGTH + 1, FILE_SYSTEM_FILE_EXTENTION_LENGTH) == 0)) {
        *((u16*)userData2) = x1_fileGetInfomationBlockFileSize(ib);
        *((u8*)userData3) = 1;
        return 1; // 列挙終わり
    }
    *((u16*)userData2) = 0;
    *((u8*)userData3) = 0;
    return 0;
}

/**
 * @brief ファイルサイズを取得する
 * 
 * @param[in] driveNo ドライブ番号(0-3)
 * @param filename 
 * @param fileSize 
 * @return 
 */
u8
getFileSize(const u8 driveNo, const char* filename, u16* fileSize)
{
    *fileSize = 0;
    u8 found = 0;
    x1_fileSetCurrentDriveNo(driveNo);
    const u8 res = x1_fileEnumerateInfomationBlock(driveNo, callbackEnumFileSize, filename, fileSize, &found);
    x1_diskMortorOff(driveNo);
    if(res != FILE_SYSTEM_SUCCESS) {
        return res;
    }
    if(found == 0) {
        return FILE_SYSTEM_ERROR_FILE_NOT_FOUND;
    }
    return FILE_SYSTEM_SUCCESS;
}

/**
 * @brief ファイルが存在しているかどうか
 * @param[in] driveNo ドライブ番号(0-3)
 * @param filename 
 * @return 
 */
u8
existFile(const u8 driveNo, const char* filename)
{
    u16 fileSize = 0;
    u8 found = 0;
    x1_fileSetCurrentDriveNo(driveNo);
    const u8 res = x1_fileEnumerateInfomationBlock(driveNo, callbackEnumFileSize, filename, &fileSize, &found);
    x1_diskMortorOff(driveNo);
    if(res != FILE_SYSTEM_SUCCESS) {
        return res;
    }
    return (found != 0) ? 1 : 0;
}

static void
internalPatch(u16 startAddress, u16 size)
{
    for(u16 addr = startAddress + 0x0010; addr < startAddress + size; ++addr) {
        if(*(u16*)addr == 0x79ED || *(u16*)addr == 0x98D3) {
            // OUT (C),A
            // OUT (0x98),A
            *(u16*)addr = 0x77C7; // RST #0x00 : LD 0(IX),A
        } else if(*(u16*)addr == 0x78ED) {
            // IN A,(C)
            *(u16*)addr = 0x7EC7; // RST #0x00 : LD A,0(IX)
        }
#if 0
        else if(*(u16*)addr == 0x41ED) {
            // OUT (C),B
            *(u16*)addr = 0x70C7; // RST #0x00 : LD 0(IX),B
        } else if(*(u16*)addr == 0x49ED) {
            // OUT (C),C
            *(u16*)addr = 0x71C7; // RST #0x00 : LD 0(IX),C
        }
//#endif
        else if(*(u16*)addr == 0x51ED) {
            // OUT (C),D
            *(u16*)addr = 0x72C7; // RST #0x00 : LD 0(IX),D
        } else if(*(u16*)addr == 0x59ED) {
            // OUT (C),E
            *(u16*)addr = 0x73C7; // RST #0x00 : LD 0(IX),E
        } else if(*(u16*)addr == 0x61ED) {
            // OUT (C),H
            *(u16*)addr = 0x74C7; // RST #0x00 : LD 0(IX),H
        } else if(*(u16*)addr == 0x69ED) {
            // OUT (C),L
            *(u16*)addr = 0x75C7; // RST #0x00 : LD 0(IX),L
        }
        else if(*(u16*)addr == 0xB3ED) {
            // OTIR
            *(u16*)addr = 0x0000; // NOP
        } else if(*(u16*)addr == 0xBBED) {
            // OTDR
            *(u16*)addr = 0x0000; // NOP
        }
#endif
        else if(*(u16*)addr == 0xA3ED) {
            // OUTI
            *(u16*)addr = 0x00CF; // RST #0x08 : NOP
        }
#if 0
        else if(*(u16*)addr == 0xABED) {
            // OUTD
            *(u16*)addr = 0x0000; // NOP
        }
        else if(*(u16*)addr == 0x40ED) {
            // IN B,(C)
            *(u16*)addr = 0x46C7; // RST #0x00 : LD B,0(IX)
        } else if(*(u16*)addr == 0x48ED) {
            // IN C,(C)
            *(u16*)addr = 0x4EC7; // RST #0x00 : LD C,0(IX)
        } else if(*(u16*)addr == 0x50ED) {
            // IN D,(C)
            *(u16*)addr = 0x56C7; // RST #0x00 : LD D,0(IX)
        } else if(*(u16*)addr == 0x58ED) {
            // IN E,(C)
            *(u16*)addr = 0x5EC7; // RST #0x00 : LD E,0(IX)
        } else if(*(u16*)addr == 0x60ED) {
            // IN H,(C)
            *(u16*)addr = 0x66C7; // RST #0x00 : LD H,0(IX)
        } else if(*(u16*)addr == 0x68ED) {
            // IN H,(C)
            *(u16*)addr = 0x6EC7; // RST #0x00 : LD L,0(IX)
        }
#endif
        else if(*(u16*)addr == 0x56ED) {
            // IM 1
            *(u16*)addr = 0x0000; // NOP
        }
#if defined(MEGA_ROM) && !!MEGA_ROM
        else if(*addr == 0x32 && *(u16)(addr+1) == 0x6000) {
            // LD (0x6000),A
            *addr = 0xCD;
            *(u16*)(addr + 1) = (u16)0x0315; // copy8KiBFromEmm0ToMem6000;
        }
        else if(*addr == 0x32 && *(u16)(addr+1) == 0x8000) {
            // LD (0x8000),A
            *addr = 0xCD;
            *(u16*)(addr + 1) = (u16)0x0318; // copy8KiBFromEmm0ToMem8000;
        }
        else if(*addr == 0x32 && *(u16)(addr+1) == 0xA000) {
            // LD (0xA000),A
            *addr = 0xCD;
            *(u16*)(addr + 1) = (u16)0x031B; // copy8KiBFromEmm0ToMemA000;
        }
#endif
    }
}

/**
 * @brief EMM0をチェックする
 * @param[in] checkEMM0Address  EMM0のチェックするアドレス
 * @return チェック結果
 * @retval 0: 駄目だった
 * @retval 0以外: 大丈夫
 */
static u8
hasEMM0(const u32 checkEMM0Address)
{
    const u8 saveValue = x1_readByteFromEmm0(checkEMM0Address);
    for(u8 i = 0; i < 16; ++i) {
        // 書き込む
        x1_setEmm0Address(checkEMM0Address);
        outp(0x0D03, i);
        // 読み込んでチェック
        if(i != x1_readByteFromEmm0(checkEMM0Address)) {
            return 0; // 書き込めてないので駄目
        }
    }
    // 元に戻す
    x1_setEmm0Address(checkEMM0Address);
    outp(0x0D03, saveValue);
    return 1;
}

/**
 * @brief 分割ファイルのファイル名を生成する
 * @param[out] filename 分割ファイルのファイル名
 * @param[in] baseFilename ベースとなるファイル名
 * @param[in] index 分割ファイルのインデックス
 */
static void
makeSplitFilename(char* filename, const char* baseFilename, const u8 index)
{
    memcpy(filename, baseFilename, FILE_SYSTEM_FILE_NAME_LENGTH + FILE_SYSTEM_FILE_EXTENTION_LENGTH + 2);
    if(index != 0) {
        // 拡張子を".001"、".002"のようにする
        filename[FILE_SYSTEM_FILE_NAME_LENGTH + 1] = '0';
        filename[FILE_SYSTEM_FILE_NAME_LENGTH + 2] = '0' + (index / 10);
        filename[FILE_SYSTEM_FILE_NAME_LENGTH + 3] = '0' + (index % 10);
    }
}

/**
 * @brief 分割されたファイルかどうか
 * 
 * @param[in] driveNo ドライブ番号(0-3)
 * @param[in] baseFilename 分割のベースとなるファイル名
 * @return 分割されたファイルかどうか
 * @retval 0 : 分割されてないファイル
 * @retval 0以外 : 分割されたファイル
 */
static u8
isSplitFile(const u8 driveNo, const char* baseFilename)
{
    char filename[FILE_SYSTEM_FILE_NAME_LENGTH + FILE_SYSTEM_FILE_EXTENTION_LENGTH + 2];
    // 1個目の分割ファイルのファイル名を作成して
    makeSplitFilename(filename, baseFilename, 1);
    // それが存在するかどうかで判定
    return existFile(driveNo, filename);
}

/**
 * @brief 分割されたファイルの読み込み
 * 
 * @param[in] driveNo ドライブ番号(0-3)
 * @param[in] baseFilename 分割のベースとなるファイル名
 * @return 処理結果
 * @retval 0 : 成功
 * @retval 1 : 失敗
 */
static u8
splitFileRead(const u8 driveNo, const char* baseFilename)
{
    if(!hasEMM0(0)) {
        // EMM0が無かった
        errMsg("There are no EMM0 devices.");
        return 1;
    }
    x1_fileSetCurrentDriveNo(driveNo);

    u16 fileSize = 0;
    for(s8 index = 7; index >= 0; --index) {
        char filename[FILE_SYSTEM_FILE_NAME_LENGTH + FILE_SYSTEM_FILE_EXTENTION_LENGTH + 2];
        makeSplitFilename(filename, baseFilename, index);
        if(getFileSize(driveNo, filename, &fileSize) == FILE_SYSTEM_SUCCESS) {
            if(fileSize != 0x8000) {
                errMsg("The file size is not 32 KiB.");
                return 1; // 32KiBじゃないと駄目
            }
            dispMsg(filename);
            if(x1_fileReadFile(filename, (void*)ROM_ADDRESS) != FILE_SYSTEM_SUCCESS) {
                errMsg("File load failed.");
                return 1; // 読み込み失敗
            }
            // EMM0にコピー
            u32 emmAddress = (u32)index * (u32)0x8000;
            if(!hasEMM0(emmAddress)) {
                // EMM0の容量が足りない
                errMsg("There is not enough capacity on EMM0.");
                return 1;
            }
            dispMsg("Copy to EMM0.");
            x1_copyToEmm0(emmAddress, (u8*)ROM_ADDRESS, fileSize);
        }
    }
    return 0;
}

static u8
normalFileRead(const u8 driveNo, const char* filename, u8* sys)
{
    x1_fileSetCurrentDriveNo(driveNo);

    u16 fileSize = 0;
    if(getFileSize(driveNo, filename, &fileSize) != FILE_SYSTEM_SUCCESS) {
        errMsg("File load failed.");
        return 1; // 失敗
    }
    if(fileSize > 0x8000) {
        errMsg("The file size is larger than 32 KiB.");
        return 1; // ファイルサイズが大きい
    }
    if(fileSize <= 0x4000) {
        *sys = 0; // 16KiB以下
    } else {
        *sys = 1;
    }
    // 32KiB以下
    // 0x4000～に読み込む
    if(x1_fileReadFile(filename, (void*)ROM_ADDRESS) != FILE_SYSTEM_SUCCESS) {
        errMsg("File load failed.");
        return 1; // 読み込み失敗
    }
    return 0;
}

/**
 * @brief ファイル読み込み
 * @param[in] filename ファイル名
 */
static u8
fileRead(const u8 driveNo, const char* filename, u8* sys)
{
    // ・32KiB以下なら0x4000～0xBFFFに読み込む
    // ・分割ファイルならEMM0に読み込んで、最初の32KiBを0x4000～0xBFFFにコピーする
    if(isSplitFile(driveNo, filename)) {
        // 分割ファイルを読み込む
        dispMsg("Loading the split files.");
        *sys = 1;
        return splitFileRead(driveNo, filename);
    } else {
        // 通常のファイルを読み込む
        dispMsg("Loading the file.");
        return normalFileRead(driveNo, filename, sys);
    }
}

static u8
patch(const u8 driveNo, const char* patchFilename, const u32 patchTargetFilesize)
{
    if(patchTargetFilesize > 0x8000) {
        // パッチ当てれるのは32KiB以下
        return 0;
    }

    u16 patchFileSize = 0;
    if(getFileSize(driveNo, patchFilename, &patchFileSize) == FILE_SYSTEM_SUCCESS) {
        dispMsg("Apply the patch to memory.");
        if(patchFileSize > 0x4000) {
            // パッチのファイルサイズが大きい
            errMsg("The patch file size is larger than 16 KiB.");
            return 1;
        }
        // パッチファイル読み込み
        if(x1_fileReadFile(patchFilename, (void*)PATCH_ADDRESS) != FILE_SYSTEM_SUCCESS) {
            errMsg("The patch file load failed.");
            return 1; // 読み込み失敗
        }
        if(ipsPatch((u8*)ROM_ADDRESS, (void*)PATCH_ADDRESS, patchFileSize) != 0) {
            errMsg("Patch failed.");
            return 1; // 適応失敗
        }
    } else {
        // パッチファイルが無ければ、自動パッチを当てる
        internalPatch((u16)ROM_ADDRESS, patchTargetFilesize);
    }
    return 0;
}

static u8
fileSelectReadAndPatch(u8* driveNo)
{
    u8 sys = 0;
    x1_fileInitialize(fatBuffer, readWriteBuffer);
    char filename[FILE_SYSTEM_FILE_NAME_LENGTH + FILE_SYSTEM_FILE_EXTENTION_LENGTH + 2];
    for(;;) {
        memcpy(filename, "AUTOEXEC     .ROM", 13+1+3+1);
        if(fileRead(*driveNo, filename, &sys) != 0) {
            for(;;) {
                // ファイル選択
                if(fileSelect(filename, driveNo) != 0) {
                    continue;
                }
                // ファイル読み込み
                if(fileRead(*driveNo, filename, &sys) != 0) {
                    continue;
                }
                break;
            }
        }
        // パッチ
        filename[FILE_SYSTEM_FILE_NAME_LENGTH + 1 + 0] = 'i';
        filename[FILE_SYSTEM_FILE_NAME_LENGTH + 1 + 1] = 'p';
        filename[FILE_SYSTEM_FILE_NAME_LENGTH + 1 + 2] = 's';
        if(patch(*driveNo, filename, 0x8000) != 0) {
            continue;
        }
        break;
    }

    x1_diskMortorOff(*driveNo);
    x1_fileTerminate();
    return sys;
}

/**
 * @brief モジュールを読み込む
 * 
 * @param[in]   filename    読み込むプログラム名
 */
void
loadModule(const char* filename) __naked
{
    (void)filename;
    __asm
    PUSH HL
    LD DE,#_readWriteBuffer
    LD HL,#_fatBuffer
    CALL _x1_fileInitialize
    POP HL
    LD DE,#0xC000
    CALL _x1_fileReadFile
    XOR A
    CALL _x1_diskMortorOff
    CALL _x1_fileTerminate

    ; VRAMへ転送する
    LD HL,#0xC000
    LD BC,#0x4000
    LD DE,#0x2000
loadModule_LOOP:
    LD A,(HL)
    OUT (C),A
    INC HL
    INC BC
    DEC DE
    LD A,D
    OR E
    JR NZ,loadModule_LOOP
    RET
    __endasm;
}

/**
 * @brief プログラムを読み込んで実行する
 * 
 * @param[in]   filename    読み込むプログラム名
 */
void
executeProgram(const char* filename) __naked
{
    (void)filename;
    __asm
    LD SP,#0x1000
    PUSH HL
    LD DE,#_readWriteBuffer
    LD HL,#_fatBuffer
    CALL _x1_fileInitialize
    POP HL
    LD DE,#0xC000
    CALL _x1_fileReadFile
    XOR A
    CALL _x1_diskMortorOff
    CALL _x1_fileTerminate

    LD HL,#0xC000
    LD DE,#0x1000
    LD BC,#0x3000
    JP _copyProgram
    __endasm;
}

u8
main()
{
    // ファイル選択、読み込み、パッチの適応など
    u8 driveNo = 0;
    const u8 sys = fileSelectReadAndPatch(&driveNo);
    if(sys == 0) {
        // モジュールをVRAMへ読み込み
        // ・本体側で適切にコピーすること
        loadModule("A:vdp.mod");
        // 本体読み込んで実行
        executeProgram("A:msX1turbo.BIN");
        // ここには戻ってこない
    } else {
        // モジュールをVRAMへ読み込み
        // ・本体側で適切にコピーすること
        loadModule("A:vdpZ.mod");
        // 本体読み込んで実行
        executeProgram("A:msX1turboZ.BIN");
        // ここには戻ってこない
    }
    return 0;
}
