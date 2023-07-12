#include <stddef.h>
#include <endian.h>
#include <dtb.h>
#include <utils.h>

void kernel_main(u64 dtb_ptr32, u64 x1, u64 x2, u64 x3) {
    fdt_header header = *((fdt_header*)dtb_ptr32);

    fdt_header_endian_fix(&header);

    if (header.magic != 0xd00dfeed) {
        emergency_halt();
    }

    u64 cur_address = dtb_ptr32 + header.off_mem_rsvmap;

    while (1) {
        fdt_memory_res_block res_block = *((fdt_memory_res_block*)cur_address);
        fdt_memory_res_block_endian_fix(&res_block);

        if (res_block.size == 0 && res_block.address == 0) {
            break;
        }

        cur_address += sizeof(fdt_memory_res_block);
    }
}