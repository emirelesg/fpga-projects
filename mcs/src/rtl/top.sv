module top
    (
        input logic clk,
        input logic reset_n,
        input logic uart_txd_in,
        output logic uart_rxd_out
    );

    design_1 design_1_unit (
        .clk(clk),
        .reset_n(reset_n),
        .rx(uart_txd_in),
        .tx(uart_rxd_out)
    );
endmodule
