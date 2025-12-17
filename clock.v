module clock (
  input clk,
        rst,
        en_sec,
        sel_min,
        sel_hr,
        [7:0] set_min,
        [7:0] set_hr,

  output [3:0] hh_t_out, hh_u_out, mm_t_out, mm_u_out, ss_t_out, ss_u_out
);
//======= seconds counter =======
wire [7:0] sec_carry;
wire [3:0] sec_t;  
wire [3:0] sec_u;  
seconds_counter seconds (
  .clk       (clk),
  .rst       (rst),
  .en        (en_sec),
  .sec_t     (sec_t),
  .sec_u     (sec_u),
  .carry_out (sec_carry)
);
//======= minutes counter =======
wire [7:0] min_carry;
wire [7:0] min_in;
wire [3:0] mm_t;
wire [3:0] mm_u;
assign min_in = sel_min? sec_carry : set_min;
limited_counter #(60) minutes (
  .clk       (clk),
  .rst       (rst),
  .in        (min_in),
  .sel       (sel_min),
  .mm_t      (mm_t),
  .mm_u      (mm_u),
  .carry_out (min_carry)
);
//======= hours counter =======
wire [7:0] hr_carry;
wire [7:0] hr_in;
wire [3:0] hr_t;
wire [3:0] hr_u;
assign hr_in = sel_hr? min_carry : set_hr;
limited_counter #(24) hours (
  .clk       (clk),
  .rst       (rst),
  .in        (hr_in),
  .sel       (sel_hr),
  .mm_t      (hr_t),
  .mm_u      (hr_u),
  .carry_out (hr_carry)
);
//======= output assignments =======
assign ss_t_out = sec_t;
assign ss_u_out = sec_u;
assign mm_t_out = mm_t;
assign mm_u_out = mm_u;
assign hh_t_out = hr_t;
assign hh_u_out = hr_u;
endmodule

