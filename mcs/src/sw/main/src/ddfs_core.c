/*
 * ddfs_core.c
 *
 *  Created on: 8 Mar 2024
 *      Author: emire
 */

#include "ddfs_core.h"

void ddfs_set_carrier_freq(uint32_t ddfs_addr, int freq) {
	uint32_t p2n, fccw;
	float tmp;

	p2n = 1 << PW;
	tmp = (float)p2n / (float)SYS_CLK_FREQ;
	fccw = (uint32_t)(freq * tmp);

	io_write(ddfs_addr, REG_FCCW, fccw);
}

void ddfs_set_offset_freq(uint32_t ddfs_addr, int freq) {
	uint32_t p2n, focw;
	float tmp;

	p2n = 1 << PW;
	tmp = (float)p2n / (float)SYS_CLK_FREQ;
	focw = (uint32_t)(freq * tmp);

	io_write(ddfs_addr, REG_FOCW, focw);
}

void ddfs_set_phase_degree(uint32_t ddfs_addr, int phase) {
	uint32_t pha;

	pha = SYS_CLK_FREQ * phase/360;

	io_write(ddfs_addr, REG_PHA, pha);
}
