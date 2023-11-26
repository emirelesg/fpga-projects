module top
    #(
        parameter real  CLK_FREQ = 100_000_000, // 100 Mhz, 10 ns
                  real  BAUDRATE = 115_200
    )
    (
        input logic clk,
        input logic reset_n,
        input logic btn,
        input logic uart_txd_in,
        output logic uart_rxd_out
    );

    logic [7:0] tx_data = 'h58; // X

    // ~~ Create debouncer_fsm unit ~~ //

    logic btn_db;

    debouncer_fsm #(.DB_TIME(0.100)) debouncer_fsm_unit(
        .clk(clk),
        .reset_n(reset_n),
        .sw(btn),
        .db(btn_db)
    );

    // ~~ Create uart unit ~~ //

    uart uart_unit(
        .clk(clk),
        .reset_n(reset_n),
        .tx_start(btn_db),
        .tx_data(tx_data),
        .tx(uart_rxd_out)
    );

    // ~~ Assignment of outputs ~~ //

endmodule
