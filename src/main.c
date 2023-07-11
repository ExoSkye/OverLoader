#include <stddef.h>
#include <endian.h>
#include <dtb.h>
#include <utils.h>

void kernel_main(uint64_t dtb_ptr32, uint64_t x1, uint64_t x2, uint64_t x3) {
    for (uint64_t x = dtb_ptr32; x < sizeof(fdt_header); x += 4) {
        *((uint32_t*)x) = swap_endian_32(*((uint32_t*)x));
    }

    fdt_header header = *((fdt_header *)dtb_ptr32);

    volatile uint32_t version = header.version;

    if (header.magic != 0xd00dfeed) {
        emergency_halt();
    }
}