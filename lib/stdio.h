#ifndef LIB_STDIO_H_
#define LIB_STDIO_H_

#include "stdint.h"

uint32_t putstr(const char* s);
uint32_t debug_printf(const char* format, ...);

#endif /* LIB_STDIO_H_ */