/*
 * uart_tx
 * 
 */

module uart_tx
    (
        input logic clk,
        input logic reset_n,
        input logic tick
    );
    
    always_ff @(posedge clk, negedge reset_n) begin
    end

endmodule
