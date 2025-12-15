onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group clk/rst -color Yellow /tb/clk
add wave -noupdate -expand -group clk/rst -color Yellow /tb/rst
add wave -noupdate -expand -group inputs /tb/mode
add wave -noupdate -expand -group inputs /tb/set
add wave -noupdate /tb/count
add wave -noupdate /tb/state
add wave -noupdate -expand -group outputs /tb/en_sec_normal
add wave -noupdate -expand -group outputs -color Cyan /tb/en_sec_normal_exp
add wave -noupdate -expand -group outputs /tb/en_sec_sw
add wave -noupdate -expand -group outputs -color Cyan /tb/en_sec_sw_exp
add wave -noupdate -expand -group outputs /tb/save_split
add wave -noupdate -expand -group outputs -color Cyan /tb/save_split_exp
add wave -noupdate -expand -group outputs /tb/sel_hr
add wave -noupdate -expand -group outputs -color Cyan /tb/sel_hr_exp
add wave -noupdate -expand -group outputs /tb/sel_min
add wave -noupdate -expand -group outputs -color Cyan /tb/sel_min_exp
add wave -noupdate -expand -group outputs /tb/sel_hr_sw
add wave -noupdate -expand -group outputs -color Cyan /tb/sel_hr_sw_exp
add wave -noupdate -expand -group outputs /tb/sel_min_sw
add wave -noupdate -expand -group outputs -color Cyan /tb/sel_min_sw_exp
add wave -noupdate -radix unsigned /tb/hh_t
add wave -noupdate -radix unsigned /tb/hh_t_exp
add wave -noupdate -radix unsigned /tb/hh_u
add wave -noupdate -radix unsigned /tb/hh_u_exp
add wave -noupdate -radix unsigned /tb/mm_t
add wave -noupdate -radix unsigned /tb/mm_t_exp
add wave -noupdate -radix unsigned /tb/mm_u
add wave -noupdate -radix unsigned /tb/mm_u_exp
add wave -noupdate -radix unsigned /tb/ah_t
add wave -noupdate -radix unsigned /tb/ah_t_exp
add wave -noupdate -radix unsigned /tb/ah_u
add wave -noupdate -radix unsigned /tb/ah_u_exp
add wave -noupdate -radix unsigned /tb/am_t
add wave -noupdate -radix unsigned /tb/am_t_exp
add wave -noupdate -radix unsigned /tb/am_u
add wave -noupdate -radix unsigned /tb/am_u_exp
add wave -noupdate -radix unsigned /tb/set_mm
add wave -noupdate -radix unsigned /tb/set_hh
add wave -noupdate -radix unsigned /tb/state_out
add wave -noupdate -radix unsigned /tb/clock_counter
add wave -noupdate -radix unsigned /tb/sws_t_exp
add wave -noupdate -radix unsigned /tb/sws_u_exp
add wave -noupdate -radix unsigned /tb/swm_t_exp
add wave -noupdate -radix unsigned /tb/swm_u_exp
add wave -noupdate -radix unsigned /tb/set_mm_exp
add wave -noupdate -radix unsigned /tb/set_hh_exp
add wave -noupdate -radix unsigned /tb/state_out_exp
add wave -noupdate /tb/correct_count
add wave -noupdate /tb/error_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {200 ms} 0}
quietly wave cursor active 1
configure wave -namecolwidth 190
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ms} {1 sec}
