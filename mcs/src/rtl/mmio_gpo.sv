module mmio_gpo
    (
        input   logic           i_clk,
        input   logic           i_reset_n,
        // MMIO slot
        input   logic           i_cs,
        input   logic           i_write,
        input   logic           i_read,
        input   logic [4:0]     i_addr,
        input   logic [31:0]    i_write_data,
        output  logic [31:0]    o_read_data,
        // External
        output  logic [31:0]    o_gpo
    );

    logic [31:0] gpo_reg;
    logic wr_en;

    always_ff @(posedge i_clk, negedge i_reset_n)
        if (~i_reset_n)
            gpo_reg <= 0;
        else
            if (wr_en)
                gpo_reg <= i_write_data;

    assign wr_en = i_cs & i_write;
    assign o_read_data = 0; // No data to read from the gpo module.
    assign o_gpo = gpo_reg;
endmodule
