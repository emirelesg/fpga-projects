/*
 * ddfs_core.h
 *
 *  Created on: 8 Mar 2024
 *      Author: emire
 */

#ifndef SRC_DDFS_CORE_H_
#define SRC_DDFS_CORE_H_

#include <stdio.h>
#include "io_rw.h"

enum {
	FCCW_REG = 0,
	FOCW_REG = 1,
	PHA_REG = 2
};

enum {
	PW = 30
};

void Ddfs_set_carrier_freq(uint32_t slot_addr, int freq);
void Ddfs_set_offset_freq(uint32_t slot_addr, int freq);
void Ddfs_set_phase_degree(uint32_t slot_addr, int phase);

#endif /* SRC_DDFS_CORE_H_ */
