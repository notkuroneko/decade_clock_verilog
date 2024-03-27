module decade_counter(
	input rst_n,
	input mode,
	input clk,
	output logic [7:0] sec_7seg,
	output logic [7:0] min_7seg,
	output logic [7:0] hour_7seg,
	output logic [7:0] day_7seg,
	output logic [7:0] month_7seg,
	output logic [7:0] year_7seg
);
	reg [5:0] sec_bin;
	reg [5:0] min_bin;
	reg [4:0] hour_bin;
	reg [4:0] day_bin;
	reg [3:0] month_bin;
	reg [13:0] year_bin;
	
	always @(posedge clk or negedge rst_n)
	begin
		if (~rst_n)
		begin //reset to 00:00:00, 01/01/2024
			sec_7seg <= 0;
			min_7seg <= 0;
			hour_7seg <= 0;
			day_7seg <= 0;
			month_7seg <= 0;
			year_7seg <= 0;
		end
		else
		begin
			day_bin <= day_bin + 1; //day block
			if (month_bin==4'd1||month_bin==4'd3||month_bin==4'd5||month_bin==4'd7||month_bin==4'd8||month_bin==4'd10||month_bin==4'd12)
			begin
				if (day_bin==5'd31) {day_bin <= 5'd1; month_bin <= month_bin + 1}
			end
			else if (month_bin==4'd4||month_bin==4'd6||month_bin==4'd9||month_bin==4'd11)
			begin
				if (day_bin==5'd30) {day_bin <= 5'd1;  month_bin <= month_bin + 1}
			end
			else if (month_bin==4'd2)
			begin
				if (!year_bin%4&&day_bin==5'd29) {day_bin <= 5'd1;  month_bin <= month_bin + 1}
				else if (year_bin%4&&day_bin==5'd28) {day_bin <= 5'd1;  month_bin <= month_bin + 1}
			end
			if (month_bin==4'd12) {month_bin <= 1; year_bin <= year_bin + 1}
			if (year_bin==14'd9999) year_bin <= 14'd0;
		end
	end
endmodule

module bin_to_7seg(	
	input [3:0] w_bcd,
	output logic [6:0] w_seg7
);
	// seven segggggment display
	always @(w_bcd)
	begin
		case(w_bcd)
			4'd0: w_seg7 <= ~7'b0111111;
			4'd1: w_seg7 <= ~7'b0000110;   
			4'd2: w_seg7 <= ~7'b1011011;   
			4'd3: w_seg7 <= ~7'b1001111;    
			4'd4: w_seg7 <= ~7'b1100110; 
			4'd5: w_seg7 <= ~7'b1101101;  
			4'd6: w_seg7 <= ~7'b1111101;    
			4'd7: w_seg7 <= ~7'b0000111;   
			4'd8: w_seg7 <= ~7'b1111111; 
			4'd9: w_seg7 <= ~7'b1101111;  
			default : w_seg7 <= 7'b0000000;
		endcase
	end

endmodule : bin_to_7seg


