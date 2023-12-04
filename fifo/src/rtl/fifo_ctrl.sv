/*
 * fifo_ctrl
 *
 * Control the read and write pointes for a circular queue.
 */

module fifo_ctrl
    #(
        parameter   ADDR_WIDTH = 2
    )
    (
        input logic clk,
        input logic reset_n,
        input logic rd, wr,
        output logic empty, full,
        output logic [ADDR_WIDTH-1:0] w_addr,
        output logic [ADDR_WIDTH-1:0] r_addr
    );

    logic full_reg, full_next;
    logic empty_reg, empty_next;
    logic [ADDR_WIDTH-1:0] w_ptr_reg, w_ptr_next, w_ptr_inc;
    logic [ADDR_WIDTH-1:0] r_ptr_reg, r_ptr_next, r_ptr_inc;

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
        end
        else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
        end
    end

    always_comb begin
        // Default values:
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        full_next = full_reg;
        empty_next = empty_reg;

        w_ptr_inc = w_ptr_reg + 1;
        r_ptr_inc = r_ptr_reg + 1;

        unique case ({wr, rd})
            // Read if fifo is not empty.
            2'b01:
                if (~empty_reg) begin
                    r_ptr_next = r_ptr_inc;
                    full_next = 1'b0; // Not full because an element was read.
                    if (r_ptr_inc == w_ptr_reg)
                        empty_next = 1'b1;
                end
            // Write if fifo is not full.
            2'b10:
                if (~full_reg) begin
                    w_ptr_next = w_ptr_inc;
                    empty_next = 1'b0; // Not empty because an element was written.
                    if (w_ptr_inc == r_ptr_reg)
                        full_next = 1'b1;
                end
            // Read and Write
            2'b11: begin
                w_ptr_next = w_ptr_inc;
                r_ptr_next = r_ptr_inc;
            end
             // 2'b00: No operation
            default: ;
        endcase
    end

    assign w_addr = w_ptr_reg;
    assign r_addr = r_ptr_reg;
    assign full = full_reg;
    assign empty = empty_reg;
endmodule
