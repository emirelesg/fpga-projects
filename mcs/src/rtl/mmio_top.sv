`include "io_mmio_map.svh"
module mmio_top
    (
        input logic clk,
        input logic reset_n,
        // MMIO bus
        input logic mmio_cs,
        input logic mmio_write,
        input logic mmio_read,
        input logic [20:0] mmio_addr,
        input logic [31:0] mmio_write_data,
        output logic [31:0] mmio_read_data
    );
    
    mmio_controller mmio_controller_unit(
        // MMIO bus
        .mmio_cs(mmio_cs),
        .mmio_write(mmio_write),
        .mmio_read(mmio_read),
        .mmio_addr(mmio_addr),
        .mmio_write_data(mmio_write_data),
        .mmio_read_data(mmio_read_data)
    );
    
    mmio_gpo mmio_gpo_unit(
        .clk(clk),
        .reset_n(reset_n)
        // MMIO Slot
    );

endmodule
