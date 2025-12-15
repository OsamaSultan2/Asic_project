vlib work
vlog clock_comp.v clock.v watch_fsm.v top.v tb.v +cover -covercells
vsim -voptargs=+acc work.tb -cover
add wave *
#do wave.do
run -all
