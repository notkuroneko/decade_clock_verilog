module clock_divider (
    input wire clk_50MHz,
    input wire reset_n,
    output tick
);

reg [25:0] counter;
always @(posedge clk_50MHz or negedge reset_n) begin
    if (~reset_n) begin
        counter <= 0; // Reset bo dem
    if (counter  == 50000000 - 1) begin // 50MHz -> 1Hz, cong thuc 
        counter <= 0;
    end else begin
        counter <= counter + 1; // cong them 1 moi lan dem
    end
end

assign tick = counter == 500000000 - 1;


endmodule
