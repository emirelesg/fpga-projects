/*
 * main.c
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xiomodule.h"
#include "microblaze_sleep.h"
#include "io_init.h"
#include "ddfs_core.h"

int main()
{
    init_platform();

	Ddfs_set_offset_freq(io_s1_ddfs, 0);
	Ddfs_set_phase_degree(io_s1_ddfs, 0);

    while(1) {
    	for (uint32_t f = 200; f < 500; f += 1) {
			xil_printf("%d Hz\r\n", f);
			Ddfs_set_carrier_freq(io_s1_ddfs, f);
			usleep(50000); // 50 ms
		}
    	for (uint32_t f = 500; f > 200; f -= 1) {
			xil_printf("%d Hz\r\n", f);
			Ddfs_set_carrier_freq(io_s1_ddfs, f);
			usleep(50000); // 50 ms
		}

    	/*
    	for (uint32_t i = 0; i < 16; i += 1) {
    		xil_printf("%d data %x\r\n", i, io_read(get_slot_addr(IO_BASE_ADDR, 1), 0));
    		io_write(io_s0_gpo, 0, i);
    		usleep(100000); // 100 ms
    	}
    	*/
    }
}
