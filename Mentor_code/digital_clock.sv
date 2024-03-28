module digital_clock (
  input clk,    // Clock
  input reset_n,  // Asynchronous reset active low
  input sw_mode, // Select mode display 1- Calendar, 0 - Clock
  input btn_dec, // Adjust dec
  input btn_inc, // Adjust inc
  input btn_settime, // Request Adjust
  output logic [1:0] set_time, // 2 Led
  output logic [6:0] seg0,
  output logic [6:0] seg1,
  output logic [6:0] seg2,
  output logic [6:0] seg3,
  output logic [6:0] seg4,
  output logic [6:0] seg5,
  output logic [6:0] seg6,
  output logic [6:0] seg7
);
logic [4:0] hour;
logic [5:0] min;
logic [5:0] sec;
logic [4:0] day;
logic [3:0] month;
logic [13:0] year;

//****************************************************************
//                       CLOCK DIVIDER                           
//****************************************************************
// logic [15:0] count;
logic  tick_1s;

// always_ff @(posedge clk or negedge reset_n) begin
//   if(~reset_n) begin
//     count <= 0;
//   end else begin
//     if (count == 16'd49999) begin
//       count <= 0;
//     end
//     else begin
//       count <= count + 1;
//     end
//   end
// end
// assign tick_1s = count == 16'd49999;

delay #(32,32'd49_999_999) dly1s (
  .clk     (clk),
  .reset_n (reset_n),
  .clr    (!db_btn_settime && set_time),
  .en      (1),
  .tick    (tick_1s)
  );

delay #(32,32'd24_999_999) dlybtn1 (
  .clk     (clk),
  .reset_n (reset_n),
  .clr    (0),
  .en      (!btn_dec),
  .tick    (db_btn_dec)
  );
delay #(32,32'd24_999_999) dlybtn2 (
  .clk     (clk),
  .reset_n (reset_n),
  .clr    (0),
  .en      (!btn_inc),
  .tick    (db_btn_inc)
  );
delay #(32,32'd24_999_999) dlybtn3 (
  .clk     (clk),
  .reset_n (reset_n),
  .clr    (0),
  .en      (!btn_settime),
  .tick    (db_btn_settime)
  );

// 2'b00 - No operation
// 2'b01 - Adjust hour/year
// 2'b10 - Adjust min/month
// 2'b11 - Adjust sec/day
always_ff @(posedge clk or negedge reset_n) begin
  if(~reset_n) begin
    set_time <= 0;
  end else if (db_btn_settime) begin
    set_time <= set_time + 1;
  end
end
//****************************************************************
//                       CONTROL CLOCK                            
//****************************************************************
always_ff @(posedge clk or negedge reset_n) begin 
  if(~reset_n) begin
    hour  <= 0;
    min   <= 0;
    sec   <= 0;
  end 
  else if ((!sw_mode) & |set_time) begin
    if (db_btn_inc) begin
      case (set_time)
        2'b01: hour <= (hour == 23) ? 0 : hour + 1;
        2'b10: min <= (min == 59) ? 0 : min + 1;
        2'b11: sec <= (sec == 59) ? 0 : sec + 1;
      endcase
    end
    else if (db_btn_dec) begin
      case (set_time)
        2'b01: hour <= (hour == 0) ? 23 : hour - 1;
        2'b10: min <= (min == 0) ? 59 : min - 1;
        2'b11: sec <= (sec == 0) ? 59 : sec - 1;
      endcase
    end
  end
  else if (tick_1s) begin
    if ((hour == 23) & (min == 59) & (sec == 59)) begin
      hour <= 0;
      min <= 0;
      sec <= 0;
    end
    else if ((min == 59) & (sec == 59)) begin
      hour <= hour + 5'd1;
      min <= 0;
      sec <= 0;
    end
    else if ((sec == 59)) begin
      min <= min + 6'd1;
      sec <= 0;
    end
    else begin
      sec <= sec + 6'd1;
    end
  end
