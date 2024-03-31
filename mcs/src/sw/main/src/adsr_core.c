/*
 * adsr_core.c
 *
 *  Created on: 8 Mar 2024
 *      Author: emire
 */

#include "adsr_core.h"

void adsr_start(uint32_t adsr_base_addr) {
	io_write(adsr_base_addr, REG_START, 0);
}

void adsr_set_env(uint32_t adsr_base_addr, int attack_ms, int decay_ms, int sustain_ms, int release_ms, float sustain_level) {
	uint32_t nc, step, sustain_abs;
	const uint32_t clks_per_ms = 0.001 * SYS_CLK_FREQ;

	// Sustain level: convert to absolute value.
	sustain_abs = (unsigned int)(MAX * sustain_level);
	io_write(adsr_base_addr, REG_SUSTAIN_LEVEL, sustain_abs);

	// Attack: convert attack_ms to envelope increment step.
	nc = attack_ms * clks_per_ms;
	step = MAX / nc;
	if (step == 0) {
		step = 1;
	}
	io_write(adsr_base_addr, REG_ATTACK, step);

	// Decay: convert decay_ms to envelope decrement step.
	nc = decay_ms * clks_per_ms;
	step = (MAX - sustain_abs) / nc;
	if (step == 0) {
		step = 1;
	}
	io_write(adsr_base_addr, REG_DECAY, step);

	// Sustain: convert sustain_ms to number of clocks.
	nc = sustain_ms * clks_per_ms;
	io_write(adsr_base_addr, REG_SUSTAIN, nc);

	// Release: convert release_ms to envelope decrement step.
	nc = release_ms * clks_per_ms;
	step = sustain_abs / nc;
	if (step == 0) {
		step = 1;
	}
	io_write(adsr_base_addr, REG_RELEASE, step);
}

int calc_note_freq(int note_i, int oct) {
	const float NOTES[] = {
			0,			// REST
			16.3516,	// 0 C
			17.3239,	// 1 C#
			18.3541,	// 2 D
			19.4454,	// 3 D#
			20.6017,	// 4 E
			21.8268,	// 5 F
			23.1247,	// 6 F#
			24.4997,	// 7 G
			25.9565,	// 8 G#
			27.5000,	// 9 A
			29.1352,	// 10 A#
			30.8677		// 11 B
	};

	int freq;

	freq = (unsigned int)(NOTES[note_i] * (1 << oct));
	return(freq);
}
