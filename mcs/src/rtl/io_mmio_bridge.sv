module io_mmio_bridge
    #(
        parameter IO_BRIDGE_BASE = 32'hc000_0000
    )
    (
        // uBlaze MCS I/O bus
        input   logic           i_io_addr_strobe,
        input   logic           i_io_read_strobe,
        input   logic           i_io_write_strobe,
        input   logic [3:0]     i_io_byte_enable,
        input   logic [31:0]    i_io_address,
        input   logic [31:0]    i_io_write_data,
        output  logic [31:0]    o_io_read_data,
        output  logic           o_io_ready,
        // MMIO bus
        output  logic           o_mmio_cs,
        output  logic           o_mmio_write,
        output  logic           o_mmio_read,
        output  logic [20:0]    o_mmio_addr,
        output  logic [31:0]    o_mmio_write_data,
        input   logic [31:0]    i_mmio_read_data
    );

    // io_address is broken down as follows:
    // xxxx xxxx yzzz zzzz zzzz zzzz zzzz zz00
    // bits 31 to 24: used for enabling the correct module.
    // bit 23: not used
    // bit 22 to 2: used to identify a memory location in the mmio
    // bit 1 to 0: not used
    assign o_mmio_cs = i_io_address[31:24] == IO_BRIDGE_BASE[31:24];
    assign o_mmio_addr = i_io_address[22:2]; // 2 LSBs are used for the word alignment.

    assign o_mmio_write = i_io_write_strobe;
    assign o_mmio_read = i_io_read_strobe;

    assign o_io_ready = 1'b1; // Not used, since transaction is done in 1 clock.

    assign o_mmio_write_data = i_io_write_data;
    assign o_io_read_data = i_mmio_read_data;
endmodule
