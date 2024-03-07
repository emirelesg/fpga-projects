`timescale 1ns / 10ps

module i2s_tb;
    localparam T=10; // 100 MHz
    localparam T_I2S=40.69; // 24.576 MHz

    logic clk;
    logic clk_i2s;
    logic reset_n;

    logic [15:0] audio_l;
    logic [15:0] audio_r;
    logic tx_mclk;
    logic tx_sclk;
    logic tx_lrclk;
    logic tx_sd;

    i2s uut(
        .clk(clk),
        .clk_i2s(clk),
        .reset_n(reset_n),
        .audio_l(audio_l),
        .audio_r(audio_r),
        // Outputs
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk),
        .tx_lrclk(tx_lrclk),
        .tx_sd(tx_sd)
    );
    // Simulate a 100 MHz clock signal.
    initial clk = 0;
    always clk = #(T/2) ~clk;

    // Simulate a 24.576 MHz clock signal.
    initial clk_i2s = 0;
    always clk_i2s = #(T_I2S/2) ~clk_i2s;

    // Reset at the start of the simulation.
    initial begin
        reset_n = 1'b0;
        repeat(2) @(negedge clk); // 2 cycles to let the signal cross domains.
        reset_n = 1'b1;
    end

    // Initial values for signals.
    initial begin
        audio_l = 16'hdead;
        audio_r = 16'hbeef;

        // Stop the test after this delay in case of a bug.
        #((16 * 2 + 1) * 16 * T_I2S); // (16 bits * 2 channels + 1 sclk delay) * 16 dvsr * T
        $finish;
    end

   assert_tx_sclk:
    assert
        property (
            @(posedge tx_mclk) disable iff (~reset_n)
            // After tx_sclk rises, wait two clk cycles and ts_sclk should fall,
            // after two more clk cycles, it should rise.
            $rose(tx_sclk) |-> ##8 $fell(tx_sclk) ##8 $rose(tx_sclk)
        )
        else
            $fatal("[tx_sclk] Expected signal to be tx_mclk/8");


    assert_tx_lrclk:
    assert
        property (
            @(posedge tx_mclk) disable iff (~reset_n)
            // After tx_sclk rises, wait two clk cycles and ts_sclk should fall,
            // after two more clk cycles, it should rise.
            $rose(tx_lrclk) |-> ##256 $fell(tx_lrclk) ##256 $rose(tx_lrclk)
        )
        else
            $fatal("[tx_lrclk] Expected signal to be tx_mclk/256");

    task get_tx_data;
        output [15:0] sent_data;
        begin
            sent_data = 0;
            for (int i = 15; i >= 0; i--) begin
                @(negedge tx_sclk);
                $display("%t [tx_sd] %2d: %b", $time, i, tx_sd);
                sent_data[i] = tx_sd;
            end
            $display("[tx_sd] Sent 0x%h", sent_data);
        end
    endtask

    initial begin
        @(posedge reset_n);
        repeat(4) @(negedge tx_lrclk);
        fork
            begin
                logic [15:0] sent_data;
                get_tx_data(sent_data);
                assert(sent_data == audio_l) else $fatal("[tx_sd] Expected 0x%h to be 0x%h.", sent_data, audio_l);
                get_tx_data(sent_data);
                assert(sent_data == audio_r) else $fatal("[tx_sd] Expected 0x%h to be 0x%h.", sent_data, audio_r);
            end
        join
    end
endmodule
