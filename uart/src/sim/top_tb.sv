`timescale 1ns / 10ps

module top_tb;
    localparam T=10; // 100 Mhz, 10 ns

    logic clk;
    logic reset_n;

    // Parameters and signals for UUT

    localparam DB_TIME = 0.000005; // 5 us

    logic btn;
    logic tx, rx;

    top #(.DB_TIME(DB_TIME)) uut(
        .*,
        .uart_txd_in(rx),
        // Outputs
        .uart_rxd_out(tx)
    );

    // Parameters and signals for Test

    localparam T_DB = T * 1000; // 10 us
    localparam S_TICK = 54; // Amount of clock cycles for a bit to send.

    // Simulate a 100 Mhz clock signal.
    always begin
        clk = 1'b0;
        #(T/2);
        clk = 1'b1;
        #(T/2);
    end

    // Reset at the start of the simulation.
    initial begin
        reset_n = 1'b0;
        #(T/2);
        reset_n = 1'b1;
        #(T);
    end

    initial begin
        btn = 1'b0;

        @(posedge reset_n); // Wait for the reset.
        @(negedge clk);

        btn = 1'b1;
        #(T_DB); // Wait for the debounced tick.
        btn = 1'b0;
        repeat(10) @(posedge clk); // Wait for FIFO to be filled.
        @(negedge clk);

        // Wait for 10 bytes to send.
        // 10 bytes * 10 bits * T_BIT
        repeat(10) repeat(10) repeat(16*S_TICK) @(negedge clk);

        $stop;
    end
endmodule
