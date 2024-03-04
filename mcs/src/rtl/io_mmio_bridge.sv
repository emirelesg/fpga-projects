module io_mmio_bridge
    #(
        parameter BRIDGE_BASE = 32'hc000_0000
    )
    (
        // uBlaze MCS I/O bus
        input logic io_addr_strobe,
        input logic io_read_strobe,
        input logic io_write_strobe,
        input logic [3:0] io_byte_enable,
        input logic [31:0] io_address,
        input logic [31:0] io_write_data,
        output logic [31:0] io_read_data,
        output logic io_ready,
        // MMIO bus
        output logic mmio_cs,
        output logic mmio_write,
        output logic mmio_read,
        output logic [20:0] mmio_addr,
        output logic [31:0] mmio_write_data,
        input logic [31:0] mmio_read_data
    );

    // io_address is broken down as follows:
    // xxxx xxxx yzzz zzzz zzzz zzzz zzzz zz00
    // bits 31 to 24: used for enabling the correct module.
    // bit 23: not used
    // bit 22 to 2: used to identify a memory location in the mmio
    // bit 1 to 0: not used
    assign mmio_cs = io_address[31:24] == BRIDGE_BASE[31:24];
    assign mmio_addr = io_address[22:2]; // 2 LSBs are used for the word alignment.

    assign mmio_write = io_write_strobe;
    assign mmio_read = io_read_strobe;

    assign io_ready = 1'b1; // Not used, since transaction is done in 1 clock.

    assign mmio_write_data = io_write_data;
    assign io_read_data = mmio_read_data;
endmodule
