#include <int_types.h>

typedef struct fdt_header {
    u32 magic;
    u32 totalsize;
    u32 off_dt_struct;
    u32 off_dt_strings;
    u32 off_mem_rsvmap;
    u32 version;
    u32 last_comp_version;
    u32 boot_cpuid_phys;
    u32 size_dt_strings;
    u32 size_dt_struct;
} fdt_header;

void fdt_header_endian_fix(fdt_header* header);

typedef struct fdt_memory_res_block {
    uint64_t address;
    uint64_t size;
} fdt_memory_res_block;

void fdt_memory_res_block_endian_fix(fdt_memory_res_block* header);
