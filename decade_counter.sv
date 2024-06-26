module decade_counter(
	input 	rst_n,
	input 	sw_mode,			// sw = switch
	input	sw_speed,
	input 	clk,
	input 	butt_increase,		// butt = button (p33 user_man)
	input 	butt_decrease,		// butt press = 0, release = 1
	input 	butt_change,
	output reg	led17,			// led0 and led1 to show the state
	output reg	led14,
	output reg 	led10,
	output logic [6:0] seg0,
	output logic [6:0] seg1,
	output logic [6:0] seg2,
	output logic [6:0] seg3,
	output logic [6:0] seg4,
	output logic [6:0] seg5,
	output logic [6:0] seg6,
	output logic [6:0] seg7);

	
	/*************  CLOCK CONTROL  ****************/
	
	// core clock
	reg tick_1s;
	delay #(26'd49_999_999,26) delay1s (	.delay(tick_1s), 
											.reset_n(rst_n), 
											.CLOCK_50MHZ(clk), 
											.en(1));
	reg tick_0_1s;
	delay #(26'd499,26) delay_half_s (		.delay(tick_0_1s), 
											.reset_n(rst_n), 
											.CLOCK_50MHZ(clk), 
											.en(1));
	wire tick;
	assign tick = (sw_speed) ? tick_0_1s : tick_1s;

	// button clock
	reg tick_change;
	delay #(26'd24_999_999,26) delay_change (	.delay(tick_change), 
												.reset_n(rst_n), 
												.CLOCK_50MHZ(clk), 
												.en(~butt_change));
	reg tick_up;
	delay #(26'd12_499_999,26) delay_tickup (	.delay(tick_up), 
												.reset_n(rst_n), 
												.CLOCK_50MHZ(clk), 
												.en(~butt_increase));
	reg tick_down;
	delay #(26'd12_499_999,26) delay_tickdn (	.delay(tick_down), 
												.reset_n(rst_n), 
												.CLOCK_50MHZ(clk), 
												.en(~butt_decrease));


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
	display_to_7seg st7s (	// Input
							.clk(clk), .sw_mode(sw_mode), 
							.day1(day1), .day0(day0),
							.month1(month1), .month0(month0),
							.year3(year3), .year2(year2), .year1(year1), .year0(year0),
							.hour1(hour1), .hour0(hour0), 
							.min1(min1), .min0(min0),
							.sec1(sec1), .sec0(sec0),
							// Output
							.seg7(seg7),
							.seg6(seg6),
							.seg5(seg5),
							.seg4(seg4),
							.seg3(seg3),
							.seg2(seg2),
							.seg1(seg1),
							.seg0(seg0));


	// button
	reg [1:0] state;
	// assign state = (tick_change) ? ((state == 2'b11) ? 2'b00 : (state + 2'b01)) : (state + 2'b00);
	always @(posedge clk or negedge rst_n)
	begin
		if (!rst_n)
		begin
			state <= 2'd0;
		end
		else if (tick_change)
		begin
			state <= state + 1;
		end
	end

	reg led17_;
	reg led14_;
	reg led10_;
	assign led17 = led17_;
	assign led14 = led14_;
	assign led10 = led10_;

	initial state = 2'b00;



	/**************  DIGITAL CLOCK'S LOGIC  ****************/
	reg dayChange;
	reg monthChange;
	reg yearChange;

	assign yearChange = ((month1 == 4'd2) && (month0 == 4'd1) && (day1 == 4'd1) && (day0 == 4'd3));


	assign dayChange = ((hour1 == 4'd2) 	&& 	(hour0 == 4'd3) 	&&
						(min1 == 4'd5) 	&& 	(min0 == 4'd9)	&&
						(sec1 == 4'd5) 	&& 	(sec0 == 4'd9)	&&
						(tick));
	reg leapYear;
	assign leapYear = ( 
						(
							((year1[0] == 1'b0) && ((year0 == 4'b0000) 	|| 	// year1 even
													(year0 == 4'b0100) 	||		// so y0 is 0, 4, 8
													(year0 == 4'b1000)))||
							((year1[0] == 1'b1) && ((year0 == 4'b0010) 	|| 	// year1 odd
													(year0 == 4'b0110)))		// so y0 is 2, 6
						) && 
						((year1 != 4'b0000) && (year0 != 4'b0000)));	// not divide_able to 100
						
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
			case (state)	// set time
				2'b01 	:	// second
					begin
						if(~sw_mode)
						begin
							if (tick_up)
							begin
								if (sec0 == 4'd9) 
								begin
									sec0 <= 4'd0;
									if (sec1 == 4'd5) 
									begin
										sec1 <= 4'd0;
									end
									else
									begin
										sec1 <= sec1 + 4'd1;
									end
								end
								else
								begin
									sec0 <= sec0 + 4'd1;
								end
							end
							else if (tick_down) 
							begin
								if (sec0 == 4'd0) 
								begin
									sec0 <= 4'd9;
									if(sec1 == 4'd0)
									begin
										sec1 <= 4'd5;
									end
									else
									begin
										sec1 <= sec1 - 4'd1;
									end
								end
								else
								begin
									sec0 <= sec0 - 4'd1;		
								end	
							end
							else
							begin
								sec1 <= sec1 + 4'd0;
								sec0 <= sec0 + 4'd0;	
							end

							// display red led for state
							led17_ <= 1'd0;
							led14_ <= 1'd0;
							led10_ <= 1'd1;
						end
					end
				2'b10 	:	// minute
					begin
						if(~sw_mode)
						begin
							if (tick_up)
							begin
								if (min0 == 4'd9) 
								begin
									min0 <= 4'd0;
									if (min1 == 4'd5) 
									begin
										min1 <= 4'd0;
									end
									else
									begin
										min1 <= min1 + 4'd1;
									end
								end
								else
								begin
									min0 <= min0 + 4'd1;
								end
							end
							else if (tick_down) 
							begin
								if (min0 == 4'd0) 
								begin
									min0 <= 4'd9;
									if(min1 == 4'd0)
									begin
										min1 <= 4'd5;
									end
									else
									begin
										min1 <= min1 - 4'd1;
									end
								end
								else
								begin
									min0 <= min0 - 4'd1;		
								end	
							end
							else
							begin
								min1 <= min1 + 4'd0;
								min0 <= min0 + 4'd0;	
							end

							// display red led for state
							led17_ <= 1'd0;
							led14_ <= 1'd1;
							led10_ <= 1'd0;
						end
					end
				2'b11 	:	// hour
					begin
						if(~sw_mode)
						begin
							if (tick_up)
							begin
								if ((hour0 == 4'd3) && (hour1 == 4'd2)) begin
									hour1 <= 4'd0;
									hour0 <= 4'd0;
								end
								else if (hour0 == 4'd9) 
								begin
									hour1 <= hour1 + 4'd1;
									hour0 <= 4'd0;
								end
								else 
								begin
									hour0 <= hour0 + 4'd1;
								end
							end
							else if (tick_down) 
							begin
								if ((hour0 == 4'd0) && (hour1 == 4'd0)) 
								begin
									hour1 <= 4'd2;
									hour0 <= 4'd3;
								end
								else if (hour0 == 4'd0) 
								begin
									hour1 <= hour1 - 4'd1;
									hour0 <= 4'd9;
								end
								else
								begin
									min0 <= min0 - 4'd1;		
								end	
							end
							else
							begin
								hour1 <= hour1 + 4'd0;
								hour0 <= hour0 + 4'd0;
							end
							// display red led for state
							led17_ <= 1'd1;
							led14_ <= 1'd0;
							led10_ <= 1'd0;
						end
					end
				default : 
					begin
						if (tick)
						begin
							// Check TIME'S double digits value first!
							if ((hour1 == 4'd2) && 	(hour0 == 4'd3) &&
								(min1 == 4'd5) 	&& 	(min0 == 4'd9)	&&
								(sec1 == 4'd5) 	&& 	(sec0 == 4'd9)) 
							begin
								if (day0 == 4'd1001)
								begin
									// Increasement of day1
									day1 <= day1 + 4'd1;
									day0 <= 4'd0;
								end
								else
								begin
									// Increasement of day0
									day0 <= day0 + 4'd1;
								end
								
								hour1 	<= 4'd0;
								hour0 	<= 4'd0;
								min1 	<= 4'd0;
								min0 	<= 4'd0;
								sec1 	<= 4'd0;
								sec0 	<= 4'd0;
							end
							else if ((min1 == 4'd5) && (min0 == 4'd9) && 
									 (sec1 == 4'd5) && (sec0 == 4'd9) &&
									 (hour0 == 4'd9))
							begin
							 	// Increasement of hour1
								hour1 	<= hour1 + 4'd1;
								hour0 	<= 4'd0;

								min1 	<= 4'd0;
								min0 	<= 4'd0;
								sec1 	<= 4'd0;
								sec0 	<= 4'd0;
							end 
							else if ((min1 == 4'd5) && (min0 == 4'd9) && 
									 (sec1 == 4'd5) && (sec0 == 4'd9)) 
							begin
								// Increasement of hour0
								hour0 	<= hour0 + 4'd1;

								min1 	<= 4'd0;
								min0 	<= 4'd0;
								sec1 	<= 4'd0;
								sec0 	<= 4'd0;
							end
							else if ((sec1 == 4'd5) && (sec0 == 4'd9) && 
									 (min0 == 4'd9)) 
							begin
								// Increasement of min1
								min1 	<= min1 + 4'd1;
								min0 	<= 4'd0;

								sec1 	<= 4'd0;
								sec0 	<= 4'd0;
							end
							else if ((sec1 =='b0101) && (sec0 == 4'b1001)) 
							begin
								// Increasement of min0
								min0 	<= min0 + 4'd1;

								sec1 	<= 4'd0;
								sec0 	<= 4'd0;
							end
							else if ((sec0 == 4'b1001)) 
							begin
								// Increasement of sec1
								sec1 	<= sec1 + 4'd1;

								sec0 	<= 4'd0;
							end
							else 
							begin
								// Increasement of sec0
								sec0 	<= sec0 + 4'd1;
							end
						end

						// display red led for state
						led17_ <= 1'd0;
						led14_ <= 1'd0;
						led10_ <= 1'd0;
					end
			endcase

			// DATE BLOCK
			case (state)	// set date
				2'b01 	: 
					begin 	// Year
						if(sw_mode)
						begin
							if ( (yearChange == 1'b1) )
								begin
									if ({year3, year2, year1, year0} == 16'b1001_1001_1001_1001) // 9999
									begin
										year0 <= 4'd0;
										year1 <= 4'd0;
										year2 <= 4'd0;
										year3 <= 4'd0;
									end
									else if ({year2, year1, year0} == 12'b1001_1001_1001) // ~999
									begin
										year3 <= year3 + 4'd1;
										year2 	<= 4'd0;
										year1 	<= 4'd0;
										year0 	<= 4'd0;
									end
									else if ({year1, year0} == 8'b1001_1001) // ~~99
										begin
											year2 <= year2 + 4'd1;
											year1 	<= 4'd0;
											year0 	<= 4'd0;
										end
									else if ({year0} == 4'b1001)	// ~~~9
									begin
										year1 <= year1 + 4'd1;
										year0 <= 4'd0;
									end	
								end
										
								


							// display red led for state
							led17_ <= 1'd1;
							led14_ <= 1'd0;
							led10_ <= 1'd0;
						end
					end
				2'b10 	:
					begin 	// month
						if(sw_mode)
						begin

							/* code */
						
							// display red led for state
							led17_ <= 1'd0;
							led14_ <= 1'd1;
							led10_ <= 1'd0;
						end
					end
				2'b11 	:
					begin 	// day
						if(sw_mode)
						begin

							
							// display red led for state
							led17_ <= 1'd0;
							led14_ <= 1'd0;
							led10_ <= 1'd1;
						end
					end
				default : 
					begin
						if ( (dayChange == 1'b1) && ({year2, year1, year0} 	== 12'b1001_1001_1001) 	// ~999
									 && ({month1, month0} 		== 8'b0001_0010)		// December
									 && ({day1, day0} 			== 8'b0011_0001))		// 31st
						begin
							// Increasemetn of year3
							if (year3 == 4'd9)	// Incase 9999 appear
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
						else if ( (dayChange == 1'b1) && ({year1, year0} 	== 8'b1001_1001) 	// ~~99
													 && ({month1, month0} 	== 8'b0001_0010)		// December
													 && ({day1, day0} 		== 8'b0011_0001))	// 31st
						begin
							// Increasemetn of year2
							year2 	<= year2 + 4'd1;
							year1 	<= 4'd0;
							year0 	<= 4'd0;
							
							day1	<= 4'd00;
							day0 	<= 4'd01;
							month1	<= 4'd00;
							month0	<= 4'd01;
						end
						else if ( (dayChange == 1'b1) && ({year0} 			== 4'b1001) 			// ~~~9
													 && ({month1, month0} 	== 8'b0001_0010)		// December
													 && ({day1, day0} 		== 8'b0011_0001))	// 31st
						begin
							// Increasemetn of year1
							year1 	<= year1 + 4'd1;
							year0 	<= 4'd0;
							
							day1	<= 4'd00;
							day0 	<= 4'd01;
							month1	<= 4'd00;
							month0	<= 4'd01;
						end
						else if ( (dayChange == 1'b1) && ({month1, month0} 	== 8'b00010010)		// December
													 && ({day1, day0} 		== 8'd49))			// 31st
						begin
							// Increasemetn of year0
							year0 	<= year0 + 4'd1;
							
							day1	<= 4'd00;
							day0 	<= 4'd01;
							month1	<= 4'd00;
							month0	<= 4'd01;
						end
						// Month that have 31 days
						else if ((dayChange == 1'b1) && (({month1, month0} 	== 8'b00000001) ||	// Jan
														({month1, month0} 	== 8'b00000011) ||	// Mar
														({month1, month0} 	== 8'b00000101) ||	// May
														({month1, month0} 	== 8'b00000111) ||	// Jul
														({month1, month0} 	== 8'b00001000) ||	// Aug
														({month1, month0} 	== 8'b00010000) ))	// Oct
						begin
							if (({day1, day0} 	== 8'b00110001))	// 31 
							begin 
								// month1 is not need to change here
								month0 	<= month0 + 4'd1;

								day1 	<= 4'd0;
								day0 	<= 4'd1; 
							end
						end
						else if ((dayChange == 1'b1) && (({month1, month0} 	== 8'b00000100) ||	// Apr
														({month1, month0} 	== 8'b00000110) ||	// Jun
														({month1, month0} 	== 8'b00001001) ||	// Sep
														({month1, month0} 	== 8'b00010001) ))	// Nov
						begin
							if (({day1, day0} 	== 8'b00110000))	// 30
							begin
								if (month0 == 4'b1001)	// Sep require process of month1
								begin
									month1 <= 4'd1;		// Resault: Oct
									month0 <= 4'd0;
								end
								else
								begin
									month0 <= month0 + 4'd1;
								end

								day1 	<= 4'd0;
								day0 	<= 4'd1;  
							end
						end
						else if ((dayChange == 1'b1) && 	({month1, month0} 	 ==  8'b00000010))		// Feb
						begin
							if ((leapYear) && ({day1, day0} == 8'b00101001)) // 29th 
							begin 
								month0 <= month0 + 4'd1;

								day1 	<= 4'd0;
								day0 	<= 4'd1;  
							end
							else if ((!leapYear) &&{day1, day0} == 8'b00101000) // 28th
							begin 
								month0 <= month0 + 4'd1;
								
								day1 	<= 4'd0;
								day0 	<= 4'd1;
							end
						end
						// display red led for state
						led17_ <= 1'd0;
						led14_ <= 1'd0;
						led10_ <= 1'd0;
					end
					
			endcase
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
			default : seg7 <= ~7'b0000000;
		endcase
	end

endmodule : bin_to_7seg


/*****************************************************************************************
									DELAY
*****************************************************************************************/
module delay #(parameter COUNT  = 26'd49_999_999,
			   parameter COUNTW = 26)
		(delay, reset_n, CLOCK_50MHZ, en);

	output reg delay;
	input CLOCK_50MHZ;
	input reset_n;	// reset_n active low
	input en; 		// enable clock signal active low
	
	reg [COUNTW - 1 : 0] count;
	always @(posedge CLOCK_50MHZ or negedge reset_n)
	begin
		if(!reset_n)
		begin
			count <= 0;
		end
		else if (count == COUNT)
		begin
			count <= 1'd0;
		end
		else if (en)
		begin
			count <= count + 1;
		end
	end
	assign delay = count == COUNT;
endmodule : delay



/*****************************************************************************************
								DISPLAY TO 7SEG
*****************************************************************************************/
module display_to_7seg (
	input clk,    	// Clock
	input sw_mode,	// Switch mode between date/time
	input day1, day0, month1, month0, year3, year2, year1, year0,
	input hour1, hour0, min1, min0, sec1, sec0,

	output seg7,
	output seg6,
	output seg5,
	output seg4,
	output seg3,
	output seg2,
	output seg1,
	output seg0
);
	logic [7:0][6:0] calendar_dis;
	logic [7:0][6:0] clock_dis;

	logic [7:0][3:0] calendar_bin;
	logic [7:0][3:0] clock_bin;
	assign calendar_bin = {day1, day0, month1, month0, year3, year2, year1, year0};
	assign clock_bin 	= {hour1, hour0, min1, min0, sec1, sec0, 4'b1110, 4'b1110};
	
	bin_to_7seg day1_dis 	(.bcd(calendar_bin[7]), .seg7(calendar_dis[7]));
	bin_to_7seg day0_dis 	(.bcd(calendar_bin[6]), .seg7(calendar_dis[6]));
	bin_to_7seg month1_dis 	(.bcd(calendar_bin[5]), .seg7(calendar_dis[5]));
	bin_to_7seg month0_dis 	(.bcd(calendar_bin[4]), .seg7(calendar_dis[4]));
	bin_to_7seg year3_dis 	(.bcd(calendar_bin[3]), .seg7(calendar_dis[3]));
	bin_to_7seg year2_dis 	(.bcd(calendar_bin[2]), .seg7(calendar_dis[2]));
	bin_to_7seg year1_dis 	(.bcd(calendar_bin[1]), .seg7(calendar_dis[1]));
	bin_to_7seg year0_dis 	(.bcd(calendar_bin[0]), .seg7(calendar_dis[0]));
	
	bin_to_7seg hour1_dis 	(.bcd(clock_bin[7]), .seg7(clock_dis[7]));
	bin_to_7seg hour0_dis 	(.bcd(clock_bin[6]), .seg7(clock_dis[6]));
	bin_to_7seg min1_dis 	(.bcd(clock_bin[5]), .seg7(clock_dis[5]));
	bin_to_7seg min0_dis 	(.bcd(clock_bin[4]), .seg7(clock_dis[4]));
	bin_to_7seg sec1_dis 	(.bcd(clock_bin[3]), .seg7(clock_dis[3]));
	bin_to_7seg sec0_dis 	(.bcd(clock_bin[2]), .seg7(clock_dis[2]));
	bin_to_7seg blk1_dis 	(.bcd(clock_bin[1]), .seg7(clock_dis[1]));
	bin_to_7seg blk0_dis 	(.bcd(clock_bin[0]), .seg7(clock_dis[0]));

	always_comb
	begin
		if (~sw_mode) 
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
		else 
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
	end
endmodule : display_to_7seg