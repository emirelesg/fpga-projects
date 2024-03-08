/*
 * io_init.h
 *
 *  Created on: 4 Mar 2024
 *      Author: emire
 */

#ifndef SRC_IO_INIT_H_
#define SRC_IO_INIT_H_

#include "io_rw.h"
#include "io_map.h"

// Bit Manipulation Macros
#define bit(n) (1UL << n)
#define bit_set(data, n) (data |= bit(n))
#define bit_clear(data, n) (data &= ~bit(n))
#define bit_toggle(data, n) (data ^= bit(n))
#define bit_read(data, n) ((data >> n) & 0x01)
#define bit_write(data, n, value) (value ? bit_set(data, n) : bit_clear(data, n))

// Slots
#define io_s0_gpo get_slot_addr(IO_BASE_ADDR, IO_S0_GPO)
#define io_s1_ddfs get_slot_addr(IO_BASE_ADDR, IO_S1_DDFS)

#endif /* SRC_IO_INIT_H_ */
