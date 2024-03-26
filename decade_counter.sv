module decade_counter(
	input rst_n,
	input mode,
	input clk,
	output logic [5:0] sec_7seggs,
	output logic [5:0] min_7seggs,
	output logic [4:0] hour_7seggs,
	output logic [4:0] day_7seggs,
	output logic [3:0] month_7seggs,
	output logic [13:0] year_7seggs
);

	always @(posedge clk or negedge rst_n)
	begin
		if (~rst_n)
		begin //reset to 00:00:00, 01/01/2024
			sec_7seggs <= 0;
			min_7seggs <= 0;
			hour_7seggs <= 0;
			day_7seggs <= 0;
			month_7seggs <= 0;
			year_7seggs <= 0;
		end
		else
		begin
		end
	end
	
endmodule