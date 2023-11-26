module uart
    #(
        parameter real  CLK_FREQ = 100_000_000, // 100 Mhz, 10 ns
                  real  BAUDRATE = 115_200
    )
    (
        input logic clk,
        input logic reset_n,
        input logic tx_start,
        input logic [7:0] tx_data,
        input logic rx,
        output logic tx
    );

    /* ~~ Create uart_baudrate_gen unit ~~ */

    logic s_tick;

    uart_baudrate_gen #(.CLK_FREQ(CLK_FREQ), .BAUDRATE(BAUDRATE)) uart_baudrate_gen_unit(
        .clk(clk),
        .reset_n(reset_n),
        .s_tick(s_tick)
    );

    /* ~~ Create uart_tx unit ~~ */

    logic tx_done_tick;

    uart_tx uart_tx_unit(
        .clk(clk),
        .reset_n(reset_n),
        .s_tick(s_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

endmodule
