.globl swap_endian_16
swap_endian_16:
    rev16 x0,x0
    ret

.globl swap_endian_32
swap_endian_32:
    rev x0,x0
    ret

.globl swap_endian_64
swap_endian_64:
    rev64 x0,x0
    ret

