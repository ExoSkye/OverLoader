#include <stddef.h>
#include <endian.h>
#include <dtb.h>
#include <utils.h>

void kernel_main(u64 dtb_ptr32, u64 x1, u64 x2, u64 x3) {
    fdt_header header = *((fdt_header *)dtb_ptr32);

    header.magic = swap_endian_32(header.magic);

    volatile uint32_t version = swap_endian_32(header.version);

    if (header.magic != 0xd00dfeed) {
        emergency_halt();
    }
}