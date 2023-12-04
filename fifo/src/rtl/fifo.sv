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
        input logic clk,
        input logic reset_n,
        input logic rd, wr,
        input logic [DATA_WIDTH-1:0] w_data,
        output logic empty, full,
        output logic [DATA_WIDTH-1:0] r_data
    );

    logic [ADDR_WIDTH-1:0] w_addr, r_addr;
    logic wr_en;

    /* ~~ Initialize fifo_ctrl unit ~~ */

    fifo_ctrl #(ADDR_WIDTH) fifo_ctrl_unit(
        .*,
        .rd(rd),
        .wr(wr),
        .empty(empty),
        .full(full),
        .w_addr(w_addr),
        .r_addr(r_addr)
    );

    /* ~~ Initialize reg_file unit ~~ */

    assign wr_en = wr & ~full;

    reg_file #(DATA_WIDTH, ADDR_WIDTH) reg_file_unit(
        .*,
        .wr_en(wr_en),
        .w_addr(w_addr),
        .r_addr(r_addr),
        .w_data(w_data),
        .r_data(r_data)
    );

endmodule