end
//****************************************************************
//                       CONTROL CALENDAR                         
//****************************************************************
always_ff @(posedge clk or negedge reset_n) begin 
  if(~reset_n) begin
    day <= 1;
    month <= 1;
    year <= 14'd2024;
  end 
  else if (sw_mode & |set_time) begin
    if (db_btn_inc) begin
      case (set_time)
        2'b01: year <= (year == 9999) ? 0 : year + 1;
        2'b10: month <= (month == 12) ? 1 : month + 1;
        2'b11: begin 
          if (month == 2 & year %4 != 0) begin
            day <= (day == 28) ? 1 : day + 1;
          end
          else if (month == 2) begin
            day <= (day == 29) ? 1 : day + 1;
          end
          else if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) begin
            day <= (day == 31) ? 1 : day + 1;
          end
          else begin
            day <= (day == 30) ? 1 : day + 1;
          end
        end
      endcase
    end
    else if (db_btn_dec) begin
      case (set_time)
        2'b01: year <= (year == 0000) ? 9999 : year - 1;
        2'b10: month <= (month == 1) ? 12 : month - 1;
        2'b11: begin 
          if (month == 2 & year %4 != 0) begin
            day <= (day == 1) ? 28 : day - 1;
          end
          else if (month == 2) begin
            day <= (day == 1) ? 29 : day - 1;
          end
          else if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) begin
            day <= (day == 1) ? 31 : day - 1;
          end
          else begin
            day <= (day == 1) ? 30 : day - 1;
          end
        end
      endcase
    end
  end
  else if ((hour == 23) & (min == 59) & (sec == 59) & tick_1s) begin
    if (day == 28) begin
      if (month == 2 & year %4 != 0) begin
        month <= month + 1;
        day <= 1;
      end
    end
    else if (day == 29) begin
      if (month == 2 & year %4 == 0) begin
        month <= month + 1;
        day <= 1;
      end
    end
    else if (day == 30) begin
      if (month == 4 || month == 6 || month == 9 || month == 11) begin
        day <= 1;
        month <= month + 1;
      end
    end
    else if (day == 31) begin
      if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) begin
        day <= 1;
        if (month == 12) begin
          month <= 1;
          year <= year + 1;
        end
        else begin
          month <= month + 1;
        end
      end
    end
    else begin
      day <= day + 1;
    end
  end
end

// always_comb begin
//   if (year[15:12] == 9 & year[11:8] == 9 & year[7:4] == 9 & year[3:0] == 9) begin
//     nxt_year = 0;
//   end
//   else if ( year[11:8] == 9 & year[7:4] == 9 & year[3:0] == 9) begin
//     nxt_year = {year[15:12] + 1, 12'd0};
//   end
//   else if (year[7:4] == 9 & year[3:0] == 9) begin
//     nxt_year = {year[15:12], year[11:8] + 1, 8'd0};
//   end
//   else if (year[3:0] == 9) begin
//     nxt_year = {year[15:12], year[11:8], year[7:4] + 1, 4'd0};
//   end
//   else begin
//     nxt_year = {year[15:12], year[11:8], year[7:4], year[3:0] + 1};
//   end
// end

//****************************************************************
//                       DISPLAY SEG7                             
//****************************************************************

logic [3:0] hour1, hour0, min1, min0, sec1, sec0;
logic [5:0][3:0] value_clock;
logic [5:0][6:0] seg7_clock;

assign hour1 = hour/10;
assign hour0 = hour - hour1 * 10;
assign min1 = min/10;
assign min0 = min - min1 * 10;
assign sec1 = sec/10;
assign sec0 = sec - sec1 * 10;
assign  value_clock = {hour1, hour0, min1, min0, sec1, sec0};
genvar i;
generate
  for (i = 0; i <= 5; i++) begin : aaaa1
    display_seg7 seg_clock (
      .bin (value_clock[i]),
      .seg7(seg7_clock[i])
      );
  end
endgenerate

logic [3:0] day1, day0, month1, month0, year3, year2, year1, year0;
logic [7:0][3:0] value_calen;
logic [7:0][6:0] seg7_calen;

assign day1 = day/10;
assign day0 = day - day1 * 10;
assign month1 = month/10;
assign month0 = month - month1 * 10;
assign year3 = year/1000;
assign year2 = (year - year3 * 1000)/100;
assign year1 = (year - year3 * 1000 - year2 * 100)/10;
assign year0 = (year - year3 * 1000- year2 * 100 - year1 * 10);
assign value_calen = {day1, day0, month1, month0, year3, year2, year1, year0};
genvar j;
generate
  for (j = 0; j <= 7; j++) begin : aaaa2
    display_seg7 seg_calen (
      .bin (value_calen[j]),
      .seg7(seg7_calen[j])
      );
  end
endgenerate


logic [6:0] t_seg_calen7 ;
logic [6:0] t_seg_calen6 ;
logic [6:0] t_seg_calen5 ;
logic [6:0] t_seg_calen4 ;
logic [6:0] t_seg_calen3 ;
logic [6:0] t_seg_calen2 ;
logic [6:0] t_seg_calen1 ;
logic [6:0] t_seg_calen0 ;

logic [6:0] t_seg_clock5 ;
logic [6:0] t_seg_clock4 ;
logic [6:0] t_seg_clock3 ;
logic [6:0] t_seg_clock2 ;
logic [6:0] t_seg_clock1 ;
logic [6:0] t_seg_clock0 ;
logic time1s;

always_ff @(posedge clk or negedge reset_n) begin 
  if(~reset_n) begin
    time1s <= 0;
  end else if (tick_1s) begin
    time1s <= ~time1s;
  end
