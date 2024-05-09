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
    logic data_valid;
    logic data_ready;

    i2s_cdc uut(
        .i_clk(clk),
        .i_clk_12_288(clk_i2s),
        .i_reset_n(reset_n),
        .i_audio_l(audio_l),
        .i_audio_r(audio_r),
        .i_data_valid(data_valid),
        // Outputs
        .o_data_ready(data_ready),
        .o_tx_mclk(tx_mclk),
        .o_tx_sclk(tx_sclk),
        .o_tx_lrclk(tx_lrclk),
        .o_tx_sd(tx_sd)
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
        data_valid = 1'b0;
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
                    wait(data_ready); // On data_ready latch the new audio data.
                    audio_l = 16'haaaa-i;
                    audio_r = 16'haaaa+i;
                    @(posedge clk); // Create a tick on data_valid for 1 clk cycle.
                    data_valid = 1'b1;
                    @(posedge clk);
                    data_valid = 1'b0;
                end
            end
            // Read sample data
            begin
                for(int i = 0; i < 10; i++) begin
                    @(negedge tx_lrclk); // Wait for lrclk to fall and one sclk cycle.
                    @(posedge tx_sclk);

                    get_tx_data(sent_data);
                    assert(sent_data == 16'haaaa-i) else $fatal("[tx_sd] Expected 0x%h to be 0x%h.", sent_data, 16'haaaa-i);

                    @(posedge tx_lrclk); // Wait for lrclk to rise and one sclk cycle.
                    @(posedge tx_sclk);

                    get_tx_data(sent_data);
                    assert(sent_data == 16'haaaa+i) else $fatal("[tx_sd] Expected 0x%h to be 0x%h.", sent_data, 16'haaaa+i);
                end
            end
        join_any
    end
endmodule
