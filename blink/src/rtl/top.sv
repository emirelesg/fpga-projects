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
    
    logic c_tick;
    logic [$clog2(CLK_DIVIDE)-1:0] c_reg, c_next;
    logic t, t_next; 
        
    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            c_reg <= 0;
            t <= 0;
        end
        else begin
            c_reg <= c_next;
            t <= t_next;
        end
    end

    assign c_tick = (c_reg == CLK_DIVIDE/2 - 1) ? 1'b1 : 1'b0;
    assign c_next = (c_tick) ? 1'b0 : c_reg + 1;
    assign t_next = (c_tick) ? ~t : t;

    assign led0_b = t;
endmodule
