`timescale 1ns / 10ps

module reg_file_tb;
    localparam T=10; // 100 Mhz, 10 ns

    logic clk;
    logic reset_n;

    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 3;

    logic wr_en;
    logic [ADDR_WIDTH-1:0] w_addr, r_addr;
    logic [DATA_WIDTH-1:0] w_data, r_data;

    reg_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MEMORY_FILE("bram_file.mem")
    ) uut(
        .i_clk(clk),
        .i_reset_n(reset_n),
        .i_wr_en(wr_en),
        .i_w_addr(w_addr),
        .i_r_addr(r_addr),
        .i_w_data(w_data),
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

    // Initial values for signals.
    initial begin
        wr_en = 1'b0;
        w_addr = 2'b00;
        w_data = 8'h00;
        r_addr = 2'b00;
    end
    
    initial begin
        @(posedge reset_n); // Wait for the reset.
        @(negedge clk);
        
        // Read all addresses.
        for (logic [DATA_WIDTH-1:0] i=0; i < 2**ADDR_WIDTH; i++) begin
            r_addr = i;
            @(negedge clk); // Wait for the data.
            assert(r_data == 8'hc0 + i) else $fatal("Expected r_data to be 0x%2h.", 8'hc0 + i);
        end

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
            @(negedge clk); // Wait for the data.
            assert(r_data == 8'hf0 + i) else $fatal("Expected r_data to be 0x%2h.", 8'hf0 + i);
        end

        $finish;
    end
endmodule
