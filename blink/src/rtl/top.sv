module top
    #(
        parameter   CLK_FREQ = 100_000_000, // 100 Mhz, 10 ns
                    OUTPUT_FREQ = 2 // 2 Hz
    )
    (
        input logic clk,
        input logic reset_n,
        output logic led0_b
    );

    localparam CLK_DIVIDE = CLK_FREQ / OUTPUT_FREQ;
    
    logic [$clog2(CLK_DIVIDE)-1:0] c_reg = 0;
    logic t_reg = 0;
        
    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            c_reg <= 0;
            t_reg <= 0; 
        end
        else begin
            if (c_reg == (CLK_DIVIDE/2)-1) begin
                c_reg <= 0;
                t_reg <= ~t_reg;
            end
            else
                c_reg <= c_reg + 1;
        end
    end

    assign led0_b = t_reg;
endmodule
