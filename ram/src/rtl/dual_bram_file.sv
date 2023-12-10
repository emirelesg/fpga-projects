/*
 * bram_reg_file
 *
 * Block RAM based basic register file with dynamic indexing.
 * Based on pg. 118 of https://docs.xilinx.com/v/u/2018.3-English/ug901-vivado-synthesis
 * "Simple Dual-Port Block RAM with Single Clock"
 */

module dual_bram_file
    #(
        parameter   DATA_WIDTH = 8,
                    ADDR_WIDTH = 2,
                    MEM_FILE = "dual_bram_file.mem"
    )
    (
        input logic clk,
        input logic wr_en,
        input logic [ADDR_WIDTH-1:0] w_addr, r_addr,
        input logic [DATA_WIDTH-1:0] w_data,
        output logic [DATA_WIDTH-1:0] r_data
    );

    // For small ADDR_WIDTH sizes, the array_reg is synthesized with LUTs.
    // Force the usage of BRAM with the following directive:
    (* ram_style = "block" *) logic [DATA_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];

    initial begin
        $readmemh(MEM_FILE, array_reg);
    end

    always_ff @(posedge clk) begin
        if (wr_en)
            array_reg[w_addr] <= w_data;
        r_data <= array_reg[r_addr];
    end
endmodule
