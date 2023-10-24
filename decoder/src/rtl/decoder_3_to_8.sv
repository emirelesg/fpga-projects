module decoder_3_to_8
    (
        input logic [2:0] in,
        output logic [7:0] out
    );
    
    always_comb
    begin
        case (in)
            3'b000: out = 8'b0000_0001;
            3'b001: out = 8'b0000_0010;
            3'b010: out = 8'b0000_0100;
            3'b011: out = 8'b0000_1000;
            3'b100: out = 8'b0001_0000;
            3'b101: out = 8'b0010_0000;
            3'b110: out = 8'b0100_0000;
            3'b111: out = 8'b1000_0000;
        endcase
    end
endmodule
