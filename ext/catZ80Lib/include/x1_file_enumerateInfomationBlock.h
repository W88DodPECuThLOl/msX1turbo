#ifndef INCL_x1_file_enumerateInfomationBlock__h
#define INCL_x1_file_enumerateInfomationBlock__h

#include "catBasicTypes.h"

typedef u8(*X1_FILE_CALLBACK_ENUMERATE_IB)(const u8* ib, void* userData1, void* userData2, void* userData3);

u8 x1_fileEnumerateInfomationBlock(u8 driveNo, X1_FILE_CALLBACK_ENUMERATE_IB funcCallback, void* userData1, void* userData2, void* userData3);

#endif // INCL_x1_file_enumerateInfomationBlock__h
