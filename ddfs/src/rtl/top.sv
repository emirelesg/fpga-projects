module top
    (
        input logic clk,
        input logic reset_n
    );
    
    /* ~~ Create ddfs unit ~~ */
    
    logic [29:0] fccw, focw;
    logic [29:0] pha;
    logic [15:0] env;
    
    initial begin
        // 4295 = 400 Hz
        fccw = 4295; // (2 ^ PHASE_WIDTH * freq / 100_000_000)
        focw = 0;
        pha = 0;
        // 1.0
        env = 16'h4000;
    end 
    
    ddfs ddfs_unit(
        .clk(clk),
        .reset_n(reset_n),
        .fccw(fccw),
        .focw(focw),
        .pha(pha),
        .env(env)
    );
endmodule
