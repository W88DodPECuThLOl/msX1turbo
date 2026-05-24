#ifndef INCL_z80_outp__h
#define INCL_z80_outp__h

#if defined(__SDCC_z80)
#include "catBasicTypes.h"
void outp(u16 portAddress, u8 value);
#else
#include <stdlib.h>
#endif

#endif // INCL_z80_outp__h
