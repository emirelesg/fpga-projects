/*
 * uart_baudrate_gen
 *
 */

module uart_baudrate_gen
    #(
        parameter real  CLK_FREQ = 100_000_000, // 100 Mhz, 10 ns
                        BAUDRATE = 115_200
    )
    (
        input logic clk,
        input logic reset_n,
        output logic s_tick
    );

    localparam DVSR = $rtoi(CLK_FREQ / BAUDRATE / 16) - 1;

    logic [$clog2(DVSR)-1:0] q_reg, q_next;

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n)
            q_reg <= 0;
        else
            q_reg <= q_next;
    end

    assign q_next = (q_reg == DVSR) ? 0 : q_reg + 1;

    /* ~~ Assignment of outputs ~~ */

    assign s_tick = q_reg == 1;
endmodule
