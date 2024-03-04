module mmio_gpo
    (
        input logic clk,
        input logic reset_n,
        // MMIO slot
        input logic cs,
        input logic write,
        input logic read,
        input logic [4:0] addr,
        input logic [31:0] write_data,
        output logic [31:0] read_data
    );

endmodule
