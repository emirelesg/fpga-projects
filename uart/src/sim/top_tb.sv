`timescale 1ns / 10ps

module uart_tb;
    localparam T=10; // 100 Mhz, 10 ns
    localparam S_TICK=54; // Amount of clock cycles for an s_tick.

    logic clk;
    logic reset_n;
    logic tx;
    logic tx_start;
    logic [7:0] tx_data;

    uart uut(
        .clk(clk),
        .reset_n(reset_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx)
    );

    // Simulate a 100 Mhz clock signal.
    always begin
        clk = 1'b0;
        #(T/2);
        clk = 1'b1;
        #(T/2);
    end

    // Reset at the start of the simulation.
    initial begin
        tx_start = 0'b0;
        tx_data = 8'b10101010;
        reset_n = 1'b0;
        #(T/2);
        reset_n = 1'b1;
        #(T);
    end

    initial begin
        @(posedge reset_n); // Wait for the reset.
        @(negedge clk);

        assert(tx == 1);
        // state_reg = idle

        tx_start = 1'b1;

        @(negedge clk);

        // state_reg = start

        tx_start = 0'b0;

        @(posedge clk);
        assert(tx == 0);

        repeat(16*S_TICK) @(negedge clk);
        assert(tx == 0);

        // state_reg = data

        repeat(16*S_TICK) @(negedge clk);
        assert(tx == 1);
        repeat(16*S_TICK) @(negedge clk);
        assert(tx == 0);
        repeat(16*S_TICK) @(negedge clk);
        assert(tx == 1);
        repeat(16*S_TICK) @(negedge clk);
        assert(tx == 0);
        repeat(16*S_TICK) @(negedge clk);
        assert(tx == 1);
        repeat(16*S_TICK) @(negedge clk);
        assert(tx == 0);
        repeat(16*S_TICK) @(negedge clk);
        assert(tx == 1);

        repeat(16*S_TICK) @(negedge clk);
        assert(tx == 1);

        // state_reg = stop

        repeat(16*S_TICK) @(negedge clk);
        assert(tx == 1);

        // state_reg = idle

        repeat(16*S_TICK) @(negedge clk);

        $stop;
    end
endmodule
