module top
    #(
        parameter real  CLK_FREQ = 100_000_000, // 100 Mhz, 10 ns
                  real  BAUDRATE = 115_200
    )
    (
        input logic clk,
        input logic reset_n,
        input logic uart_txd_in,
        output logic uart_rxd_out
    );
    
    logic tick;
    
    // ~~ Create uart_baudrate_gen unit ~~ //

    uart_baudrate_gen #(.CLK_FREQ(CLK_FREQ), .BAUDRATE(BAUDRATE)) uart_baudrate_gen_unit(
        .clk(clk),
        .reset_n(reset_n),
        .tick(tick)
    );

    // ~~ Create uart_tx unit //

    uart_tx uart_tx_unit(
        .clk(clk),
        .reset_n(reset_n),
        .tick(tick)
    );

    // ~~ Assignment of outputs ~~ //

endmodule
