#ifndef INCL_z80_inp__h
#define INCL_z80_inp__h

#if defined(__SDCC_z80)
#include "catBasicTypes.h"
u8 inp(u16 portAddress);
#else
#include <stdlib.h>
#endif

#endif // INCL_z80_inp__h
