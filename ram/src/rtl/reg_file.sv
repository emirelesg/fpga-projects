/*
 * reg_file
 *
 * Basic register file with dynamic indexing.
 *
 * RAM_STYLE: https://docs.amd.com/r/en-US/ug901-vivado-synthesis/RAM_STYLE?tocId=EWhb59DDWEWsMr4arnAICw
 */

module reg_file
    #(
        parameter   DATA_WIDTH = 8,
                    ADDR_WIDTH = 2,
                    MEMORY_TYPE = "distributed", // block, distributed, registers, ultra, mixed, auto
                    MEMORY_FILE = ""
    )
    (
        input   logic                   i_clk,
        input   logic                   i_reset_n,
        input   logic                   i_wr_en,
        input   logic [ADDR_WIDTH-1:0]  i_w_addr, i_r_addr,
        input   logic [DATA_WIDTH-1:0]  i_w_data,
        output  logic [DATA_WIDTH-1:0]  o_r_data
    );
    
    (* ram_style = MEMORY_TYPE *) logic [DATA_WIDTH-1:0] ram [0:2**ADDR_WIDTH-1];
    
    if (MEMORY_FILE != "")
        initial
            $readmemh(MEMORY_FILE, ram);
    
    always_ff @(posedge i_clk) begin
        if (i_wr_en)
            ram[i_w_addr] <= i_w_data;
        o_r_data <= ram[i_r_addr];
    end
endmodule
