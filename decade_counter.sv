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
			
		end
	end
	
endmodule