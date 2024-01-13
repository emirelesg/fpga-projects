module top
    (
        input logic clk,
        input logic reset_n
    );
    
    /* ~~ Create design_1_wrapper unit ~~ */
    
    logic clk_i2s;
    
    design_1_wrapper design_1_wrapper_unit (
        .clk(clk),
        .reset_n(reset_n),
        // Outputs
        .clk_i2s(clk_i2s)
    );
endmodule
