module bin_to_7seg (
	input [3:0] w_bcd,
	output logic [6:0] w_seg7
);
	always @(w_bcd) 
	begin
		case (w_bcd)
			4'h0: w_seg7 = 7'd62;
			4'h1: w_seg7 = 7'd48;
			4'h2: w_seg7 = 7'd109;
			4'h3: w_seg7 = 7'd121;
			4'h4: w_seg7 = 7'd51;
			4'h5: w_seg7 = 7'd91;
			4'h6: w_seg7 = 7'd95;
			4'h7: w_seg7 = 7'd112;
			4'h8: w_seg7 = 7'd127;
			4'h9: w_seg7 = 7'd123;
			4'hA: w_seg7 = 7'd119;
			4'hB: w_seg7 = 7'd31;
			4'hC: w_seg7 = 7'd78;
			4'hD: w_seg7 = 7'd61;
			4'hE: w_seg7 = 7'd79;
			4'hF: w_seg7 = 7'd71;
		endcase
	end
endmodule

`timescale 1ns/1ps

module bin_to_7seg_test();
	reg [3:0] stim_bcd;
	reg [6:0] out_seg7;
	
	bin_to_7seg test(.w_bcd(stim_bcd), .w_seg7(stim_seg7));
	
	initial
	begin
		stim_bcd = 4'd13;
		#5 stim_bcd = 4'd4;
		#5 stim_bcd = 4'd8;
	end
endmodule
// 0000 -> 1111110 = 62
// 0001 -> 0110000 = 48
// 0010 -> 1101101 = 109
// 0011 -> 1111001 = 121
// 0100 -> 0110011 = 51
// 0101 -> 1011011 = 91
// 0110 -> 1011111 = 95
// 0111 -> 1110000 = 112
// 1000 -> 1111111 = 127
// 1001 -> 1111011 = 123
// 1010 -> 1110111 = 119
// 1011 -> 0011111 = 31
// 1100 -> 1001110 = 78
// 1101 -> 0111101 = 61
// 1110 -> 1001111 = 79
// 1111 -> 1000111 = 71 