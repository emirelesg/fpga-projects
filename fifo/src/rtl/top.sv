module top
    (
        input logic clk,
        input logic reset_n
    );

    /* ~~ Initialize reg_file unit ~~ */

    reg_file reg_file_unit (.*);
endmodule
