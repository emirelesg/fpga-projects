module mmio_controller
    (
        // MMIO bus
        input logic mmio_cs,
        input logic mmio_write,
        input logic mmio_read,
        input logic [20:0] mmio_addr,
        input logic [31:0] mmio_write_data,
        output logic [31:0] mmio_read_data
    );

endmodule
