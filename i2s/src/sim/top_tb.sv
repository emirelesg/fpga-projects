`timescale 1ns / 10ps

module top_tb;
    localparam T=10; // 100 Mhz

    logic clk;
    logic reset_n;

    logic [3:0] sw;
    logic [3:0] btn;
    logic tx_mclk;
    logic tx_sclk;
    logic tx_lrclk;
    logic tx_sd;

    top uut(
        .i_clk(clk),
        .i_reset_n(reset_n),
        .i_btn(btn),
        // Outputs
        .o_tx_mclk(tx_mclk),
        .o_tx_sclk(tx_sclk),
        .o_tx_lrclk(tx_lrclk),
        .o_tx_sd(tx_sd)
    );

    // Simulate a 100 Mhz clock signal.
    initial clk = 0;
    always clk = #(T/2) ~clk;

    // Reset at the start of the simulation.
    initial begin
        reset_n = 1'b0;
        @(negedge clk);
        reset_n = 1'b1;
    end

    // Initial values for signals.
    initial begin
        btn = 4'b0000;
        sw = 4'b0000;

        // Stop the test after this delay in case of a bug.
        #100us;
        $finish;
    end

    initial begin
        @(posedge reset_n);
    end
endmodule
