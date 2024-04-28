/*
 * ddfs_core.h
 *
 *  Created on: 8 Mar 2024
 *      Author: emire
 */

#ifndef SRC_DDFS_CORE_H_
#define SRC_DDFS_CORE_H_

#include <stdio.h>
#include "io_init.h"

#define PW 30 // Phase width
#define DDFS_EN_FREQ 96000 // 96 kHz
#define ENV_MAX 0x4000 // // 2^15

enum {
	REG_FCCW = 0,
	REG_FOCW = 1,
	REG_PHA = 2,
	REG_ENV = 3,
	REG_CTRL = 4
};

void ddfs_set_wave_type(uint32_t ddfs_addr, int wave_type);
void ddfs_set_env_source(uint32_t ddfs_addr, int channel);
void ddfs_set_env(uint32_t ddfs_addr, float env);
void ddfs_set_carrier_freq(uint32_t ddfs_addr, int freq);
void ddfs_set_offset_freq(uint32_t ddfs_addr, int freq);
void ddfs_set_phase_degree(uint32_t ddfs_addr, int phase);

#endif /* SRC_DDFS_CORE_H_ */
