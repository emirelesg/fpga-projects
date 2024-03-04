/*
 * main.c
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xiomodule.h"
#include "microblaze_sleep.h"
#include "io_init.h"

int main()
{
    init_platform();

    while(1) {
    	for (uint32_t i = 0; i < 16; i += 1) {
    		xil_printf("%d data %x\r\n", i, io_read(get_slot_addr(IO_BASE_ADDR, 1), 0));
    		io_write(io_s0_gpo, 0, i);
    		usleep(100000);
    	}
    }
}
