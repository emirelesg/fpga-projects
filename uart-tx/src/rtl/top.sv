module top
    (
        input logic clk,
        input logic reset_n,
        input logic uart_txd_in,
        output logic uart_rxd_out
    );

    // ~~ Create uart_baudrate_gen unit ~~ //

    uart_baudrate_gen uart_baudrate_gen_unit(
        .clk(clk),
        .reset_n(reset_n)
    );

    // ~~ Create uart_tx unit //

    uart_tx uart_tx_unit(
        .clk(clk),
        .reset_n(reset_n)
    );

    // ~~ Assignment of outputs ~~ //

endmodule
