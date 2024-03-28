module decade_counter(
	input 	rst_n,
	input 	sw_mode,
	input 	clk,
	input 	butt_increase,
	input 	butt_decrease,
	input 	butt_change,
	output logic [6:0] seg0,
	output logic [6:0] seg1,
	output logic [6:0] seg2,
	output logic [6:0] seg3,
	output logic [6:0] seg4,
	output logic [6:0] seg5,
	output logic [6:0] seg6,
	output logic [6:0] seg7);
	
	/*************  CLOCK CONTROL  ****************/
	reg tick_1s;
	delay #(26'd49_999_999,26) delay1s (.delay(tick_1s), .reset_n(rst_n), .CLOCK_50MHZ(clk));
	

	/*************  SINGLE DIGITS  ****************/
	reg [3:0] sec1; 
	reg [3:0] sec0;

	reg [3:0] min1;
	reg [3:0] min0;
	
	reg [3:0] hour1;
	reg [3:0] hour0;
	
	reg [3:0] day1;
	reg [3:0] day0;
	
	reg [3:0] month1;
	reg [3:0] month0;
	
	reg [3:0] year3;
	reg [3:0] year2;
	reg [3:0] year1;
	reg [3:0] year0;


	/*************  DISPLAY TO 7SEG  ***************/
	logic [7:0][6:0] calendar_dis;
	logic [7:0][6:0] clock_dis;

	logic [7:0][3:0] calendar_bin;
	logic [7:0][3:0] clock_bin;
	assign calendar_bin = {day1, day0, month1, month0, year3, year2, year1, year0};
	assign clock_bin 	= {hour1, hour0, min1, min0, sec1, sec0, 4'b1110, 4'b1110};
	
	bin_to_7seg day1_dis 	(.w_bcd(calendar_bin[7]), .w_seg7(calendar_dis[7]));
	bin_to_7seg day0_dis 	(.w_bcd(calendar_bin[6]), .w_seg7(calendar_dis[6]));
	bin_to_7seg month1_dis 	(.w_bcd(calendar_bin[5]), .w_seg7(calendar_dis[5]));
	bin_to_7seg month0_dis 	(.w_bcd(calendar_bin[4]), .w_seg7(calendar_dis[4]));
	bin_to_7seg year3_dis 	(.w_bcd(calendar_bin[3]), .w_seg7(calendar_dis[3]));
	bin_to_7seg year2_dis 	(.w_bcd(calendar_bin[2]), .w_seg7(calendar_dis[2]));
	bin_to_7seg year1_dis 	(.w_bcd(calendar_bin[1]), .w_seg7(calendar_dis[1]));
	bin_to_7seg year0_dis 	(.w_bcd(calendar_bin[0]), .w_seg7(calendar_dis[0]));
	
	bin_to_7seg hour1_dis 	(.w_bcd(clock_bin[7]), .w_seg7(clock_dis[7]));
	bin_to_7seg hour0_dis 	(.w_bcd(clock_bin[6]), .w_seg7(clock_dis[6]));
	bin_to_7seg min1_dis 	(.w_bcd(clock_bin[5]), .w_seg7(clock_dis[5]));
	bin_to_7seg min0_dis 	(.w_bcd(clock_bin[4]), .w_seg7(clock_dis[4]));
	bin_to_7seg sec1_dis 	(.w_bcd(clock_bin[3]), .w_seg7(clock_dis[3]));
	bin_to_7seg sec0_dis 	(.w_bcd(clock_bin[2]), .w_seg7(clock_dis[2]));
	bin_to_7seg blk1_dis 	(.w_bcd(clock_bin[1]), .w_seg7(clock_dis[1]));
	bin_to_7seg blk0_dis 	(.w_bcd(clock_bin[0]), .w_seg7(clock_dis[0]));

	always @(posedge clk or negedge rst_n)
	begin
		if (sw_mode) 
		begin
			seg7 = calendar_dis[7];
			seg6 = calendar_dis[6];
			seg5 = calendar_dis[5];
			seg4 = calendar_dis[4];
			seg3 = calendar_dis[3];
			seg2 = calendar_dis[2];
			seg1 = calendar_dis[1];
			seg0 = calendar_dis[0];
		end
		else 
		begin
			seg7 = clock_dis[7];
			seg6 = clock_dis[6];
			seg5 = clock_dis[5];
			seg4 = clock_dis[4];
			seg3 = clock_dis[3];
			seg2 = clock_dis[2];
			seg1 = clock_dis[1];
			seg0 = clock_dis[0];
		end
	end


	/**************  DIGITAL CLOCK'S LOGIC  ****************/
	reg dayChange;
	assign dayChange = ((hour1 & 4'd2) 	&& 	(hour0 & 4'd3) 	&&
						(min1 & 4'd5) 	&& 	(min0 & 4'd9)	&&
						(sec1 & 4'd5) 	&& 	(sec0 & 4'd9));
	always @(posedge clk or negedge rst_n)
	begin
		if (~rst_n)
		begin
			// 00:00:00xx
			hour1 	<= 4'b0000;	// 0
			hour0 	<= 4'b0000;	// 0
			min1 	<= 4'b0000;	// 0
			min0 	<= 4'b0000;	// 0
			sec1 	<= 4'b0000; // 0
			sec0 	<= 4'b0000;	// 0
			// 01:01:2024
			day1 	<= 4'b0000;	// 0
			day0 	<= 4'b0001;	// 1
			month1 	<= 4'b0000;	// 0
			month0 	<= 4'b0001;	// 1
			year3 	<= 4'b0010;	// 2
			year2 	<= 4'b0000;	// 0
			year1 	<= 4'b0010;	// 2
			year0 	<= 4'b0100;	// 4
		end
		else
		begin
			// TIME BLOCK
			if (tick_1s)
			begin
				// Check TIME'S double digits value first!
				if ((hour1 & 4'd2) 	&& 	(hour0 & 4'd3) 	&&
					(min1 & 4'd5) 	&& 	(min0 & 4'd9)	&&
					(sec1 & 4'd5) 	&& 	(sec0 & 4'd9)) 
				begin
					// Increasement of day0
					day0 	<= day0 + 4'd1;
					
					hour1 	<= 4'd0;
					hour0 	<= 4'd0;
					min1 	<= 4'd0;
					min0 	<= 4'd0;
					sec1 	<= 4'd0;
					sec0 	<= 4'd0;
				end
				else if ((min1 & 4'd5) && (min0 & 4'd9) && 
						 (sec1 & 4'd5) && (sec0 & 4'd9)	&&
						 (hour0 & 4'd9))
				begin
				 	// Increasement of hour1
					hour1 	<= hour1 + 4'd1;
					hour0 	<= 4'd0;

					min1 	<= 4'd0;
					min0 	<= 4'd0;
					sec1 	<= 4'd0;
					sec0 	<= 4'd0;
				end 
				else if ((min1 & 4'd5) && (min0 & 4'd9) && 
						 (sec1 & 4'd5) && (sec0 & 4'd9)) 
				begin
					// Increasement of hour0
					hour0 	<= hour0 + 4'd1;

					min1 	<= 4'd0;
					min0 	<= 4'd0;
					sec1 	<= 4'd0;
					sec0 	<= 4'd0;
				end
				else if ((sec1 & 4'd5) && (sec0 & 4'd9) && 
						 (min0 & 4'd9)) 
				begin
					// Increasement of min1
					min1 	<= min1 + 4'd1;
					min0 	<= 4'd0;

					sec1 	<= 4'd0;
					sec0 	<= 4'd0;
				end
				else if ((sec1 & 4'd5) && (sec0 & 4'd9)) 
				begin
					// Increasement of min0
					min0 	<= min0 + 4'd1;

					sec1 	<= 4'd0;
					sec0 	<= 4'd0;
				end
				else if ((sec0 & 4'd9)) 
				begin
					// Increasement of sec1
					sec1 	<= sec1 + 4'd1;

					sec0 	<= 4'd0;
				end
				else 
				begin
					// Increasement of sec0
					sec0 	<= sec0 + 6'd1;
				end
			end

			// DATE BLOCK
			if ( (dayChange & 1'b1) && ({year2, year1, year0} & 12'b1001_1001_1001) // ~999
									&& ({month1, month0} 	& 8'b0001_0010)			// December
									&& ({day1, day0} 		& 8'b0011_0001))		// 31st
			begin
				// Increasemetn of year3
				if (year3 & 4'd9)	// Incase 9999 appear
				begin
					year3 <= 0;
				end
				else
				begin
					year3 	<= year3 + 4'd1;
				end
				year2 	<= 4'd0;
				year1 	<= 4'd0;
				year0 	<= 4'd0;
				// 01:01:xxxx
				day1	<= 4'd00;
				day0 	<= 4'd01;
				month1	<= 4'd00;
				month0	<= 4'd01;
			end
			else if ( (dayChange & 1'b1) && ({year1, year0} 	& 8'b1001_1001) 	// ~~99
										 && ({month1, month0} 	& 8'b0001_0010)		// December
										 && ({day1, day0} 		& 8'b0011_0001))	// 31st
			begin
				// Increasemetn of year2
				year0 	<= year0 + 4'd1;
				
				day1	<= 4'd00;
				day0 	<= 4'd01;
				month1	<= 4'd00;
				month0	<= 4'd01;
			end
			else if ( (dayChange & 1'b1) && ({month1, month0} 	& 8'd18)	// December
										 && ({day1, day0} 		& 8'd49))	// 31st
			begin
				// Increasemetn of year0
				year0 	<= year0 + 4'd1;
				
				day1	<= 4'd00;
				day0 	<= 4'd01;
				month1	<= 4'd00;
				month0	<= 4'd01;
			end
			else if ((dayChange == 1) && (	month_bin == 4'd1 || month_bin == 4'd3 || 
											month_bin == 4'd5 || month_bin == 4'd7 ||
										 	month_bin == 4'd8 || month_bin == 4'd10 ))
			begin
				if (day_bin == 5'd31) 
				begin 
					day_bin 	<= 5'd1; 
					month_bin 	<= month_bin + 1;
				end
			end
			else if ((dayChange == 1) && ( 	month_bin == 4'd4 || month_bin == 4'd6 || 
											month_bin == 4'd9 || month_bin == 4'd11 ))
			begin
				if (day_bin == 5'd30) 
				begin
					day_bin 	<= 5'd1;  
					month_bin 	<= month_bin + 1;
				end
			end
			else if ((dayChange == 1) && (month_bin == 4'd2))		// FEB
			begin
				if ((year_bin % 14'd4 == 0) && (year_bin % 14'd100 != 0) && (day_bin == 5'd29)) 
				begin 
					day_bin 	<= 5'd1;  
					month_bin 	<= month_bin + 1;
				end
				else if (day_bin == 5'd28) 
				begin 
					day_bin 	<= 5'd1;  
					month_bin 	<= month_bin + 1;
				end
			end

		end
	end

endmodule


/*****************************************************************************************
								7 SEGMENT DECODER
*****************************************************************************************/
module bin_to_7seg(	
	input [3:0] bcd,
	output logic [6:0] seg7
);
	// seven segggggment display
	always @(bcd)
	begin
		case(bcd)
			4'd0: seg7 <= ~7'b0111111;
			4'd1: seg7 <= ~7'b0000110;   
			4'd2: seg7 <= ~7'b1011011;   
			4'd3: seg7 <= ~7'b1001111;    
			4'd4: seg7 <= ~7'b1100110; 
			4'd5: seg7 <= ~7'b1101101;  
			4'd6: seg7 <= ~7'b1111101;    
			4'd7: seg7 <= ~7'b0000111;   
			4'd8: seg7 <= ~7'b1111111; 
			4'd9: seg7 <= ~7'b1101111;  
			default : seg7 <= 7'b0000000;
		endcase
	end

endmodule : bin_to_7seg


/*****************************************************************************************
									DELAY
*****************************************************************************************/
module delay #(parameter COUNT  = 26'd49_999_999,
			   parameter COUNTW = 26)
			(delay, reset_n,CLOCK_50MHZ);

	output reg delay;
	input CLOCK_50MHZ;
	input reset_n;
	
	reg [COUNTW - 1 : 0] count;
	
	always @(posedge CLOCK_50MHZ or negedge reset_n)
	begin
		if(~reset_n)
		begin
			count <= 0;
		end
		else if(count == COUNT)
		begin
			count <= 1'd0;
		end
		else
		begin
			count <= count + 1;
		end
	end
	assign delay = count == COUNT;
endmodule : delay
