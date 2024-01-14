`timescale 1ns / 10ps

module top_tb;
    localparam T=10; // 100 Mhz, 10 ns

    logic clk;
    logic reset_n;
    
    logic tx_mclk;
    logic tx_sclk;

    top uut(
        .clk(clk),
        .reset_n(reset_n),
        // Outputs
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk)
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
        reset_n = 1'b0;
        #(T/2);
        reset_n = 1'b1;
        #(T);
    end

    initial begin
        @(posedge reset_n); // Wait for the reset.
        @(negedge clk);
        
        #5000ns;

        $stop;
    end
endmodule
