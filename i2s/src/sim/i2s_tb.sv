`timescale 1ns / 10ps

module i2s_tb;
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
    logic data_ready;

    i2s uut(
        .i_clk_12_288(clk_i2s),
        .i_reset_n(reset_n),
        .i_audio_l(audio_l),
        .i_audio_r(audio_r),
        // Outputs
        .o_tx_mclk(tx_mclk),
        .o_tx_sclk(tx_sclk),
        .o_tx_lrclk(tx_lrclk),
        .o_tx_sd(tx_sd),
        .o_data_ready(data_ready)
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
        @(negedge clk);
        reset_n = 1'b1;
    end

    // Initial values for signals.
    initial begin
        audio_l = 16'b00101010_10101010;
        audio_r = 16'b01010101_01010111;

        // Stop the test after this delay in case of a bug.
        #(10 * 16 * 2 * 2 * T_I2S); // 10 lrclk cycles * 16 bits * 2 channels * 2 dvsr * T
        $finish;
    end

   assert_tx_sclk:
    assert
        property (
            @(posedge tx_mclk) disable iff (~reset_n)
            // The mclk/sclk ratio should be 2.
            $rose(tx_sclk) |-> ##1 $fell(tx_sclk) ##1 $rose(tx_sclk)
        )
        else
            $fatal("[tx_sclk] Expected signal to be tx_mclk/2");

    assert_tx_lrclk:
    assert
        property (
            @(posedge tx_mclk) disable iff (~reset_n)
            // The mclk/lrclk ratio should be 128.
            $rose(tx_lrclk) |-> ##64 $fell(tx_lrclk) ##64 $rose(tx_lrclk)
        )
        else
            $fatal("[tx_lrclk] Expected signal to be tx_mclk/128");

   assert_data_ready:
    assert
        property (
            @(posedge tx_mclk) disable iff (~reset_n)
            // The data_ready should tick on the first tx_sclk after lrclk.
            $rose(data_ready) |-> ##1 $fell(data_ready) ##127 $rose(data_ready)
        )
        else
            $fatal("[data_ready] Expected signal to tick every 128 tx_mclk.");

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
        fork
            // Read sample data
            begin
                @(negedge tx_lrclk); // Wait for lrclk to fall and one sclk cycle.
                @(posedge tx_sclk);

                get_tx_data(sent_data);
                assert(sent_data == audio_l) else $fatal("[tx_sd] Expected 0x%h to be 0x%h.", sent_data, audio_l);

                @(posedge tx_lrclk); // Wait for lrclk to rise and one sclk cycle.
                @(posedge tx_sclk);

                get_tx_data(sent_data);
                assert(sent_data == audio_r) else $fatal("[tx_sd] Expected 0x%h to be 0x%h.", sent_data, audio_r);
            end
        join_any
    end
endmodule
