`timescale 1s/100ms
module tb ();
//======== parameters ====================
  parameter NORMAL    = 2'b00;
  parameter SET_TIME   = 2'b01;
  parameter SET_ALARM  = 2'b10;
  parameter STOP_WATCH = 2'b11;
//======== DUT inputs ===================
  reg clk,rst;
  reg mode;
  reg set;
//======== DUT outputs ==================
  wire [7:0] hr,mm;
  wire       en;
  wire       sel1,sel2;
  wire       disp_mode;
  wire       clock_set;
//========= golden model signals ==========
  reg [1:0]  state;
  reg       en_exp;
  reg       sel1_exp,sel2_exp;
  reg       disp_mode_exp;
  reg       clock_set_exp;
  reg [7:0] hr_stored,mm_stored;
  reg       count;
  integer    correct_count=0 , error_count=0;
//======== clock generation ========
initial begin
  clk=0;
  forever begin
    #0.5 clk=~clk;
  end
end
//========   DUT instantiation  =========


// =======   testbench stimulus   ==========
initial begin
// start the simulation with reset
  assert_reset();
//------------ scenario 1: normal operation --------------//
  // time now is at zero we will wait for 5 mins (300 seconds)
  wait_cycles(300);
//------------ scenario 2: set time --------------//
  //we will enter the set time mode and set the time to 12:30
  assert_mode();    // enter set time mode (now we are setting the minutes)
  repeat (30) begin
    assert_set();   // set the minutes to 30
  end
  // going to set the hours now
  assert_mode();    // move to set hours
  repeat (12) begin
    assert_set();   // set the hours to 12
  end
//------------ scenario 3: setting_alarm operation --------------//
  //we will enter the set alarm mode and set the alarm to 14:45
  assert_mode();   // enter set alarm mode (now we are setting the minutes)
  repeat (45) begin
    assert_set();  // set the minutes to 45
  end
  assert_mode();   // move to set hours
  repeat (14) begin
    assert_set();  // set the hours to 14
  end
//------------ scenario 4: stopwatch operation --------------//
  assert_mode();  // enter stopwatch mode
  //we will wait for the 59 mins to check all possible outputs of the clock (3540 seconds)
  wait_cycles(3540);
  // now we will stop the stopwatch
  assert_mode();  // stop the stopwatch
//------------------- end of simulation ------------------//
$display ("======================================= END OF SIMULATION ======================================");
$display ("Total Correct Outputs = %0d", correct_count);
$display ("Total Errors          = %0d", error_count);
end
//==========   tasks   ==================
task golden_model();
  begin
    if (rst) begin
      state = NORMAL;
    end
    //========================== state outputs ============================\\
      case (state)
        //normal operation displays the time so we want the clock to operate normally
        NORMAL: begin
          en_exp        = 1'b1;
          sel1_exp      = 1'b0;
          sel2_exp      = 1'b0;
          disp_mode_exp = 1'b0;
          count         = 1'b0;
          clock_set_exp = 1'b0;
        end
        // we need to stop the clock and begin setting the time
        SET_TIME: begin
          en_exp        = 1'b0;
          disp_mode_exp = 1'b0;
          if (!count) begin
            sel1_exp      = 1'b1;
            sel2_exp      = 1'b0;
            clock_set_exp = set;
          end else begin
            sel1_exp      = 1'b0;
            sel2_exp      = 1'b1;
            clock_set_exp = set;
          end
            
        end
        SET_ALARM: begin   //check the mode condition later depends on the design specs (alarm operation)
          // if (!mode) begin
          en_exp        = 1'b0;
          disp_mode_exp = 1'b0;
            if (!count) begin
              sel1_exp      = 1'b1;
              sel2_exp      = 1'b0;
              clock_set_exp = set;
            end else begin
              sel1_exp      = 1'b0;
              sel2_exp      = 1'b1;
              clock_set_exp = set;
            end
          // end
          // else begin
          //   {hr_stored,mm_stored} = {hr,mm};
          // end
        end
        STOP_WATCH: begin
          count = count + set;
          if (!count) begin
            // stopwatch begin to count
            en_exp    = 1'b1;
            sel1_exp  = 1'b0;
            sel2_exp  = 1'b0;
            // we need to display the minutes and seconds
            disp_mode_exp = 1'b1;
            clock_set_exp = 1'b0;
          end
          else begin
            en_exp    = 1'b0;
            sel1_exp  = 1'b1;
            sel2_exp  = 1'b1;
            // we need to display the minutes and seconds
            disp_mode_exp = 1'b1;
            clock_set_exp = 1'b0;
            // stopwatch stop counting
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
        if (mode && !count) begin
          count = count+1;
        end 
        else if(mode && count)begin
          state = SET_ALARM;
        end
      end
      SET_ALARM: begin
        if (mode && !count) begin
          count = count+1;
        end 
        else if(mode && count)begin
          state = STOP_WATCH;
        end
      end
      STOP_WATCH: begin
        if (mode) begin
          state = NORMAL;
        end
        else begin
          state = STOP_WATCH;
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
  if (en == en_exp && sel1 == sel1_exp && sel2 == sel2_exp && disp_mode == disp_mode_exp)
    correct_count = correct_count +1;
  else begin
    error_count = error_count +1;
    $display("Mismatch detected at time %0t:",$time);
    $display("DUT outputs: en=%b, sel1=%b, sel2=%b, disp_mode=%b,",en,sel1,sel2,disp_mode);
    $display("Expected outputs: en=%b, sel1=%b, sel2=%b, disp_mode=%b,",en_exp,sel1_exp,sel2_exp,disp_mode_exp);
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