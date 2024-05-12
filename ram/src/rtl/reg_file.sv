/*
 * reg_file
 *
 * Basic register file with dynamic indexing.
 */

module reg_file
    #(
        parameter   DATA_WIDTH = 8,
                    ADDR_WIDTH = 2
    )
    (
        input   logic                   i_clk,
        input   logic                   i_reset_n,
        input   logic                   i_wr_en,
        input   logic [ADDR_WIDTH-1:0]  i_w_addr, i_r_addr,
        input   logic [DATA_WIDTH-1:0]  i_w_data,
        output  logic [DATA_WIDTH-1:0]  o_r_data
    );

    logic [DATA_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];

    always_ff @(posedge i_clk)
        if (i_wr_en)
            array_reg[i_w_addr] <= i_w_data;

    assign o_r_data = array_reg[i_r_addr];
endmodule
