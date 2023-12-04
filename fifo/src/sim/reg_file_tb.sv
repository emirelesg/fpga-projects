`timescale 1ns / 10ps

module reg_file_tb;
    localparam T=10; // 100 Mhz, 10 ns

    logic clk;
    logic reset_n;

    // Parameters and signals for UUT

    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 3;

    logic wr_en;
    logic [ADDR_WIDTH-1:0] w_addr, r_addr;
    logic [DATA_WIDTH-1:0] w_data, r_data;

    reg_file #(DATA_WIDTH, ADDR_WIDTH) uut(.*);

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
        wr_en = 1'b0;
        w_addr = 2'b00;
        w_data = 8'h00;
        r_addr = 2'b00;

        @(posedge reset_n); // Wait for the reset.
        @(negedge clk);

        // Write to all addresses a byte.
        wr_en = 1'b1;
        for (logic [DATA_WIDTH-1:0] i=0; i < 2**ADDR_WIDTH; i++) begin
            w_addr = i;
            w_data = 8'hf0 + i;
            @(negedge clk);
        end
        wr_en = 1'b0;
        w_addr = 2'b00;
        w_data = 8'h00;

        // Read all addresses.
        for (logic [DATA_WIDTH-1:0] i=0; i < 2**ADDR_WIDTH; i++) begin
            r_addr = i;
            @(negedge clk);
        end

        $stop;
    end
endmodule
