`timescale 1ns / 10ps

module delay_tb;
    localparam T=10; // 100 Mhz, 10 ns

    logic clk;
    logic reset_n;

    delay uut(
        .i_clk(clk),
        .i_reset_n(reset_n)
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
        // Stop the test after this delay in case of a bug.
        #1ms;
        $finish;
    end

    initial begin
        @(posedge reset_n); // Wait for the reset.
        @(negedge clk);

        $finish;
    end
endmodule
