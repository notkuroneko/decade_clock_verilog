module chia_tanso (
    input wire clk_50MHz,
    output reg tick
);

reg [25:0] counter; // 26-bit counter, for 50MHz to 1Hz

always @(posedge clk_50MHz) begin
    if (counter == 50000000 - 1) begin
	counter <= 0;
	if (counter[3:0] == 9) begin
	tick <= 1; 
	end else begin
	tick <= 0;
	end
	end else begin
	counter <= counter + 1; 
	tick <= 0;
	end
end

endmodule
