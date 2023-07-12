#include <dtb.h>
#include <endian.h>

void fdt_header_endian_fix(fdt_header* header) {
    header->magic = swap_endian_32(header->magic);
    header->totalsize = swap_endian_32(header->totalsize);
    header->off_dt_struct = swap_endian_32(header->off_dt_struct);
    header->off_dt_strings = swap_endian_32(header->off_dt_strings);
    header->off_mem_rsvmap = swap_endian_32(header->off_mem_rsvmap);
    header->version = swap_endian_32(header->version);
    header->last_comp_version = swap_endian_32(header->last_comp_version);
    header->boot_cpuid_phys = swap_endian_32(header->boot_cpuid_phys);
    header->size_dt_strings = swap_endian_32(header->size_dt_strings);
    header->size_dt_struct = swap_endian_32(header->size_dt_struct);
}

void fdt_memory_res_block_endian_fix(fdt_memory_res_block* block) {
    block->address = swap_endian_64(block->address);
    block->size = swap_endian_64(block->size);
}