module top 
    (
        input logic [3:0] sw, btn,
        output logic [7:0] led
    );
    
    decoder_3_to_8 decoder1(
        .in(sw[2:0]),
        .out(led)
    );
endmodule
