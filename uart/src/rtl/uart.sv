/*
 * uart
 *
 * Wrapper for all UART related modules.
 */

module uart
    #(
        parameter real  CLK_FREQ = 100_000_000, // 100 Mhz, 10 ns
                        BAUDRATE = 115_200,
        parameter       DATA_BIT = 8,
                        STOP_BIT = 1,
                        FIFO_WIDTH = 4 // 2^4 or 16 bytes
    )
    (
        input logic clk,
        input logic reset_n,
        input logic wr,
        input logic [DATA_BIT-1:0] w_data,
        output logic tx
    );

    /* ~~ Create uart_baudrate_gen unit ~~ */

    logic s_tick;

    uart_baudrate_gen #(.CLK_FREQ(CLK_FREQ), .BAUDRATE(BAUDRATE)) uart_baudrate_gen_unit(
        .clk(clk),
        .reset_n(reset_n),
        // Outputs
        .s_tick(s_tick)
    );

    /* ~~ Create uart_tx unit ~~ */

    logic uart_tx_done_tick;

    uart_tx #(.DATA_BIT(DATA_BIT), .STOP_BIT(STOP_BIT)) uart_tx_unit(
        .clk(clk),
        .reset_n(reset_n),
        .s_tick(s_tick),
        .tx_start(fifo_tx_not_empty), // Start sending as soon as fifo is not empty.
        .tx_data(fifo_tx_out),
        // Outputs
        .tx_done_tick(uart_tx_done_tick),
        .tx(tx)
    );

    /* ~~ Create fifo_tx unit ~~ */

    logic fifo_tx_empty, fifo_tx_not_empty, fifo_tx_full;
    logic [DATA_BIT-1:0] fifo_tx_out;

    fifo #(.DATA_WIDTH(DATA_BIT), .ADDR_WIDTH(FIFO_WIDTH)) fifo_tx_unit(
        .clk(clk),
        .reset_n(reset_n),
        .rd(uart_tx_done_tick), // Read the next byte after the previous byte is tranmitted.
        .wr(wr),
        .w_data(w_data),
        // Outputs
        .empty(fifo_tx_empty),
        .full(fifo_tx_full),
        .r_data(fifo_tx_out)
    );

    assign fifo_tx_not_empty = ~fifo_tx_empty;
endmodule
