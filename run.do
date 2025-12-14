vlib work 
vlog clock_comp.v clock.v FSM_tb.v
vsim -voptargs=+acc tb
# add wave *
do wave.do
# run -all
 