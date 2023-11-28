module top
    (
        input logic [3:0] sw, btn,
        output logic [7:0] led
    );

    /* ~~ Create decoder_3_to_8 unit ~~ */

    decoder_3_to_8 decoder_unit(
        .in(sw[2:0]),
        .out(led)
    );
endmodule
