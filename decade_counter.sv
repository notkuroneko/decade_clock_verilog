module decade_counter(
	input rst_n,
	input mode,
	input clk,
	input butt_increase,
	input butt_decrease,
	input butt_change,
	output logic [6:0] seg0,
	output logic [6:0] seg1,
	output logic [6:0] seg2,
	output logic [6:0] seg3,
	output logic [6:0] seg4,
	output logic [6:0] seg5,
	output logic [6:0] seg6,
	output logic [6:0] seg7);

	/***********************************************************
						Logic and computing
	***********************************************************/
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
			sec_bin 	<= 	6'd00;
			min_bin 	<= 	6'd00;
			hour_bin 	<= 	5'd00;
			day_bin		<=	5'd01;
			month_bin	<=	4'd01;
			year_bin	<=	14'd2024;
		end
		else
		begin
			/********************   TIME BLOCK   ********************/
			if (hour_bin == 5'd23 && min_bin == 6'd59 && sec_bin == 6'd59) 
			begin
				day_bin <= day_bin + 5'd1;
				
				hour_bin <= 5'd0;
				min_bin <= 6'd0;
				sec_bin <= 6'd0;
			end
			else if (min_bin == 6'd59 && sec_bin == 6'd59) 
			begin
				hour_bin <= hour_bin + 5'd1;

				min_bin <= 6'd0;
				sec_bin <= 6'd0;
			end
			else if (sec_bin == 6'd59) 
			begin
				min_bin <= min_bin + 6'd1;

				sec_bin <= 6'd0;
			end
			else 
			begin
				sec_bin <= sec_bin + 6'd1;
			end

			/********************   DATE BLOCK   ********************/
			reg dayChange;
			assign dayChange = ((hour_bin == 5'd23) && (min_bin == 6'd59) && (sec_bin == 6'd59);
			if ((dayChange)&&(month_bin==4'd1||month_bin==4'd3||month_bin==4'd5||month_bin==4'd7||month_bin==4'd8||month_bin==4'd10))
			begin
				if (day_bin==5'd31) 
				begin 
					day_bin <= 5'd1; 
					month_bin <= month_bin + 1;
				end;
			end
			else if (month_bin==4'd4||month_bin==4'd6||month_bin==4'd9||month_bin==4'd11)
			begin
				if (day_bin==5'd30) 
				begin
					day_bin <= 5'd1;  month_bin <= month_bin + 1;
				end
			end
			else if (month_bin==4'd2)
			begin
				if (!year_bin%4&&day_bin==5'd29) 
				begin 
					day_bin <= 5'd1;  month_bin <= month_bin + 1;
				end
				else if (year_bin%4&&day_bin==5'd28) 
				begin 
					day_bin <= 5'd1;  month_bin <= month_bin + 1;
				end
			end 
			if (month_bin==4'd12) 
			begin 
				month_bin <= 1; year_bin <= year_bin + 1;
			end
			if (year_bin==14'd9999) year_bin <= 14'd0;
		end
	end
endmodule

/*****************************************************************************************
								7 SEGMENT DECODER
*****************************************************************************************/
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


/* Valley of death

logic [3:0] sec1, sec0, min1, min0, hr1, hr0, day1, day0, month1, month0, year3, year2, year1, year0;
	logic [6:0] sec_7seg1, sec_7seg0, min_7seg1, min_7seg0, hour_7seg1, hour_7seg0, day_7seg1, day_7seg0, month_7seg1, month_7seg0, year_7seg3, year_7seg2, year_7seg1, year_7seg0;
	
	assign sec1 = sec_bin/10;
	assign sec0 = sec_bin%10;
	assign min1 = min_bin/10;
	assign min0 = min_bin%10;
	assign hr1 = hour_bin/10;
	assign hr0 = hour_bin%10;
	assign day1 = day_bin/10;
	assign day0 = day_bin%10;
	assign month1 = month_bin/10;
	assign month0 = month_bin%10;
	assign year3 = year_bin/1000;
	assign year2 = (year_bin%1000)/100;
	assign year1 = (year_bin%100)/10;
	assign year0 = year_bin%10;
	
	bin_to_7seg day1_dis (.w_bcd(day1), .w_seg7(day_7seg1));
	bin_to_7seg day0_dis (.w_bcd(day0), .w_seg7(day_7seg0));
	bin_to_7seg month1_dis (.w_bcd(month1), .w_seg7(month_7seg1));
	bin_to_7seg month0_dis (.w_bcd(month0), .w_seg7(month_7seg0));
	bin_to_7seg year3_dis (.w_bcd(year3), .w_seg7(year_7seg3));
	bin_to_7seg year2_dis (.w_bcd(year2), .w_seg7(year_7seg2));
	bin_to_7seg year1_dis (.w_bcd(year1), .w_seg7(year_7seg1));
	bin_to_7seg year0_dis (.w_bcd(year0), .w_seg7(year_7seg0));
	bin_to_7seg sec1_dis (.w_bcd(sec1), .w_seg7(sec_7seg1));
	bin_to_7seg sec0_dis (.w_bcd(sec0), .w_seg7(sec_7seg0));
	bin_to_7seg min1_dis (.w_bcd(min1), .w_seg7(min_7seg1));
	bin_to_7seg min0_dis (.w_bcd(min0), .w_seg7(min_7seg0));
	bin_to_7seg hr1_dis (.w_bcd(hr1), .w_seg7(hour_7seg1));
	bin_to_7seg hr0_dis (.w_bcd(hr0), .w_seg7(hour_7seg0));

	always @(mode)
	begin
		if (mode==1)// date display
		begin
			seg7 <= day_1;
			seg6 <= day_0;
			seg5 <= month_1;
			seg4 <= month_0;
			seg3 <= year_3;
			seg2 <= year_2;
			seg1 <= year_1;
			seg0 <= year_0;
		end
		else		// time display
		begin 
			seg7 <= hour_7seg1;
			seg6 <= hour_7seg0;
			seg5 <= min_7seg1;
			seg4 <= min_7seg0;
			seg3 <= sec_7seg1;
			seg2 <= sec_7seg0;
			seg1 <= 7'b1111111;	// turn off unused led
			seg0 <= 7'b1111111; // turn off unused led
		end
	end
*/