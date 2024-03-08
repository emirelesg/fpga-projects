/*
 * adsr_core.h
 *
 *  Created on: 8 Mar 2024
 *      Author: emire
 */

#ifndef SRC_ADSR_CORE_H_
#define SRC_ADSR_CORE_H_

#include <stdio.h>
#include "io_rw.h"

enum {
	REG_START = 0,
	REG_ATTACK = 1,
	REG_DECAY = 2,
	REG_SUSTAIN = 3,
	REG_SUSTAIN_LEVEL = 4,
	REG_RELEASE = 5
};

enum {
	MAX = 0x7fffffff
};

enum {
	NOTE_C,
	NOTE_Cs,
	NOTE_D,
	NOTE_Ds,
	NOTE_E,
	NOTE_F,
	NOTE_Fs,
	NOTE_G,
	NOTE_Gs,
	NOTE_A,
	NOTE_As,
	NOTE_B
};

void adsr_start(uint32_t adsr_base_addr);
void adsr_set_env(uint32_t adsr_base_addr, int attack_ms, int decay_ms, int sustain_ms, int release_ms, float sustain_level);
int calc_note_freq(int note_i, int oct);

#endif /* SRC_ADSR_CORE_H_ */
