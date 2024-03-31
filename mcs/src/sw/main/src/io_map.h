/*
 * io_map.h
 *
 *  Created on: 4 Mar 2024
 *      Author: emire
 */

#ifndef SRC_IO_MAP_H_
#define SRC_IO_MAP_H_

#include "xparameters.h"

#define SYS_CLK_FREQ XPAR_CPU_CORE_CLOCK_FREQ_HZ
#define I2S_EN_FREQ 192000
#define IO_BASE_ADDR XPAR_MICROBLAZE_MCS_0_IOMODULE_0_IO_BASEADDR

// Slot definition
#define IO_S0_GPO 0
#define IO_S1_DDFS 1
#define IO_S2_ADSR 2

#endif /* SRC_IO_MAP_H_ */
