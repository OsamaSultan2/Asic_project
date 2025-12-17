module top (    
    input  wire clk,
    input  wire rst,
    input  wire mode_btn,
    input  wire set_btn,

    output reg  [3:0] hh_t_out, hh_u_out, mm_t_out, mm_u_out,     // time
    output reg  [3:0] mm_t_sw_split, mm_u_sw_split, ss_t_sw_split, ss_u_sw_split
);

wire [7:0] set_min, set_hr;
wire en_sec_normal, en_sec_sw;

wire  [3:0] hh_t, hh_u, mm_t, mm_u;                        // time_fsm
wire  [3:0] hh_t_clk, hh_u_clk, mm_t_clk, mm_u_clk;        // time_normal_clock
wire  [3:0] mm_t_sw, mm_u_sw, ss_t_sw, ss_u_sw;            // time_sw_clock
wire  [3:0] ah_t, ah_u, am_t, am_u;                        // alarm

wire  sel_hr, sel_min;
wire  sel_hr_sw, sel_min_sw;

wire  save_split;

wire [1:0] state;

clock normal_clock(
   .clk      (clk),
   .rst      (rst),
   .en_sec   (en_sec_normal),
   .sel_min  (sel_min),
   .sel_hr   (sel_hr),
   .set_min  (set_min),
   .set_hr   (set_hr),

   .hh_t_out (hh_t_clk), .hh_u_out (hh_u_clk), .mm_t_out (mm_t_clk), .mm_u_out (mm_u_clk)
);

clock sw_clock(
   .clk      (clk),
   .rst      (rst),
   .en_sec   (en_sec_sw),
   .sel_min  (sel_min_sw),
   .sel_hr   (sel_hr_sw),
   .set_min  (8'd0),
   .set_hr   (8'd0),

   .mm_t_out (mm_t_sw), .mm_u_out (mm_u_sw), .ss_t_out (ss_t_sw), .ss_u_out (ss_u_sw)
);

watch_fsm fsm(
   .clk      (clk),
   .rst      (rst),
   .mode_btn (mode_btn),
   .set_btn  (set_btn),

   .hh_t(hh_t), .hh_u(hh_u), .mm_t(mm_t), .mm_u(mm_u),     // time
   .ah_t(ah_t), .ah_u(ah_u), .am_t(am_t), .am_u(am_u),     // alarm

   .en_sec_normal(en_sec_normal), 
   .en_sec_sw(en_sec_sw),
   .save_split(save_split),

   .set_mm(set_min), .set_hh(set_hr),
   .sel_hr(sel_hr), .sel_min(sel_min),
   .sel_hr_sw(sel_hr_sw), .sel_min_sw(sel_min_sw),

   .state_out(state)
);

   always @(*) begin
       if (save_split) begin
           mm_t_sw_split = mm_t_sw;
           mm_u_sw_split = mm_u_sw;
           ss_t_sw_split = ss_t_sw;
           ss_u_sw_split = ss_u_sw;
       end
   end


   always @(*) begin
       case (state)
           2'd0: begin
                hh_t_out = hh_t_clk;
                hh_u_out = hh_u_clk;
                mm_t_out = mm_t_clk;
                mm_u_out = mm_u_clk;
           end
            2'd1: begin
                hh_t_out = hh_t;
                hh_u_out = hh_u;
                mm_t_out = mm_t;
                mm_u_out = mm_u;
            end
            2'd2: begin
                hh_t_out = ah_t;
                hh_u_out = ah_u;
                mm_t_out = am_t;
                mm_u_out = am_u;
            end
            2'd3: begin
                hh_t_out = mm_t_sw;
                hh_u_out = mm_u_sw;
                mm_t_out = ss_t_sw;
                mm_u_out = ss_u_sw;
            end
       endcase
   end


endmodule
