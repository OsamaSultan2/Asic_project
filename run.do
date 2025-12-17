vlib work 
vlog watch_fsm.v FSM_tb.v  +cover -covercells
vsim -voptargs=+acc tb    -cover
coverage save  FSM.ucdb -onexit -du work.watch_fsm
do wave.do
run -all
coverage exclude -src watch_fsm.v -line 81 -code s
coverage exclude -src watch_fsm.v -line 82 -code s
coverage exclude -src watch_fsm.v -line 83 -code s
coverage exclude -src watch_fsm.v -line 84 -code s
coverage exclude -src watch_fsm.v -line 85 -code s
coverage exclude -src watch_fsm.v -line 86 -code s
coverage exclude -src watch_fsm.v -line 87 -code s
coverage exclude -src watch_fsm.v -line 80 -code b
coverage exclude -src watch_fsm.v -line 137 -code b
coverage exclude -src watch_fsm.v -line 100 -code b
 