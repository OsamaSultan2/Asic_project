module clock (
  input clk,
        rst,
        state,
        en_sec,
        sel_min,
        sel_hr,
        set,
  output [7:0] mm,
               hh
);
//======= seconds counter =======
wire sec_carry;
wire [7:0] sec;  
seconds_counter seconds (
  .clk       (clk),
  .rst       (rst),
  .en        (en_sec),
  .seconds   (sec),
  .carry_out (sec_carry)
);
//======= minutes counter =======
wire min_carry;
wire min_in;
wire [7:0] min;
assign min_in = sel_min? sec_carry : set;
limited_counter #(60) minutes (
  .clk       (clk),
  .rst       (rst),
  .in        (sec_carry),
  .sel       (sel_min),
  .dout      (min),
  .carry_out (min_carry)
);
//======= hours counter =======
wire hr_carry;
wire hr_in;
wire [7:0] hr;
assign hr_in = sel_hr? min_carry : set;
limited_counter #(24) hours (
  .clk       (clk),
  .rst       (rst),
  .in        (min_carry),
  .sel       (sel_hr),
  .dout      (hr),
  .carry_out (hr_carry)
);
//======= output assignments =======
assign mm = state? min : sec;
assign hh = state? hr  : min;
endmodule