vlib work 
vlog watch_fsm.v FSM_tb.v
vsim -voptargs=+acc tb
do wave.do
run -all
 