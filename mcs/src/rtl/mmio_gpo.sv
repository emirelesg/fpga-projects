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
        output logic [31:0] read_data,
        // External
        output logic [31:0] d_out
    );

    logic [31:0] d_out_reg;
    logic wr_en;

    always_ff @(posedge clk, negedge reset_n)
        if (~reset_n)
            d_out_reg <= 0;
        else
            if (wr_en)
                d_out_reg <= write_data;

    assign wr_en = cs & write;
    assign read_data = 0; // No data to read from the gpo module.
    assign d_out = d_out_reg;
endmodule
