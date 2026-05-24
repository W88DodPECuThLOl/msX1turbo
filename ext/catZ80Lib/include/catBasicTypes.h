#ifndef INCL_CatBasicTypes__h
#define INCL_CatBasicTypes__h

#if _WIN32

#include <stdint.h>
typedef uint8_t  u8;
typedef int8_t   s8;
typedef char     c8;
typedef uint16_t u16;
typedef int16_t  s16;
typedef uint32_t u32;
typedef int32_t  s32;
typedef uint64_t u64;
typedef int64_t  s64;

#elif defined (SDCC) || defined (__SDCC)

typedef unsigned char      u8;
typedef signed   char      s8;
typedef signed   char      c8;
typedef unsigned int       u16;
typedef signed   int       s16;
typedef unsigned long      u32;
typedef signed   long      s32;
typedef unsigned long long u64;
typedef signed   long long s64;

#elif defined(__clang__) && __clang__ != 0

#else

#endif

_Static_assert(sizeof(u8) == 1,  "sizeof(u8) == 1");
_Static_assert(sizeof(s8) == 1,  "sizeof(s8) == 1");
_Static_assert(sizeof(c8) == 1,  "sizeof(c8) == 1");
_Static_assert(sizeof(u16) == 2, "sizeof(u16) == 2");
_Static_assert(sizeof(s16) == 2, "sizeof(s16) == 2");
_Static_assert(sizeof(u32) == 4, "sizeof(u32) == 4");
_Static_assert(sizeof(s32) == 4, "sizeof(s32) == 4");
_Static_assert(sizeof(u64) == 8, "sizeof(u64) == 8");
_Static_assert(sizeof(s64) == 8, "sizeof(s64) == 8");

#endif // INCL_CatBasicTypes__h
