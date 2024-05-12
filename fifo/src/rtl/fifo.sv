/*
 * fifo
 *
 * Wrapper for a circular queue fifo.
 */

module fifo
    #(
        parameter   DATA_WIDTH = 8,
                    ADDR_WIDTH = 2
    )
    (
        input   logic                   i_clk,
        input   logic                   i_reset_n,
        input   logic                   i_rd, i_wr,
        input   logic [DATA_WIDTH-1:0]  i_w_data,
        output  logic                   o_empty, o_full,
        output  logic [DATA_WIDTH-1:0]  o_r_data
    );

    logic [ADDR_WIDTH-1:0] w_addr, r_addr;
    logic wr_en;

    fifo_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) fifo_ctrl_unit(
        .*,
        .i_rd(i_rd),
        .i_wr(i_wr),
        // Outputs
        .o_empty(o_empty),
        .o_full(o_full),
        .o_w_addr(w_addr),
        .o_r_addr(r_addr)
    );

    assign wr_en = i_wr & ~o_full;

    reg_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) reg_file_unit(
        .*,
        .i_wr_en(wr_en),
        .i_w_addr(w_addr),
        .i_r_addr(r_addr),
        .i_w_data(i_w_data),
        // Outputs
        .o_r_data(o_r_data)
    );
endmodule
