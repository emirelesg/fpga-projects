module top
    // N = 1e8 Hz / 2 Hz - 1
    // N = 50_000_000 - 1
    #(parameter N = 49_999_999)
    (
        input logic clk, // 100 Mhz, 10 ns
        input logic reset_n,
        output logic led0_b
    );
    
    logic [31:0] r_counter = 0;
    
    always_ff @(posedge clk, negedge reset_n)
    begin
        if (~reset_n)
            begin
                r_counter <= 0;
                led0_b <= 0;
            end
        else if (r_counter == N)
            begin
                r_counter <= 0;
                led0_b <= ~led0_b;
            end
        else
            begin
                r_counter <= r_counter + 1;
            end
    end
endmodule
