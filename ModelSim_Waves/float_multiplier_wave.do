onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Single-Precision -radix float32 /float_multiplier_tb/a_sp
add wave -noupdate -expand -group Single-Precision -radix float32 /float_multiplier_tb/b_sp
add wave -noupdate -expand -group Single-Precision -radix float32 /float_multiplier_tb/out_sp
add wave -noupdate -expand -group Single-Precision /float_multiplier_tb/overflow_sp
add wave -noupdate -expand -group Single-Precision /float_multiplier_tb/underflow_sp
add wave -noupdate -expand -group Single-Precision /float_multiplier_tb/inexact_sp
add wave -noupdate -expand -group Double-Precision -radix float64 /float_multiplier_tb/a_dp
add wave -noupdate -expand -group Double-Precision -radix float64 /float_multiplier_tb/b_dp
add wave -noupdate -expand -group Double-Precision -radix float64 /float_multiplier_tb/out_dp
add wave -noupdate -expand -group Double-Precision /float_multiplier_tb/overflow_dp
add wave -noupdate -expand -group Double-Precision /float_multiplier_tb/underflow_dp
add wave -noupdate -expand -group Double-Precision /float_multiplier_tb/inexact_dp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1134 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 50
configure wave -gridperiod 100
configure wave -griddelta 2
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {10500 ps}
