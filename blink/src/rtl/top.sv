module top
    #(
        // N = 1e8 Hz / 2 Hz - 1
        // N = 50_000_000 - 1
        parameter N = 49_999_999
    )
    (
        input logic clk, // 100 Mhz, 10 ns
        input logic reset_n,
        output logic led0_b
    );
    
    logic [31:0] c_reg = 0;
    logic t_reg = 0;
        
    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n)
            c_reg <= 0;
        else begin
            if (c_reg == N) begin
                c_reg <= 0;
                t_reg <= ~t_reg;
            end
            else
                c_reg <= c_reg + 1;
        end
    end

    assign led0_b = t_reg;
endmodule
