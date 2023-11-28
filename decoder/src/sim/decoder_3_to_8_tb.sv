`timescale 1ns / 10ps

module decoder_3_to_8_tb;
    logic [2:0] test_in;
    logic [7:0] test_out;

    decoder_3_to_8 uut(
        .in(test_in),
        .out(test_out)
    );

    initial
    begin
        test_in = 3'b000; // in = 0
        # 200;
        test_in = 3'b001; // in = 1
        # 200;
        test_in = 3'b010; // in = 2
        # 200;
        test_in = 3'b011; // in = 3
        # 200;
        test_in = 3'b100; // in = 4
        # 200;
        test_in = 3'b101; // in = 5
        # 200;
        test_in = 3'b110; // in = 6
        # 200;
        test_in = 3'b111; // in = 7
        # 200;
        $stop;
    end
endmodule
