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
#include "adsr_core.h"

void ddfs_test() {
	ddfs_set_offset_freq(io_s1_ddfs, 0);
	ddfs_set_phase_degree(io_s1_ddfs, 0);
	for (uint32_t f = 200; f < 500; f += 1) {
		// xil_printf("%d Hz\r\n", f);
		ddfs_set_carrier_freq(io_s1_ddfs, f);
		usleep(50000); // 50 ms
	}
	for (uint32_t f = 500; f > 200; f -= 1) {
		// xil_printf("%d Hz\r\n", f);
		ddfs_set_carrier_freq(io_s1_ddfs, f);
		usleep(50000); // 50 ms
	}
}

void gpo_test() {
	for (uint32_t i = 0; i < 16; i += 1) {
		// xil_printf("%d\r\n", i);
		io_write(io_s0_gpo, 0, i);
		usleep(100000); // 100 ms
	}
}

void adsr_test() {
	int freq;

	freq = calc_note_freq(9, 4); // A4

	ddfs_set_offset_freq(io_s1_ddfs, 0);
	ddfs_set_phase_degree(io_s1_ddfs, 0);
	ddfs_set_carrier_freq(io_s1_ddfs, freq);

	while(1) {
		// xil_printf("Go! %d Hz\r\n", freq);
		adsr_start(io_s2_adsr);
		usleep(1000000); // 1000 ms
	}
}

void adsr_dracula() {
	int freq, note_duration, sustain_ms;

	const int tempo = 120;
	const int full_note_duration = (60000 * 4) / tempo; // In ms
	const int melody[][3] = {
		{NOTE_A, 4, -4},
		{NOTE_A, 4, -4},
		{NOTE_A, 4, 16},
		{NOTE_A, 4, 16},
		{NOTE_A, 4, 16},
		{NOTE_A, 4, 16},
		{NOTE_F, 4, 8},
		{REST, 0, 8},
		{NOTE_A, 4, -4},
		{NOTE_A, 4, -4},
		{NOTE_A, 4, 16},
		{NOTE_A, 4, 16},
		{NOTE_A, 4, 16},
		{NOTE_A, 4, 16},
		{NOTE_F, 4, 8},
		{REST, 0, 8},
		{NOTE_A, 4, 4},
		{NOTE_A, 4, 4},
		{NOTE_A, 4, 4},
		{NOTE_F, 4, -8},
		{NOTE_C, 5, 16},
		{NOTE_A, 4, 4},
		{NOTE_F, 4, -8},
		{NOTE_C, 5, 16},
		{NOTE_A, 4, 2},
		{NOTE_E, 5, 4},
		{NOTE_E, 5, 4},
		{NOTE_E, 5, 4},
		{NOTE_F, 5, -8},
		{NOTE_C, 5, 16},
		{NOTE_A, 4, 4},
		{NOTE_F, 4, -8},
		{NOTE_C, 5, 16},
		{NOTE_A, 4, 2},
		{NOTE_A, 5, 4},
		{NOTE_A, 4, -8},
		{NOTE_A, 4, 16},
		{NOTE_A, 5, 4},
		{NOTE_GS, 5, -8},
		{NOTE_G, 5, 16},
		{NOTE_DS, 5, 16},
		{NOTE_D, 5, 16},
		{NOTE_DS, 5, 8},
		{REST, 0, 8},
		{NOTE_A, 4, 8},
		{NOTE_DS, 5, 4},
		{NOTE_D, 5, -8},
		{NOTE_CS, 5, 16},
		{NOTE_C, 5, 16},
		{NOTE_B, 4, 16},
		{NOTE_C, 5, 16},
		{REST, 0, 8},
		{NOTE_F, 4, 8},
		{NOTE_GS, 4, 4},
		{NOTE_F, 4, -8},
		{NOTE_A, 4, -16},
		{NOTE_C, 5, 4},
		{NOTE_A, 4, -8},
		{NOTE_C, 5, 16},
		{NOTE_E, 5, 2},
		{NOTE_A, 5, 4},
		{NOTE_A, 4, -8},
		{NOTE_A, 4, 16},
		{NOTE_A, 5, 4},
		{NOTE_GS, 5, -8},
		{NOTE_G, 5, 16},
		{NOTE_DS, 5, 16},
		{NOTE_D, 5, 16},
		{NOTE_DS, 5, 8},
		{REST, 0, 8},
		{NOTE_A, 4, 8},
		{NOTE_DS, 5, 4},
		{NOTE_D, 5, -8},
		{NOTE_CS, 5, 16},
		{NOTE_C, 5, 16},
		{NOTE_B, 4, 16},
		{NOTE_C, 5, 16},
		{REST, 0, 8},
		{NOTE_F, 4, 8},
		{NOTE_GS, 4, 4},
		{NOTE_F, 4, -8},
		{NOTE_A, 4, -16},
		{NOTE_A, 4, 4},
		{NOTE_F, 4, -8},
		{NOTE_C, 5, 16},
		{NOTE_A, 4, 2},
	};

	int divider;

	ddfs_set_offset_freq(io_s1_ddfs, 0);
	ddfs_set_phase_degree(io_s1_ddfs, 0);

	for (int i = 0; i < 86; i++) {
		io_write(io_s0_gpo, 0, i);

		freq = calc_note_freq(melody[i][0], melody[i][1]-1);
		ddfs_set_carrier_freq(io_s1_ddfs, freq);

		divider = melody[i][2];

		if (divider > 0) {
			note_duration = full_note_duration / divider;
		} else {
			note_duration = -1.5 * full_note_duration / divider;
		}

		xil_printf("%d: %d Hz for %d ms\r\n", i, freq, note_duration);

		sustain_ms = note_duration - (50 + 50 + 50);
		if (sustain_ms < 10) {
			sustain_ms = 10;
		}

		adsr_set_env(io_s2_adsr, 50, 50, sustain_ms, 50, 0.3);
		adsr_start(io_s2_adsr);

		usleep(1000 * note_duration);
	}
}

int read_int() {
	char in_byte;
	int num = 0;

	while (1) {
		in_byte = inbyte();
		outbyte(in_byte);

		if (in_byte == ',') {
			break;
		}

		num *= 10;
		num += in_byte- 0x30; // Subtract '0' to make value from 0 - 9.
	}

	return(num);
}

int main()
{
	char in_byte;
	int freq, attack_ms, decay_ms, sustain_ms, release_ms;
	float sustain_level;

    init_platform();

    while (1) {
    	in_byte = inbyte();
    	outbyte(in_byte);

    	if (in_byte == 'a') {
    		attack_ms = read_int();
    		decay_ms = read_int();
    		sustain_ms = read_int();
    		release_ms = read_int();
    		sustain_level = read_int() / 100.0;

    		adsr_set_env(io_s2_adsr, attack_ms, decay_ms, sustain_ms, release_ms, sustain_level);
    	} else if (in_byte == 'f') {
    		freq = read_int();

    		ddfs_set_offset_freq(io_s1_ddfs, 0);
    		ddfs_set_phase_degree(io_s1_ddfs, 0);
    		ddfs_set_carrier_freq(io_s1_ddfs, freq);
    	} else if (in_byte == 'p') {
			adsr_start(io_s2_adsr);
		}
    }
}
