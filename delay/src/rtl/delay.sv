/*
 * delay
 *
 * An audio delay module.
 *
 * Inspired on:
 * - https://www.rtlaudiolab.com/017-fpga-mono-delay/
 * - https://wiki.analog.com/resources/tools-software/sharc-audio-module/baremetal/delay-effect-tutorial
 */

`include "i2s_map.svh"
module delay
    #(
        parameter   ADDR_WIDTH = 14
    )
    (
        input   logic                               i_clk,
        input   logic                               i_reset_n,
        input   logic           [ADDR_WIDTH-1:0]    i_delay,
        input   logic signed    [`DATA_BIT-1:0]     i_feedback,
        input   logic signed    [`DATA_BIT-1:0]     i_wet,
        input   logic signed    [`DATA_BIT-1:0]     i_dry,
        input   logic signed    [`DATA_BIT-1:0]     i_audio,
        input   logic                               i_audio_valid,
        output  logic signed    [`DATA_BIT-1:0]     o_audio
    );
    
	logic signed [`DATA_BIT-1:0] delayed;
    logic [ADDR_WIDTH-1:0] r_ptr_reg, w_ptr_reg, r_ptr_next;
    
	logic signed [`DATA_BIT:0] a1, a2;
	logic signed [`DATA_BIT-1:0] a1_clamped, a2_clamped;
	logic signed [31:0] m1, m2, m3; // Q18.14
	
	always_ff @(posedge i_clk, negedge i_reset_n) begin
	   if (~i_reset_n)
	       r_ptr_reg <= 1;
	   else
	       r_ptr_reg <= r_ptr_next;
	end
	
	always_comb begin
	   if (i_audio_valid)
	       if (r_ptr_reg == i_delay)
	           r_ptr_next = 0;
	       else
	           r_ptr_next = r_ptr_reg + 1;
	   else
	       r_ptr_next = r_ptr_reg;
	end
	
	// The write pointer is always one position behind the read pointer.
	assign w_ptr_reg = r_ptr_reg - 1;
	
	reg_file #(
	   .DATA_WIDTH(`DATA_BIT),
	   .ADDR_WIDTH(ADDR_WIDTH),
	   .MEMORY_TYPE("bram")
    ) reg_file_unit (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_wr_en(i_audio_valid),
        .i_w_addr(w_ptr_reg),
        .i_w_data(a1_clamped),
        .i_r_addr(r_ptr_reg),
        // Outputs
        .o_r_data(delayed)
    );
    
    always_ff @(posedge i_clk) begin
        m1 <= delayed * i_feedback; // Feedback
        m2 <= delayed * i_wet;      // Wet mix
        m3 <= i_audio * i_dry;      // Dry mix
    end
    
    assign a1 = i_audio + trim_mul_16(m1);          // a1 = i_audio + (delayed * i_feedback)
    assign a1_clamped = clamp_16(a1);               // To the fifo.
    assign a2 = trim_mul_16(m3) + trim_mul_16(m2);  // a2 = (i_audio * i_dry) + (delayed * i_wet); 
    assign a2_clamped = clamp_16(a2);               // To the output.
    
    assign o_audio = a2_clamped;
endmodule
