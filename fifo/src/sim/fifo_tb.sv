`timescale 1ns / 10ps

module fifo_tb;
    localparam T=10; // 100 Mhz, 10 ns

    logic clk;
    logic reset_n;

    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 3;

    logic wr, rd;
    logic empty, full;
    logic [DATA_WIDTH-1:0] w_data, r_data;

    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut(
        .i_clk(clk),
        .i_reset_n(reset_n),
        .i_rd(rd),
        .i_wr(wr),
        .i_w_data(w_data),
        .o_full(full),
        .o_empty(empty),
        .o_r_data(r_data)
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
            assert(r_data == 8'hf0 + i) else $fatal("Expected r_data to be 0x%2h.", 8'hf0 + i);
        end
        rd = 1'b0;

        @(posedge clk);

        $finish;
    end
endmodule