end
assign t_seg_calen7 = (set_time == 2'b11) ? (time1s ? seg7_calen[7] : '1) : seg7_calen[7] ;
assign t_seg_calen6 = (set_time == 2'b11) ? (time1s ? seg7_calen[6] : '1) : seg7_calen[6] ;
assign t_seg_calen5 = (set_time == 2'b10) ? (time1s ? seg7_calen[5] : '1) : seg7_calen[5] ;
assign t_seg_calen4 = (set_time == 2'b10) ? (time1s ? seg7_calen[4] : '1) : seg7_calen[4] ;
assign t_seg_calen3 = (set_time == 2'b01) ? (time1s ? seg7_calen[3] : '1) : seg7_calen[3] ;
assign t_seg_calen2 = (set_time == 2'b01) ? (time1s ? seg7_calen[2] : '1) : seg7_calen[2] ;
assign t_seg_calen1 = (set_time == 2'b01) ? (time1s ? seg7_calen[1] : '1) : seg7_calen[1] ;
assign t_seg_calen0 = (set_time == 2'b01) ? (time1s ? seg7_calen[0] : '1) : seg7_calen[0] ;

assign t_seg_clock5 = (set_time == 2'b01) ? (time1s ? seg7_clock[5] : '1) : seg7_clock[5] ;
assign t_seg_clock4 = (set_time == 2'b01) ? (time1s ? seg7_clock[4] : '1) : seg7_clock[4] ;
assign t_seg_clock3 = (set_time == 2'b10) ? (time1s ? seg7_clock[3] : '1) : seg7_clock[3] ;
assign t_seg_clock2 = (set_time == 2'b10) ? (time1s ? seg7_clock[2] : '1) : seg7_clock[2] ;
assign t_seg_clock1 = (set_time == 2'b11) ? (time1s ? seg7_clock[1] : '1) : seg7_clock[1] ;
assign t_seg_clock0 = (set_time == 2'b11) ? (time1s ? seg7_clock[0] : '1) : seg7_clock[0] ;

always_comb begin
  if (sw_mode) begin
    seg7 = t_seg_calen7 ;
    seg6 = t_seg_calen6 ;
    seg5 = t_seg_calen5 ;
    seg4 = t_seg_calen4 ;
    seg3 = t_seg_calen3 ;
    seg2 = t_seg_calen2 ;
    seg1 = t_seg_calen1 ;
    seg0 = t_seg_calen0 ;
  end
  else begin
    seg7 = t_seg_clock5 ;
    seg6 = t_seg_clock4 ;
    seg5 = t_seg_clock3 ;
    seg4 = t_seg_clock2 ;
    seg3 = t_seg_clock1 ;
    seg2 = t_seg_clock0 ;
    seg1 = 7'b1111111  ;
    seg0 = 7'b1111111  ;
  end
end
//****************************************************************
//                       SEG                                      
//****************************************************************
endmodule : digital_clock

module display_seg7 (
  input [3:0] bin,   
  output logic [6:0] seg7
  
);
// logic [3:0] bcd;
// always_comb begin
//   case (bin)
//     4'd0: bcd = 4'b0000;
//     4'd1: bcd = 4'b0001;
//     4'd2: bcd = 4'b0010;
//     4'd3: bcd = 4'b0011;
//     4'd4: bcd = 4'b0100;
//     4'd5: bcd = 4'b0101;
//     4'd6: bcd = 4'b0110;
//     4'd7: bcd = 4'b0111;
//     4'd8: bcd = 4'b1000;
//     4'd9: bcd = 4'b1001;
//     default : bcd = 4'b0000;
//   endcase
// end

always_comb begin
  case (bin)
    4'b0000: seg7 = 7'b1000000; //0
    4'b0001: seg7 = 7'b1111001; //1
    4'b0010: seg7 = 7'b0100100; //2
    4'b0011: seg7 = 7'b0110000; //3
    4'b0100: seg7 = 7'b0011001; //4
    4'b0101: seg7 = 7'b0010010; //5
    4'b0110: seg7 = 7'b0000010; //6
    4'b0111: seg7 = 7'b1111000; //7
    4'b1000: seg7 = 7'b0000000; //8
    4'b1001: seg7 = 7'b0011000; //9
    default seg7 = 7'b0111111;
  endcase
end

endmodule : display_seg7

module delay #(parameter COUNT_W = 10,
               parameter COUNT = 10)
  (
  input clk,
  input reset_n,
  input en,
  input clr,
  output tick
  );
logic [COUNT_W - 1:0] count;
always_ff @(posedge clk or negedge reset_n) begin 
  if(~reset_n) begin
    count <= 0;
  end 
  else if (clr) begin
    count <= 0;
  end
  else if (en) begin
    count <= count == COUNT ? 0 : count + 1;
  end
  else begin
    count <= 0;
  end
end

assign tick = count == COUNT;
endmodule
