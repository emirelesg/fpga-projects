`timescale 1ns / 10ps

module i2s_cdc_tb;
    localparam T=10; // 100 MHz
    localparam T_I2S=81.38; // 12.288 MHz

    logic clk;
    logic clk_i2s;
    logic reset_n;

    logic [15:0] sent_data;
    logic [15:0] audio_l;
    logic [15:0] audio_r;
    logic tx_mclk;
    logic tx_sclk;
    logic tx_lrclk;
    logic tx_sd;
    logic wr_en;
    logic wr_ready;

    i2s_cdc uut(
        .clk(clk),
        .clk_12_288(clk_i2s),
        .reset_n(reset_n),
        .audio_l(audio_l),
        .audio_r(audio_r),
        .wr_en(wr_en),
        // Outputs
        .wr_ready(wr_ready),
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk),
        .tx_lrclk(tx_lrclk),
        .tx_sd(tx_sd)
    );

    // Simulate a 100 MHz clock signal.
    initial clk = 0;
    always clk = #(T/2) ~clk;

    // Simulate a 12.288 MHz clock signal.
    initial clk_i2s = 0;
    always clk_i2s = #(T_I2S/2) ~clk_i2s;

    // Reset at the start of the simulation.
    initial begin
        reset_n = 1'b0;
        repeat(5) @(negedge clk); // 2 cycles to let the signal cross domains.
        reset_n = 1'b1;
    end


    // Initial values for signals.
    initial begin
        wr_en = 1'b0;
        sent_data = 0;
        audio_l = 0;
        audio_r = 0;

        // Stop the test after this delay in case of a bug.
        #(10 * 16 * 2 * 2 * T_I2S); // 10 lrclk cycles * 16 bits * 2 channels * 2 dvsr * T
        $finish;
    end

    task get_tx_data;
        output [15:0] sent_data;
        begin
            sent_data = 0;
            for (int i = 15; i >= 0; i--) begin
                @(posedge tx_sclk);
                $display("%t [tx_sd] %2d: %b", $time, i, tx_sd);
                sent_data[i] = tx_sd;
            end
            $display("[tx_sd] Sent 0x%h", sent_data);
        end
    endtask

    initial begin
        @(posedge reset_n);
        @(negedge tx_lrclk); // WARN: is this for the X -> 0 transition?
        @(negedge tx_lrclk); // Wait one lrclk cycle since the fifo is under reset.
        fork
            // Generate sample data
            begin
                for(int i = 0; i < 10; i++) begin
                    wait(wr_ready); // On wr_ready latch the new audio data.
                    audio_l = 16'haaaa-i;
                    audio_r = 16'haaaa+i;
                    @(posedge clk); // Create a tick on wr_en for 1 clk cycle.
                    wr_en = 1'b1;
                    @(posedge clk);
                    wr_en = 1'b0;
                end
            end
            // Read sample data
            begin
                @(negedge tx_lrclk); // Wait one lrclk cycle since data is delayed by one cycle.
                @(negedge tx_sclk); // Start latching data on the first sclk after lrclk falls.
                for(int i = 0; i < 10; i++) begin
                    get_tx_data(sent_data);
                    assert(sent_data == 16'haaaa-i) else $fatal("[tx_sd] Expected 0x%h to be 0x%h.", sent_data, 16'haaaa-i);
                    get_tx_data(sent_data);
                    assert(sent_data == 16'haaaa+i) else $fatal("[tx_sd] Expected 0x%h to be 0x%h.", sent_data, 16'haaaa+i);
                end
            end
        join_any
    end
endmodule
