onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group clk/rst /tb/clk
add wave -noupdate -expand -group clk/rst /tb/rst
add wave -noupdate -expand -group inputs -color Magenta /tb/set
add wave -noupdate -expand -group inputs -color Magenta /tb/mode
add wave -noupdate -color Yellow -radix symbolic /tb/state
add wave -noupdate -expand -group outputs -radix binary /tb/en
add wave -noupdate -expand -group outputs -color Cyan -radix binary /tb/en_exp
add wave -noupdate -expand -group outputs -radix binary /tb/sel1
add wave -noupdate -expand -group outputs -color Cyan -radix binary /tb/sel1_exp
add wave -noupdate -expand -group outputs -radix binary /tb/sel2
add wave -noupdate -expand -group outputs -color Cyan -radix binary /tb/sel2_exp
add wave -noupdate -expand -group outputs -radix binary /tb/disp_mode
add wave -noupdate -expand -group outputs -color Cyan -radix binary /tb/disp_mode_exp
add wave -noupdate -expand -group outputs /tb/clock_set
add wave -noupdate -expand -group outputs -color Cyan /tb/clock_set_exp
add wave -noupdate -radix binary /tb/count
add wave -noupdate -radix unsigned /tb/hr_stored
add wave -noupdate -radix unsigned /tb/mm_stored
add wave -noupdate -expand -group clock /tb/hr
add wave -noupdate -expand -group clock /tb/mm
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {200 ms} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
