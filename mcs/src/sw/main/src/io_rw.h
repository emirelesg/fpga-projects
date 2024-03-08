/*
 * io_rw.h
 *
 *  Created on: 4 Mar 2024
 *      Author: emire
 */

#ifndef SRC_IO_RW_H_
#define SRC_IO_RW_H_

#include "io_map.h"

#define io_read(slot_addr, offset) (*(volatile uint32_t *)(slot_addr + offset*4))
#define io_write(slot_addr, offset, data) (*(volatile uint32_t *)(slot_addr + offset*4) = data)
#define get_slot_addr(io_base, slot) ((uint32_t)(io_base + slot*32*4))

#endif /* SRC_IO_RW_H_ */
