`timescale 1ns / 10ps

module top_tp;
    logic clk = 0;
    logic reset_n = 1;
    logic out = 0;

    // N = 100 Mhz / 100 kHz - 1
    // N = 1e8 / 1e5 - 1
    // N = 1000 - 1
    top #(.N(999)) uut(
        .clk(clk),
        .reset_n(reset_n),
        .led0_b(out)
    );
    
    always #5 clk = ~clk; // Simulate a 100 Mhz clk.
endmodule