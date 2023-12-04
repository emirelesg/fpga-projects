`timescale 1ns / 10ps

module fifo_tb;
    localparam T=10; // 100 Mhz, 10 ns

    logic clk;
    logic reset_n;

    // Parameters and signals for UUT

    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 3;

    logic wr, rd;
    logic empty, full;
    logic [DATA_WIDTH-1:0] w_data, r_data;

    fifo #(DATA_WIDTH, ADDR_WIDTH) uut(.*);

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
        wr = 1'b0;
        rd = 1'b0;
        w_data = 8'h00;

        @(posedge reset_n); // Wait for the reset.
        @(negedge clk);

        // Write to all addresses a byte.
        wr = 1'b1;
        for (logic [DATA_WIDTH-1:0] i=0; i < 2**ADDR_WIDTH; i++) begin
            w_data = 8'hf0 + i;
            @(negedge clk);
        end
        wr = 1'b0;
        w_data = 8'h00;

        // Read all addresses.
        rd = 1'b1;
        for (logic [DATA_WIDTH-1:0] i=0; i < 2**ADDR_WIDTH; i++) begin
            @(posedge clk);
            assert(r_data == 8'hf0 + i) else $fatal("Test failed! Data mismatch.");
        end
        rd = 1'b0;

        @(posedge clk);

        $stop;
    end
endmodule
