module decade_counter_2(
	input clk,
	input rst_n,
	input mode,
	output logic [6:0] seg7_7,
	output logic [6:0] seg7_6,
	output logic [6:0] seg7_5,
	output logic [6:0] seg7_4,
	output logic [6:0] seg7_3,
	output logic [6:0] seg7_2,
	output logic [6:0] seg7_1,
	output logic [6:0] seg7_0
);
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
	logic [7:0][6:0] calendar_dis;
	logic [7:2][6:0] clock_dis;
	logic [7:0][3:0] calendar_bin;
	logic [7:2][3:0] clock_bin;
	
	bin_to_7seg day1_dis (.w_bcd(calendar_bin[7]), .w_seg7(calendar_dis[7]));
	bin_to_7seg day0_dis (.w_bcd(calendar_bin[6]), .w_seg7(calendar_dis[6]));
	bin_to_7seg month1_dis (.w_bcd(calendar_bin[5]), .w_seg7(calendar_dis[5]));
	bin_to_7seg month0_dis (.w_bcd(calendar_bin[4]), .w_seg7(calendar_dis[4]));
	bin_to_7seg year3_dis (.w_bcd(calendar_bin[3]), .w_seg7(calendar_dis[3]));
	bin_to_7seg year2_dis (.w_bcd(calendar_bin[2]), .w_seg7(calendar_dis[2]));
	bin_to_7seg year1_dis (.w_bcd(calendar_bin[1]), .w_seg7(calendar_dis[1]));
	bin_to_7seg year0_dis (.w_bcd(calendar_bin[0]), .w_seg7(calendar_dis[0]));
	bin_to_7seg sec1_dis (.w_bcd(clock_bin[3]), .w_seg7(clock_dis[3]));
	bin_to_7seg sec0_dis (.w_bcd(clock_bin[2]), .w_seg7(clock_dis[2]));
	bin_to_7seg min1_dis (.w_bcd(clock_bin[5]), .w_seg7(clock_dis[5]));
	bin_to_7seg min0_dis (.w_bcd(clock_bin[4]), .w_seg7(clock_dis[4]));
	bin_to_7seg hour1_dis (.w_bcd(clock_bin[7]), .w_seg7(clock_dis[7]));
	bin_to_7seg hour0_dis (.w_bcd(clock_bin[6]), .w_seg7(clock_dis[6]));
	
	assign calendar_bin[7] = day1;
	assign calendar_bin[6] = day0;
	assign calendar_bin[5] = month1;
	assign calendar_bin[4] = month0;
	assign calendar_bin[3] = year3;
	assign calendar_bin[2] = year2;
	assign calendar_bin[1] = year1;
	assign calendar_bin[0] = year0;
	assign clock_bin[7] = hour1;
	assign clock_bin[6] = hour0;
	assign clock_bin[5] = min1;
	assign clock_bin[4] = min0;
	assign clock_bin[3] = sec1;
	assign clock_bin[2] = sec0;

	always @(posedge clk or negedge rst_n)
	begin
		if (~rst_n)
			begin
				sec1 <= 0; 
				sec0 <= 0;
				min1 <= 0;
				min0 <= 0;
				hour1 <= 0;
				hour0 <= 0;
				day1 <= 0;
				day0 <= 4'd1;
				month1 <= 0;
				month0 <= 4'd1;
				year3 <= 4'd2;
				year2 <= 0;
				year1 <= 4'd2;
				year0 <= 4'd4;
			end
		else
		begin
			//second increment block
			sec0 <= sec0 + 1;
			if (sec0 == 4'd10)
			begin
				sec0 <= 0; sec1 <= sec1 + 1;
			end
			//minute increment block
			if (sec1 == 4'd6)
			begin
				sec1 <= 0; sec0 <= 0; min0 <= min0 + 1;
			end
			if (min0 == 4'd10)
			begin
				min0 <= 0; min1 <= min1 + 1;
			end
			//hour increment block
			if (min1 == 4'd6)
			begin
				min1 <= 0; min0 <= 0; hour0 <= hour0 + 1;
			end
			if (hour0 == 4'd10)
			begin
				hour0 <= 0; hour1 <= hour1 + 1;
			end
			//day increment block
			if (hour1 == 4'd2 && hour0 == 4'd4)
			begin
				hour0 <= 0; hour1 <= 0; day0 <= day0 + 1;
			end
			if (day0 == 4'd10)
			begin
				day0 <= 0; day1 <= day1 + 1;
			end
			//month increment block
			if (	
				{month1, month0} == 8'd1 ||
				{month1, month0} == 8'd3 ||
				{month1, month0} == 8'd5 ||
				{month1, month0} == 8'd7 ||
				{month1, month0} == 8'd8 ||
				{month1, month0} == 8'd16 || //October
				{month1, month0} == 8'd18 //December
			)  
			begin
				if (day1 == 4'd3 && day0 == 4'd1)
				begin
					day1 <= 0; day0 <= 4'd1; month0 <= month0 + 1;
				end
			end
			else 
				if (	
					{month1, month0} == 4'd4 ||
					{month1, month0} == 4'd6 ||
					{month1, month0} == 4'd9 ||
					{month1, month0} == 4'd17 //November
				)
				begin
					if (day1 == 4'd3 && day0 == 0)
					begin
						day1 <= 0; day0 <= 4'd1; month0 <= month0 + 1;
					end
				end
			else 
				if ({month1, month0} == 8'd2)
				begin 
					if ((year0 % 4 == 0 && year1 % 2 == 0) || (year0 % 4 == 2 && year1 % 2 == 1)) //check for leap year
					begin
						if (day1 == 4'd2 && day0 == 4'd9)
						begin
							day1 <= 0; day0 <= 4'd1; month0 <= month0 + 1;
						end
					end
					else 
					begin
						if (day1 == 4'd2 && day0 == 4'd8)
						begin
							day1 <= 0; day0 <= 4'd1; month0 <= month0 + 1;
						end
					end
				end
			
			
			if (month0 == 4'd10)
			begin
				month0 <= 0; month1 <= month1 + 1;
			end
			//year incrememnt block here
			if (month1 == 4'd1 && month0 == 4'd3)
			begin
				month1 <= 0; month1 <= 4'd1; year0 <= year0 + 1;
			end
			if (year0 == 4'd10)
			begin
				year0 <= 0; year1 <= year1 + 1;
			end
			if (year1 == 4'd10)
			begin
				year1 <= 0; year2 <= year2 + 1;
			end
			if (year0 == 4'd10)
			begin
				year2 <= 0; year3 <= year3 + 1;
			end
			if (year0 == 4'd10)
			begin
				year0 <= 0; year1 <= 0; year2 <= 0; year3 <= 0;
			end
		end
	end
	
	always @(mode)
	begin
		if (mode==0) //calendar display
		begin
			seg7_7 = calendar_dis[7];
			seg7_6 = calendar_dis[6];
			seg7_5 = calendar_dis[5];
			seg7_4 = calendar_dis[4];
			seg7_3 = calendar_dis[3];
			seg7_2 = calendar_dis[2];
			seg7_1 = calendar_dis[1];
			seg7_0 = calendar_dis[0];
		end
		else //clock display
		begin
			seg7_7 = clock_dis[7];
			seg7_6 = clock_dis[6];
			seg7_5 = clock_dis[5];
			seg7_4 = clock_dis[4];
			seg7_3 = clock_dis[3];
			seg7_2 = clock_dis[2];
			seg7_1 = 0;
			seg7_0 = 0;
		end
	end
endmodule

module bin_to_7seg (
	input [3:0] w_bcd,
	output logic [6:0] w_seg7
);
	always @(w_bcd) 
	begin
		case (w_bcd)
			4'h0: w_seg7 = ~7'b0111111;
			4'h1: w_seg7 = ~7'b0000110;
			4'h2: w_seg7 = ~7'b1011011;
			4'h3: w_seg7 = ~7'b1001111;
			4'h4: w_seg7 = ~7'b1100110;
			4'h5: w_seg7 = ~7'b1101101;
			4'h6: w_seg7 = ~7'b1111101;
			4'h7: w_seg7 = ~7'b0000111;
			4'h8: w_seg7 = ~7'b1111111;
			4'h9: w_seg7 = ~7'b1101111;
			default: w_seg7 = ~7'b0000000;
		endcase
	end
endmodule
