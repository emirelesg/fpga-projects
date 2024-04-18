/*
 * ddfs_core.c
 *
 *  Created on: 8 Mar 2024
 *      Author: emire
 */

#include "ddfs_core.h"

void ddfs_set_env_source(uint32_t ddfs_addr, int channel) {
	uint32_t ctrl_reg;

	ctrl_reg = io_read(ddfs_addr, 0) & 0x0000000f;

	if (channel == 1) {
		bit_set(ctrl_reg, 0);
	} else {
		bit_clear(ctrl_reg, 0);
	}

	io_write(ddfs_addr, REG_CTRL, ctrl_reg);
}

void ddfs_set_env(uint32_t ddfs_addr, float env) {
	int32_t env_q214;
	float max_amp;

	max_amp = (float)(ENV_MAX);
	env_q214 = (int)(env * max_amp);

	io_write(ddfs_addr, REG_ENV, env_q214);
}

void ddfs_set_carrier_freq(uint32_t ddfs_addr, int freq) {
	uint32_t p2n, fccw;
	float tmp;

	p2n = 1 << PW;
	tmp = (float)p2n / (float)DDFS_EN_FREQ;
	fccw = (uint32_t)(freq * tmp);

	io_write(ddfs_addr, REG_FCCW, fccw);
}

void ddfs_set_offset_freq(uint32_t ddfs_addr, int freq) {
	uint32_t p2n, focw;
	float tmp;

	p2n = 1 << PW;
	tmp = (float)p2n / (float)DDFS_EN_FREQ;
	focw = (uint32_t)(freq * tmp);

	io_write(ddfs_addr, REG_FOCW, focw);
}

void ddfs_set_phase_degree(uint32_t ddfs_addr, int phase) {
	uint32_t pha;

	pha = DDFS_EN_FREQ * phase/360;

	io_write(ddfs_addr, REG_PHA, pha);
}
