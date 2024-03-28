module decade_counter(
	input rst_n,
	input sw_mode,
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

	// register storing time and date
	reg [5:0] sec_bin;
	reg [5:0] min_bin;
	reg [4:0] hour_bin;

	reg [4:0] day_bin;
	reg [3:0] month_bin;
	reg [13:0] year_bin;

	reg dayChange;
	assign dayChange = ((hour_bin == 5'd23) && (min_bin == 6'd59) && (sec_bin == 6'd59));
	/***********************************************************
						CLOCK CONTROL
	***********************************************************/
	reg tick_1s;
	delay #(26'd49_999_999,26) delay1s (.delay(tick_1s), .reset_n(rst_n), .CLOCK_50MHZ(clk));
	
	always @(posedge clk or negedge rst_n)
	begin
		/***********************************************************
							CHANGING MODE
		***********************************************************/


		/***********************************************************
							LOGIC AND COMPUTNG
		***********************************************************/
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
			if (tick_1s)
			begin
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
			end

			/********************   DATE BLOCK   ********************/
			

			
			if ((dayChange == 1) && (month_bin == 4'd12) && (day_bin == 5'd31))
			begin
				day_bin		<=	5'd01;
				month_bin	<=	4'd01;
				year_bin	<=	year_bin + 14'd1;
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

	/***********************************************************
							DISPLAYING
	***********************************************************/

	/********************   TIME BLOCK   ********************/
	logic [3:0] hour1, hour0, min1, min0, sec1, sec0;
	logic [5:0][3:0] value_clock;
	logic [5:0][6:0] seg7_clock;
	assign value_clock ={hour1, hour0, min1, min0, sec1, sec0};

	assign hour1 	= hour_bin / 10;
	assign hour0 	= hour_bin - hour1 * 10;

	assign min1 	= min_bin / 10;
	assign min0 	= min_bin - min1 	* 10;
	
	assign sec1 	= sec_bin / 10;
	assign sec0 	= sec_bin - sec1 	* 10;

	genvar i;
	generate
	  for (i = 0; i <= 5; i++) begin : displayTime
		 bin_to_7seg seg_clock (
			.bcd (value_clock[i]),
			.seg7(seg7_clock[i]));
	  end
	endgenerate

	/********************   DATE BLOCK   ********************/
	logic [3:0] day1, day0, month1, month0, year3, year2, year1, year0;
	logic [7:0][3:0] value_calen;
	logic [7:0][6:0] seg7_calen;
	assign value_calen = {day1, day0, month1, month0, year3, year2, year1, year0};

	assign day1 	= day_bin / 10;
	assign day0 	= day_bin - day1 * 10;
	
	assign month1 	= month_bin / 10;
	assign month0 	= month_bin - month1 * 10;
	
	assign year3 	=  year_bin	/ 1000;
	assign year2 	= (year_bin - year3 * 1000) / 100;
	assign year1 	= (year_bin - year3 * 1000 	- year2 * 100) 	/ 10;
	assign year0 	= (year_bin - year3 * 1000 	- year2 * 100 	- year1 * 10);

	genvar j;
	generate
	  for (j = 0; j <= 7; j++) begin : displayDate
		 bin_to_7seg seg_calen (
			.bcd (value_calen[j]),
			.seg7(seg7_calen[j])
			);
	  end
	endgenerate

	

	/***************   OUT TO SEVEN SEGMENT   ***************/
	always_comb begin
		if (sw_mode) 
		begin
			seg7 = seg7_calen[7];
			seg6 = seg7_calen[6];
			seg5 = seg7_calen[5];
			seg4 = seg7_calen[4];
			seg3 = seg7_calen[3];
			seg2 = seg7_calen[2];
			seg1 = seg7_calen[1];
			seg0 = seg7_calen[0];
		end
		else 
		begin
			seg7 = seg7_clock[5];
			seg6 = seg7_clock[4];
			seg5 = seg7_clock[3];
			seg4 = seg7_clock[2];
			seg3 = seg7_clock[1];
			seg2 = seg7_clock[0];
			seg1 <= 7'b1111111;
			seg0 <= 7'b1111111;
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
