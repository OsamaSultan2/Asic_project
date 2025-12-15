`timescale 1s/100ms
module tb ();
//======== parameters ====================
  parameter NORMAL     = 2'b00;
  parameter SET_TIME   = 2'b01;
  parameter SET_ALARM  = 2'b10;
  parameter STOP_WATCH = 2'b11;
//======== DUT inputs ===================
  reg clk,rst;
  reg mode=0;
  reg set=0;
//======== DUT outputs ==================
  wire        en_sec_normal;
  wire        en_sec_sw;
  wire        save_split;
  wire        sel_hr;
  wire        sel_min;
  wire        sel_hr_sw;
  wire        sel_min_sw;
  wire  [3:0] hh_t, hh_u, mm_t, mm_u;     // time
  wire  [3:0] ah_t, ah_u, am_t, am_u;     // alarm
  wire  [7:0] set_mm, set_hh;
  wire  [1:0] state_out;

//========= golden model signals ==========
  reg [1:0]  state;
  reg        en_sec_normal_exp;
  reg        en_sec_sw_exp;
  reg        save_split_exp;
  reg        sel_hr_exp;
  reg        sel_min_exp;
  reg        sel_hr_sw_exp;
  reg        sel_min_sw_exp;
  reg  [5:0] clock_counter;
  reg  [3:0] hh_t_exp =0, hh_u_exp =0, mm_t_exp =0, mm_u_exp =0;     // time
  reg  [3:0] sws_t_exp =0, sws_u_exp =0, swm_t_exp =0, swm_u_exp =0;     // time
  reg  [3:0] ah_t_exp =0, ah_u_exp =0, am_t_exp =0, am_u_exp =0;     // alarm
  reg  [7:0] set_mm_exp, set_hh_exp;
  reg  [1:0] state_out_exp;
  reg  [1:0]    count=0;
  integer    correct_count=0 , error_count=0;
//======== clock generation ========
initial begin
  clk=0;
  forever begin
    #0.5 clk=~clk;
  end
end
//========   DUT instantiation  =========
watch_fsm DUT (
    .clk(clk),
    .rst(rst),
    .mode_btn(mode),
    .set_btn(set),

    .hh_t(hh_t),
    .hh_u(hh_u),
    .mm_t(mm_t),
    .mm_u(mm_u),

    .ah_t(ah_t),
    .ah_u(ah_u),
    .am_t(am_t),
    .am_u(am_u),

    .en_sec_normal(en_sec_normal),
    .en_sec_sw(en_sec_sw),

    .save_split(save_split),

    .set_mm(set_mm),
    .set_hh(set_hh),

    .sel_hr(sel_hr),
    .sel_min(sel_min),

    .sel_hr_sw(sel_hr_sw),
    .sel_min_sw(sel_min_sw),

    .state_out(state_out)
);

// =======   testbench stimulus   ==========
initial begin
// start the simulation with reset
  assert_reset();
//------------ scenario 1: normal operation --------------//
  // time now is at zero we will wait for 5 mins (300 seconds)
  wait_cycles(300);
//------------ scenario 2: set time --------------// 
// time is 00:05
  //we will enter the set time mode and set the time to 12:30
  assert_mode();    // enter set time mode (now we are setting the minutes)
  assert_set();   // set the hrs_t to 1
  assert_mode();
  repeat(2) begin // set the hrs_u to 2
    assert_set();
  end
  // going to set the minutes now
  assert_mode();    // move to set minutes_t
  repeat (3) begin
    assert_set();   // set the minutes to 30
  end
  assert_mode();    // move to set minutes_u
  repeat (5) begin   // we need to increment 5 to wrap 
    assert_set();   // set the minutes to 0
  end
//------------ scenario 3: setting_alarm operation --------------//
// time is 12:30 , alarm is 00:00
// we need to set the alarm to 06:45
  assert_mode();    // enter set time mode (now we are setting the minutes)
 // set the hrs_t to 0 (aleardy done)
  assert_mode();
  repeat(6) begin // set the hrs_u to 6
    assert_set();
  end
  // going to set the minutes now
  assert_mode();    // move to set minutes_t
  repeat (4) begin
    assert_set();   // set the minutes to 4
  end
  assert_mode();    // move to set minutes_u
  repeat (5) begin   
    assert_set();   // set the minutes to 5
  end
//------------ scenario 4: stopwatch operation --------------//
  assert_mode();  // enter stopwatch mode
  assert_set();   // start the stopwatch
  //we will wait for the 59 mins to check all possible outputs of the clock (3540 seconds)
  wait_cycles(3540);
  // now we will stop the stopwatch
  assert_set();   // split the stopwatch
  wait_cycles(15);
  assert_set();   // stop the stopwatch
  assert_mode();  // return to normal
//------------------- end of simulation ------------------//
$display ("======================================= END OF SIMULATION ======================================");
$display ("Total Correct Outputs = %0d", correct_count);
$display ("Total Errors          = %0d", error_count);
$stop;
end
//==========   tasks   ==================
//---------------- clock model -----------------//
task clock();
  begin
    if (rst) begin
      clock_counter = 0;
      hh_t_exp = 0; hh_u_exp = 0; mm_t_exp = 0; mm_u_exp = 0;
    end
    else begin
      clock_counter = clock_counter + 1;
      if(clock_counter == 60) begin
        mm_u_exp = mm_u_exp + 1;
        clock_counter = 0;
      end
      if(mm_u_exp == 10) begin
        mm_u_exp = 0;
        mm_t_exp = mm_t_exp + 1;
      end
      if(mm_t_exp == 6) begin
        mm_t_exp = 0;
        hh_u_exp = hh_u_exp + 1;
      end
      if(hh_u_exp == 10) begin
        hh_u_exp = 0;
        hh_t_exp = hh_t_exp + 1;
      end
      if(hh_t_exp == 2 && hh_u_exp == 4) begin
        hh_t_exp = 0;
        hh_u_exp = 0;
      end
    end
  end
endtask
//--------------- stopwatch model ----------------//
task stopwatch();
  begin
    if (rst) begin
      sws_t_exp = 0; sws_u_exp = 0;
      swm_t_exp = 0; swm_u_exp = 0;
    end
    else begin
      sws_u_exp = sws_u_exp + 1;
      if(sws_u_exp == 10) begin
        sws_u_exp = 0;
        sws_t_exp = sws_t_exp + 1;
      end
      if(sws_t_exp == 6) begin
        sws_t_exp = 0;
        swm_u_exp = swm_u_exp + 1;
      end
      if(swm_u_exp == 10) begin
        swm_u_exp = 0;
        swm_t_exp = swm_t_exp + 1;
      end
      if(swm_t_exp == 6) begin
        swm_t_exp = 0;
        swm_u_exp = 0;
        swm_t_exp = 0;
      end
    end
  end
endtask
//---------------- golden model -----------------//
task golden_model();
  begin
    if (rst) begin
      state = NORMAL;
    end
    //========================== state outputs ============================\\
      case (state)
        //normal operation displays the time so we want the clock to operate normally
        NORMAL: begin
          en_sec_normal_exp = 1;
          en_sec_sw_exp     = 0;
          save_split_exp    = 0;
          sel_hr_exp        = 1;
          sel_min_exp       = 1;
          sel_hr_sw_exp     = 0;
          sel_min_sw_exp    = 0;
          clock();
        end
        // we need to stop the clock and begin setting the time
        SET_TIME: begin
          en_sec_normal_exp = 0;
          en_sec_sw_exp     = 0;
          sel_min_exp       = 0;
          sel_hr_exp        = 0;
          sel_hr_sw_exp     = 0;
          sel_min_sw_exp    = 0;
          if (count == 0 && set) begin
            hh_t_exp = (hh_t_exp +1) % 3 ;
          end else if (count == 1 && set) begin
            hh_u_exp = (hh_t_exp ==2) ? (hh_u_exp +1)%4 : (hh_u_exp +1)%10 ;
          end else if (count == 2 && set) begin
            mm_t_exp = (mm_t_exp +1)%6 ;
          end else if (count == 3 && set) begin
            mm_u_exp = (mm_u_exp + 1)%10 ;
          end
        end
        SET_ALARM: begin   //check the mode condition later depends on the design specs (alarm operation)
          en_sec_normal_exp = 1;
          en_sec_sw_exp     = 0;
          sel_min_exp       = 1;
          sel_hr_exp        = 1;
          sel_hr_sw_exp     = 0;
          sel_min_sw_exp    = 0;
          clock();
          if (count == 0 && set) begin
            ah_t_exp = (ah_t_exp +1) % 3 ;
          end else if (count == 1 && set) begin
            ah_u_exp = (ah_t_exp ==2) ? (ah_u_exp +1)%4 : (ah_u_exp +1)%10 ;
          end else if (count == 2 && set) begin
            am_t_exp = (am_t_exp +1)%6 ;
          end else if (count == 3 && set) begin
            am_u_exp = (am_u_exp + 1)%10 ;
          end
        end
        STOP_WATCH: begin
          en_sec_normal_exp = 1;
          en_sec_sw_exp     = 1;
          sel_min_exp       = 1;
          sel_hr_exp        = 1;
          clock();
          if (count == 0) begin
            sel_hr_sw_exp     = 0;
            sel_min_sw_exp    = 0;
          end else if (count == 1) begin
            sel_hr_sw_exp     = 1;
            sel_min_sw_exp    = 1;
            stopwatch();
          end else if (count == 2) begin
            sel_hr_sw_exp     = 1;
            sel_min_sw_exp    = 1;
            save_split_exp    = 1;
            stopwatch();
          end
          else if (count == 3) begin
            sel_hr_sw_exp     = 0;
            sel_min_sw_exp    = 0;
            save_split_exp    = 0;
          end
        end
      endcase
    //========================== state transition ============================\\
    case (state)
      NORMAL: begin
        if (mode) begin
          state = SET_TIME;
        end
        else begin
          state = NORMAL;
        end
      end
      SET_TIME: begin
        if (mode && count != 3 ) begin
          count = count+1;
        end 
        else if(mode && count == 3)begin
          state = SET_ALARM;
          count = 0;
        end
      end
      SET_ALARM: begin
        if (mode && count != 3 ) begin
            count = count+1;
        end 
        else if(mode && count == 3)begin
          state = STOP_WATCH;
          count = 0;
        end
      end
      STOP_WATCH: begin
        if (mode) begin
          state = NORMAL;
          count = 0;
        end
        else begin
          state = STOP_WATCH;
        end 
        if (set) begin 
          if (count == 3)
            count = 1;
          else
            count = count + 1;
        end
      end
    endcase
  end
endtask
//---------------- check outputs -----------------//
task check_outputs(); 
  begin
    @(negedge clk);
    golden_model();
    if (en_sec_normal == en_sec_normal_exp &&
        en_sec_sw     == en_sec_sw_exp     &&
        save_split    == save_split_exp    &&
        sel_hr        == sel_hr_exp        &&
        sel_min       == sel_min_exp       &&
        sel_hr_sw     == sel_hr_sw_exp     &&
        sel_min_sw    == sel_min_sw_exp    )
      correct_count = correct_count +1;
    else begin
      error_count = error_count +1;
      $display("Mismatch detected at time %0t:",$time);
      $display("DUT outputs: en_sec_normal=%b, en_sec_sw=%b, save_split=%b, sel_hr=%b, sel_min=%b, sel_hr_sw=%b, sel_min_sw=%b,",en_sec_normal,en_sec_sw,save_split,sel_hr,sel_min,sel_hr_sw,sel_min_sw);
      $display("Expected outputs: en_sec_normal=%b, en_sec_sw=%b, save_split=%b, sel_hr=%b, sel_min=%b, sel_hr_sw=%b, sel_min_sw=%b,",en_sec_normal_exp,en_sec_sw_exp,save_split_exp,sel_hr_exp,sel_min_exp,sel_hr_sw_exp,sel_min_sw_exp);
    end
  end
endtask
//---------------- signal asseration -----------------//
task assert_reset();
begin
  rst = 1;
  check_outputs();
  rst = 0;
end
endtask

task assert_mode(); 
begin
  mode = 1;
  check_outputs();
  mode = 0;
end
endtask

task assert_set();
begin
  set = 1;
  check_outputs();
  set = 0;
end
endtask
//=================================================//
//---------------- wait cycles -----------------//
task wait_cycles(input integer num_cycles);
begin :wait_loop
  integer i;
  for (i = 0; i < num_cycles; i = i + 1) begin
    check_outputs();
  end
end
endtask
endmodule