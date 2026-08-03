#ifndef INCL_catZ80Lib__h
#define INCL_catZ80Lib__h

#include "catBasicTypes.h"

#if !defined(CAT_Z80_LIB_DISABLE_Z80_FUNCTIONS)
#include "z80_inp.h"
#include "z80_decode_LZE.h"
#include "z80_outp.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_Z80_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_SOS_FUNCTIONS)
#include "sos_msx.h"
#include "sos_loc.h"
#include "sos_printf.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_SOS_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_X1_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_X1_EMM_FUNCTIONS)
#include "x1_emm0_copyFromEmm0.h"
#include "x1_emm0_copyToEmm0.h"
#include "x1_emm0_copyToBank0FromEmm0.h"
#include "x1_emm0_copyToBank1FromEmm0.h"
#include "x1_emm0_readByteFromEmm0.h"
#include "x1_emm0_setEmm0Address.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_X1_EMM_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_X1_CRTC_FUNCTIONS)
#include "x1_crtc_waitVBlank.h"
#include "x1_crtc_setPCG.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_X1_CRTC_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_X1_DMA_FUNCTIONS)
#include "x1_dma_reset.h"
#include "x1_dma_fillVRAM.h"
#include "x1_dma_copyMemoryToVRAM.h"
#include "x1_dma_textClearScreen40.h"
#include "x1_dma_graphicsClearScreen.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_X1_DMA_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_X1_GRAPHICS_FUNCTIONS)
#include "x1_gra_setPaletteZ.h"
#include "x1_gra_setVRAMAccessBank.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_X1_GRAPHICS_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_X1_JOYSTICK_FUNCTIONS)
#include "x1_joy_readJoyStick.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_X1_JOYSTICK_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_X1_SUBCPU_FUNCTIONS)
#include "x1_subCpu_gameKeyRead.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_X1_SUBCPU_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_X1_ETC_FUNCTIONS)
#include "x1_portAddress.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_X1_ETC_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_X1_FDC_FUNCTIONS)
#include "x1_fdc_def.h"
#include "x1_fdc_mortorOff.h"
#include "x1_fdc_mortorOn.h"
#include "x1_fdc_readData.h"
#include "x1_fdc_restore.h"
#include "x1_fdc_seek.h"
#include "x1_fdc_status.h"
#include "x1_fdc_step.h"
#include "x1_fdc_stepIn.h"
#include "x1_fdc_stepOut.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_X1_FDC_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_X1_DISK_FUNCTIONS)
#include "x1_disk_def.h"
#include "x1_disk_initialize.h"
#include "x1_disk_mortorOff.h"
#include "x1_disk_readRecord.h"
#include "x1_disk_readRecords.h"
#include "x1_disk_seek.h"
#include "x1_disk_waitForNotBusy.h"
#include "x1_disk_waitForReady.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_X1_DISK_FUNCTIONS)

#if !defined(CAT_Z80_LIB_DISABLE_X1_FILE_FUNCTIONS)
#include "x1_file_getCurrentDriveNo.h"
#include "x1_file_getDriveNameFromFilename.h"
#include "x1_file_getDriveNoFromFilename.h"
#include "x1_file_getFileInfomationBlock.h"
#include "x1_file_getFileSize.h"
#include "x1_file_initialize.h"
#include "x1_file_normalizeFileName.h"
#include "x1_file_readFat.h"
#include "x1_file_readFile.h"
#include "x1_file_setCurrentDriveNo.h"
#include "x1_file_terminate.h"
#include "x1_file_enumerateInfomationBlock.h"
#include "x1_fs_def.h"
#endif // !defined(CAT_Z80_LIB_DISABLE_X1_FILE_FUNCTIONS)
#endif // !defined(CAT_Z80_LIB_DISABLE_X1_FUNCTIONS)

#endif // INCL_catZ80Lib__h
