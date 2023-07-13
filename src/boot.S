
#include "mm.h"

.section ".text.boot"

.global _start
_start:
    mov w10, w0

	mrs	x6, mpidr_el1
	and	x6, x0,#0xFF		// Check processor id
	cbz	x6, master		// Hang for all non-primary CPU
	b	proc_hang

proc_hang:
	b 	proc_hang

master:

	adr	x0, bss_begin
	adr	x1, bss_end
	sub	x1, x1, x0
	bl 	memzero

	mov w0, w10

	mov	sp, #LOW_MEMORY
	bl	overloader_main
	b 	proc_hang		// should never come here