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
		xil_printf("%d Hz\r\n", f);
		ddfs_set_carrier_freq(io_s1_ddfs, f);
		usleep(50000); // 50 ms
	}
	for (uint32_t f = 500; f > 200; f -= 1) {
		xil_printf("%d Hz\r\n", f);
		ddfs_set_carrier_freq(io_s1_ddfs, f);
		usleep(50000); // 50 ms
	}
}

void gpo_test() {
	for (uint32_t i = 0; i < 16; i += 1) {
		xil_printf("%d\r\n", i);
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
		xil_printf("Go! %d Hz\r\n", freq);
		adsr_start(io_s2_adsr);
		usleep(1000000); // 1000 ms
	}
}

void adsr_dracula() {
	int freq, note_duration, sustain_ms;

	const int tempo = 180;
	const int full_note_duration = (60000 * 4) / tempo; // In ms
	const int melody[][3] = {
		{NOTE_A, 4, 8},
		{NOTE_G, 4, 8},
		{NOTE_A, 4, 2},
		{NOTE_B, 1, 2},
		{NOTE_G, 4, 8},
		{NOTE_F, 4, 8},
		{NOTE_E, 4, 8},
		{NOTE_D, 4, 8},
		{NOTE_Cs, 4, 2},
		{NOTE_D, 4, 2},
	};

	ddfs_set_offset_freq(io_s1_ddfs, 0);
	ddfs_set_phase_degree(io_s1_ddfs, 0);

	for (int i = 0; i < 10; i++) {
		io_write(io_s0_gpo, 0, i);

		freq = calc_note_freq(melody[i][0], melody[i][1]);
		ddfs_set_carrier_freq(io_s1_ddfs, freq);

		note_duration = full_note_duration / melody[i][2];

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

int main()
{
    init_platform();

    adsr_dracula();

    while(1) {

    }
}
