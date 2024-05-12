`timescale 1ns / 10ps

module i2s_tb;
    localparam T=10; // 100 MHz
    localparam T_I2S=81.38; // 12.288 MHz

    logic clk;
    logic clk_i2s;
    logic reset_n;

    logic [63:0] rx_data, tx_data;
    logic [15:0] audio_l, audio_r;
    logic audio_valid;
    logic mclk, sclk, lrclk;
    logic tx_sd, rx_sd;

    i2s uut(
        .i_clk_12_288(clk_i2s),
        .i_reset_n(reset_n),
        .i_audio_l(audio_l),
        .i_audio_r(audio_r),
        .i_rx_sd(rx_sd),
        // Outputs
        .o_audio_l(audio_l),
        .o_audio_r(audio_r),
        .o_audio_valid(audio_valid),
        .o_mclk(mclk),
        .o_sclk(sclk),
        .o_lrclk(lrclk),
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
        @(negedge clk);
        reset_n = 1'b1;
    end

    // Initial values for signals.
    initial begin
        tx_data = 0;
        rx_data = 0;
        rx_sd = 1'b0;

        // Stop the test after this delay in case of a bug.
        #(13 * 64 * 2 * T_I2S); // 13 lrclk cycles * 64 bits per frame * 2 dvsr * T
        $finish;
    end

   assert_tx_sclk:
    assert
        property (
            @(posedge mclk) disable iff (~reset_n)
            // The mclk/sclk ratio should be 2.
            $rose(sclk) |-> ##1 $fell(sclk) ##1 $rose(sclk)
        )
        else
            $fatal("[tx_sclk] Expected signal to be mclk/2");

    assert_tx_lrclk:
    assert
        property (
            @(posedge mclk) disable iff (~reset_n)
            // The mclk/lrclk ratio should be SCLK_MCLK_RATIO.
            $rose(lrclk) |-> ##64 $fell(lrclk) ##64 $rose(lrclk)
        )
        else
            $fatal("[tx_lrclk] Expected signal to be mclk/64");

   assert_data_ready:
    assert
        property (
            @(posedge mclk) disable iff (~reset_n)
            // The audio_valid should tick on the first tx_sclk after lrclk.
            $rose(audio_valid) |-> ##1 $fell(audio_valid) ##127 $rose(audio_valid)
        )
        else
            $fatal("[data_ready] Expected signal to tick every 128 mclk.");

    task get_tx_data;
        output [63:0] tx_data;
        begin
            tx_data = 0;
            for (int i = 63; i >= 0; i--) begin
                @(posedge sclk);
                tx_data[i] = tx_sd;
                $display("%t [tx] %2d: %b", $time, i, tx_sd);
            end
            $display("[tx] Received 0x%h", tx_data);
        end
    endtask

    task set_rx_data;
        input [15:0] rx_audio_l;
        input [15:0] rx_audio_r;

        rx_data = {rx_audio_l, 16'd0, rx_audio_r, 16'd0};

        begin
            for (int i = 63; i >= 0; i--) begin
                @(negedge sclk);
                rx_sd = rx_data[i];
                $display("%t [rx] %2d: %b", $time, i, rx_sd);
            end
            $display("[rx] Sent 0x%h", rx_data);
        end
    endtask

    initial begin
        @(posedge reset_n);

        fork
            // Simulate data to be received.
            begin
                for (int i = 0; i < 10; i++) begin
                    @(posedge sclk);

                    set_rx_data(16'hc000 + i, i[3:0]);
                end

                set_rx_data(16'd0, 16'd0);
            end
            // Test i2s_rx is receiving data.
            begin
                @(negedge lrclk); // Waits for the simulated data to be received.

                for (int i = 0; i < 10; i++) begin
                    @(posedge audio_valid);

                    assert(audio_l == 16'hc000 + i) else $fatal("[rx/left] Expected 0x%h to be 0x%h.", audio_l, 16'hc000 + i);
                    assert(audio_r == i) else $fatal("[rx/right] Expected 0x%h to be 0x%h.", audio_r, i);
               end
            end
            // Test i2s_tx is sending data.
            begin
                @(negedge lrclk); // Wait for the simulated data to be received.
                @(negedge lrclk); // Waits for the data to be loaded for transmission.
                @(posedge sclk);  // Wait for the frame to end.

                for (int i = 0; i < 10; i++) begin
                    get_tx_data(tx_data);

                    assert(tx_data[63:48] == 16'hc000 + i) else $fatal("[tx/left] Expected 0x%h to be 0x%h.", tx_data[63:48], 16'hc000 + i);
                    assert(tx_data[31:16] == i) else $fatal("[tx/right] Expected 0x%h to be 0x%h.", tx_data[31:16], i);
               end
            end
        join_any
    end
endmodule
