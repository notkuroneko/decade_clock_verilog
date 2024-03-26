module bin_to_7seg (
	input [3:0] w_bcd,
	output reg[6:0] w_seg7
);
reg [3:0] s;
	always @(w_bcd) 
	begin
		s = w_bcd[3]*8 + w_bcd[2]*4 + w_bcd[1]*2 + w_bcd[1];	
		case (s)
			4'h0: begin
				w_seg7[6] = 1;
				w_seg7[5] = 1;
				w_seg7[4] = 1;
				w_seg7[3] = 1;
				w_seg7[2] = 1;
				w_seg7[1] = 1;
				w_seg7[0] = 0;
			end
			4'h1: begin
				w_seg7[6] = 0;
				w_seg7[5] = 1;
				w_seg7[4] = 1;
				w_seg7[3] = 0;
				w_seg7[2] = 0;
				w_seg7[1] = 0;
				w_seg7[0] = 0;
			end
			4'h2: begin
				w_seg7[6] = 1;
				w_seg7[5] = 1;
				w_seg7[4] = 0;
				w_seg7[3] = 1;
				w_seg7[2] = 1;
				w_seg7[1] = 0;
				w_seg7[0] = 1;
			end
			4'h3: begin
				w_seg7[6] = 1;
				w_seg7[5] = 1;
				w_seg7[4] = 1;
				w_seg7[3] = 1;
				w_seg7[2] = 0;
				w_seg7[1] = 0;
				w_seg7[0] = 1;
			end
			4'h4: begin
				w_seg7[6] = 0;
				w_seg7[5] = 1;
				w_seg7[4] = 1;
				w_seg7[3] = 0;
				w_seg7[2] = 0;
				w_seg7[1] = 1;
				w_seg7[0] = 1;
			end
			4'h5: begin
				w_seg7[6] = 1;
				w_seg7[5] = 0;
				w_seg7[4] = 1;
				w_seg7[3] = 1;
				w_seg7[2] = 0;
				w_seg7[1] = 1;
				w_seg7[0] = 1;
			end
			4'h6: begin
				w_seg7[6] = 1;
				w_seg7[5] = 0;
				w_seg7[4] = 1;
				w_seg7[3] = 1;
				w_seg7[2] = 1;
				w_seg7[1] = 1;
				w_seg7[0] = 1;
			end
			4'h7: begin
				w_seg7[6] = 1;
				w_seg7[5] = 1;
				w_seg7[4] = 1;
				w_seg7[3] = 0;
				w_seg7[2] = 0;
				w_seg7[1] = 0;
				w_seg7[0] = 0;
			end
			4'h8: begin
				w_seg7[6] = 1;
				w_seg7[5] = 1;
				w_seg7[4] = 1;
				w_seg7[3] = 1;
				w_seg7[2] = 1;
				w_seg7[1] = 1;
				w_seg7[0] = 1;
			end
			4'h9: begin
				w_seg7[6] = 1;
				w_seg7[5] = 1;
				w_seg7[4] = 1;
				w_seg7[3] = 1;
				w_seg7[2] = 0;
				w_seg7[1] = 1;
				w_seg7[0] = 1;
			end
			4'hA: begin
				w_seg7[6] = 1;
				w_seg7[5] = 1;
				w_seg7[4] = 1;
				w_seg7[3] = 0;
				w_seg7[2] = 1;
				w_seg7[1] = 1;
				w_seg7[0] = 1;
			end
			4'hB: begin
				w_seg7[6] = 0;
				w_seg7[5] = 0;
				w_seg7[4] = 1;
				w_seg7[3] = 1;
				w_seg7[2] = 1;
				w_seg7[1] = 1;
				w_seg7[0] = 1;
			end
			4'hC: begin
				w_seg7[6] = 1;
				w_seg7[5] = 0;
				w_seg7[4] = 0;
				w_seg7[3] = 1;
				w_seg7[2] = 1;
				w_seg7[1] = 1;
				w_seg7[0] = 0;
			end
			4'hD: begin
				w_seg7[6] = 0;
				w_seg7[5] = 1;
				w_seg7[4] = 1;
				w_seg7[3] = 1;
				w_seg7[2] = 1;
				w_seg7[1] = 0;
				w_seg7[0] = 1;
			end
			4'hE: begin
				w_seg7[6] = 1;
				w_seg7[5] = 0;
				w_seg7[4] = 0;
				w_seg7[3] = 1;
				w_seg7[2] = 1;
				w_seg7[1] = 1;
				w_seg7[0] = 1;
			end
			4'hF: begin
				w_seg7[6] = 1;
				w_seg7[5] = 0;
				w_seg7[4] = 0;
				w_seg7[3] = 0;
				w_seg7[2] = 1;
				w_seg7[1] = 1;
				w_seg7[0] = 1;
			end
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
	endc
endmodule
// 0000 -> 1111110
// 0001 -> 0110000
// 0010 -> 1101101
// 0011 -> 1111001
// 0100 -> 0110011
// 0101 -> 1011011
// 0110 -> 1011111
// 0111 -> 1110000
// 1000 -> 1111111
// 1001 -> 1111011
// 1010 -> 1110111
// 1011 -> 0011111
// 1100 -> 1001110
// 1101 -> 0111101
// 1110 -> 1001111
// 1111 -> 1000111