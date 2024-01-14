module i2s
    (
        input logic clk_i2s,
        input logic reset_n,
        output logic tx_mclk,
        output logic tx_lrclk,
        output logic tx_sclk,
        output logic tx_data
    );
    
    assign tx_mclk = clk_i2s;
    assign tx_lrclk = 1'b0;
    assign tx_sclk = 1'b0;
    assign tx_data = 1'b0;
endmodule
