#include "stdint.h"

/**
 * _cdecl Calling Convention:
 * 1. Parameter Passing: Arguments are pushed onto the stack from right to left 
 *    (e.g., 'page' is pushed first, then 'c').
 * 2. Stack Cleanup: The Caller is responsible for cleaning up the stack after the call.
 * 3. Name Mangling: The compiler prefixes the function name with an underscore 
 *    ('_x86_Video_WriteCharTeletype') to match the assembly label.
 * 4. Offset Logic: This convention is why [bp+4] accesses 'c' and [bp+6] accesses 'page' 
 *    in the 16-bit assembly implementation.
 */
void _cdecl x86_Video_WriteCharTeletype(char c, uint8_t page);
void _cdecl x86_div64_32(uint64_t dividend, uint32_t divisor, uint64_t* quotientOut, uint32_t* remainderOut);
