`timescale 1ns / 10ps

module adsr_tb;
    localparam T=10; // 100 Mhz

    localparam MAX = 32'h7fff_ffff;
    localparam CLKS_PER_US = 0.000_001 / (1.0 / 100_000_000);
    localparam ATTACK_US = 1;
    localparam DECAY_US = 1;
    localparam SUSTAIN_US = 5;
    localparam RELEASE_US = 1;
    localparam SUSTAIN_LEVEL = 0.5;
    localparam SUSTAIN_ABS = $rtoi(MAX * SUSTAIN_LEVEL);

    logic clk;
    logic reset_n;

    logic start;
    logic [31:0] attack_step, decay_step, sustain_level, release_step;
    logic [31:0] sustain_time;
    logic [15:0] env;

    adsr uut(
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .attack_step(attack_step),
        .decay_step(decay_step),
        .sustain_level(sustain_level),
        .release_step(release_step),
        .sustain_time(sustain_time),
        // Outputs
        .env(env)
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
        start = 1'b0;
        attack_step = $rtoi(MAX / (ATTACK_US * CLKS_PER_US));
        decay_step = $rtoi((MAX - SUSTAIN_ABS) / (DECAY_US * CLKS_PER_US));
        sustain_level = SUSTAIN_ABS;
        sustain_time = $rtoi(SUSTAIN_US * CLKS_PER_US);
        release_step = $rtoi(SUSTAIN_ABS / (RELEASE_US * CLKS_PER_US));

        // Stop the test after this delay in case of a bug.
        #10us;
        $finish;
    end

    initial begin
        @(posedge reset_n);

        start = 1'b1;
        @(negedge clk); // state_reg == idle
        start = 1'b0;

        @(posedge clk); // state_reg == attack

        assert(env == 0) else $fatal("[env] Expected to be 0.");

        #(ATTACK_US * 1000)

        @(posedge clk); // It takes 1 cycle to clock in the value.
        @(negedge clk); // Check in the neg edge of the next cycle to get a stable value..

        assert(env < 16'h4010 && env > 16'h3ff0) else $fatal("[env] Expected to be 1.0 +/ 0.001.");

        #(DECAY_US * 1000)

        @(posedge clk); @(negedge clk); // Check 1.5 clock cycles later.

        assert(env < 16'h2002 && env > 16'h1ffe) else $fatal("[env] Expected to be 0.5 +/- 0.001.");

        #(SUSTAIN_US * 1000)

        @(posedge clk); @(negedge clk); // Check 1.5 clock cycles later.

        assert(env < 16'h2002 && env > 16'h1ffe) else $fatal("[env] Expected to be 0.5 +/- 0.001.");

        #(RELEASE_US * 1000)

        @(posedge clk); @(negedge clk); // Check 1.5 clock cycles later.

        assert(env == 16'h0000) else $fatal("[env] Expected to be 0.");
    end
endmodule
