module chia_tanso (
    input wire clk_50MHz,
    output reg clk_1Hz
);

reg [25:0] counter; // 26-bit counter, for 50MHz to 1Hz
reg [3:0] digit; // 4-bit counter, count from 0 to 9

always @(posedge clk_50MHz) begin
    if (counter == 50000000 - 1) begin // dem tu 0 nen phai tru 1
        counter <= 0;
        if (digit == 9) begin
            digit <= 0; // Reset khi dem den 9
            clk_1Hz <= ~clk_1Hz; // Flip bit 
        end else begin
            digit <= digit + 1; // Tang so dem
        end
    end else begin
        counter <= counter + 1;
    end
end

endmodule