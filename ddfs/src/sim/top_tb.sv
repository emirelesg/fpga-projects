`timescale 1ns / 10ps

module top_tb;
    localparam T=10; // 100 Mhz, 10 ns

    logic [1:0] clk_divider; // 2 bits used for a /4 divider.
    logic clk;
    logic reset_n;
    logic en;
    logic [29:0] fccw, focw;
    logic [29:0] pha;
    logic [15:0] env;
    logic [15:0] pcm_out;
    logic [2:0] wave_type;
    logic data_valid;

    ddfs uut(
        .clk(clk),
        .reset_n(reset_n),
        .en(en),
        .fccw(fccw),
        .focw(focw),
        .pha(pha),
        .env(env),
        .wave_type(wave_type),
        // Outputs
        .pcm_out(pcm_out),
        .data_valid(data_valid)
    );

    // Simulate a 100 MHz clock signal.
    initial clk = 0;
    always clk = #(T/2) ~clk;

    // Simulate a tick at 25 MHz intervals.
    always_ff @(posedge clk)
        if (~reset_n)
            clk_divider <= 0;
        else
            clk_divider <= clk_divider + 1;
    assign en = &clk_divider;

    // Reset at the start of the simulation.
    initial begin
        reset_n = 1'b0;
        @(negedge clk);
        reset_n = 1'b1;
    end

    // Initial values for signals.
    initial begin
        // (2 ^ PHASE_WIDTH * freq / 25_000_000)
        fccw = 42949; // 1000 Hz
        focw = 0;
        pha = 0;
        env = 16'h4000; // 1.0
        wave_type = 3'b001;
    end

    initial begin
        @(posedge reset_n); // Wait for the reset.
        @(negedge clk);

        #1ms; // 1 full wave cycle at 1 kHz
        wave_type = 3'b010;
        #1ms;
        wave_type = 3'b011;
        #1ms;
        wave_type = 3'b100;
        #1ms;
        wave_type = 3'b000;
        #1ms;
        $finish;
    end
endmodule
