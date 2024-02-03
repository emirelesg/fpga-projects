`timescale 1ns / 10ps

module i2s_tb;
    localparam T=81.38; // 12.288 Mhz

    logic clk;
    logic reset_n;

    logic [15:0] tx_data_l;
    logic [15:0] tx_data_r;
    logic tx_mclk;
    logic tx_sclk;
    logic tx_lrclk;
    logic tx_sd;

    i2s uut(
        .clk_i2s(clk),
        .reset_n(reset_n),
        .tx_data_l(tx_data_l),
        .tx_data_r(tx_data_r),
        // Outputs
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk),
        .tx_lrclk(tx_lrclk),
        .tx_sd(tx_sd)
    );

    // Simulate a 12.288 Mhz clock signal.
    initial clk = 0;
    always clk = #(T/2) ~clk;

    // Reset at the start of the simulation.
    initial begin
        reset_n = 1'b0;
        @(negedge clk)
        reset_n = 1'b1;
    end

    // Initial values for signals.
    initial begin
        tx_data_l = 16'hdead;
        tx_data_r = 16'hbeef;

        // Stop the test after this delay in case of a bug.
        #((24 * 2 + 1) * 4 * T); // (24 bits * 2 channels + 1 sclk delay) * 4 dvsr * T
        $finish;
    end

   assert_tx_sclk:
    assert
        property (
            @(posedge clk) disable iff (~reset_n)
            // After tx_sclk rises, wait two clk cycles and ts_sclk should fall,
            // after two more clk cycles, it should rise.
            $rose(tx_sclk) |-> ##2 $fell(tx_sclk) ##2 $rose(tx_sclk)
        )
        else
            $fatal("[tx_sclk] Expected signal to be clk/4");

    assert_tx_lrclk:
    assert
        property (
            @(posedge clk) disable iff (~reset_n)
            // After tx_sclk rises, wait two clk cycles and ts_sclk should fall,
            // after two more clk cycles, it should rise.
            $rose(tx_lrclk) |-> ##128 $fell(tx_lrclk) ##128 $rose(tx_lrclk)
        )
        else
            $fatal("[tx_lrclk] Expected signal to be clk/256");

    task get_tx_data;
        output [23:0] sent_data;
        begin
            sent_data = 0;
            for (int i = 23; i >= 0; i--) begin
                @(negedge tx_sclk);
                $display("%t [tx_sd] %2d: %b", $time, i, tx_sd);
                sent_data[i] = tx_sd;
            end
            $display("[tx_sd] Sent 0x%h", sent_data);
        end
    endtask

    initial begin
        @(posedge reset_n);
        fork
            begin
                logic [23:0] sent_data;
                get_tx_data(sent_data);
                assert(sent_data == {tx_data_l, 8'h00}) else $fatal("[tx_sd] Expected 0x%h to be 0x%h.", sent_data, {tx_data_l, 8'h00});
                get_tx_data(sent_data);
                assert(sent_data == {tx_data_r, 8'h00}) else $fatal("[tx_sd] Expected 0x%h to be 0x%h.", sent_data, {tx_data_r, 8'h00});
            end
        join
    end
endmodule
