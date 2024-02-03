`timescale 1ns / 10ps

module top_tb;
    localparam T=10; // 100 Mhz

    logic clk;
    logic reset_n;

    logic tx_mclk;
    logic tx_sclk;
    logic tx_lrclk;

    top uut(
        .clk(clk),
        .reset_n(reset_n),
        // Outputs
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk),
        .tx_lrclk(tx_lrclk)
    );

    // Simulate a 100 Mhz clock signal.
    initial clk = 0;
    always clk = #(T/2) ~clk;

    // Reset at the start of the simulation.
    initial begin
        reset_n = 1'b0;
        @(negedge clk)
        reset_n = 1'b1;
    end

    // Initial values for signals.
    initial begin
        // Stop the test after this delay in case of a bug.
        #2ms
        $finish;
    end

    initial begin
        @(posedge reset_n);
    end
endmodule
