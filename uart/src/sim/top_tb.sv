`timescale 1ns / 10ps

module uart_tb;
    localparam T=10; // 100 Mhz, 10 ns

    logic clk;
    logic reset_n;

    // Parameters and signals for UUT

    localparam S_TICK=54; // Amount of clock cycles for an s_tick.

    logic rx, tx;
    logic tx_start;
    logic [7:0] tx_data;

    uart uut(.*);

    // Parameters and signals for Test

    logic [9:0] payload;

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
        tx_start = 0'b0;
        tx_data = 8'b10101010;
        payload = {1'b1, tx_data, 1'b0}; // Including start and stop bits.

        @(posedge reset_n); // Wait for the reset.
        @(negedge clk);

        assert(tx == 1) else $fatal("Expected tx to be 1.");

        // state_reg = idle

        tx_start = 1'b1;

        @(negedge clk);

        // state_reg = start

        tx_start = 0'b0;

        @(negedge clk);

        for (int i = 0; i < 10; i++) begin
            $display("[payload] %d: %b", i, payload[i]);
            assert(tx == payload[i]) else $fatal("Expected tx to be %b.", payload[i]);
            repeat(16*S_TICK) @(negedge clk);
        end

        // state_reg = idle

        repeat(16*S_TICK) @(negedge clk);

        $stop;
    end
endmodule
