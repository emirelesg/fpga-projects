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

#define PW 30 // Phase width

enum {
	REG_FCCW = 0,
	REG_FOCW = 1,
	REG_PHA = 2
};

void ddfs_set_carrier_freq(uint32_t ddfs_addr, int freq);
void ddfs_set_offset_freq(uint32_t ddfs_addr, int freq);
void ddfs_set_phase_degree(uint32_t ddfs_addr, int phase);

#endif /* SRC_DDFS_CORE_H_ */
