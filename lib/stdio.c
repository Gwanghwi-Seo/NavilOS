#include "stdint.h"
#include "HalUart.h"
#include "stdio.h"

uint32_t putstr(const char* s)
{
    uint32_t c = 0;
    while (*s)
    {
        Hal_uart_put_char(*s++);
        c++;
    }
    return c;
}

uint32_t debug_printf(const char* format, ...)
{
    va_list args;
    va_start(args, format);
    vsprintf(printf_buf, format, args);
    va_end(args);

    return putstr(printf_buf);
}