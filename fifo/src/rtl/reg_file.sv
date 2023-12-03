/*
 *  reg_file
 */

module reg_file
    #(
        parameter   DATA_WIDTH = 8,
                    ADDR_WIDTH = 2
    )
    (
        input logic clk,
        input logic reset_n,
        input logic wr_en,
        input logic [ADDR_WIDTH-1:0] wr_addr, rd_addr,
        input logic [DATA_WIDTH-1:0] wr_data,
        output logic [DATA_WIDTH-1:0] rd_data
    );

    logic [DATA_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];

    always_ff @(posedge clk)
        if (wr_en)
            array_reg[wr_addr] <= wr_data;

    /* ~~ Assignment of outputs ~~ */

    assign rd_data = array_reg[rd_addr];
endmodule
