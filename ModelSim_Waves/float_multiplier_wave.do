onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix float32 /float_multiplier_tb/a
add wave -noupdate -radix float32 /float_multiplier_tb/b
add wave -noupdate -radix float32 /float_multiplier_tb/out
add wave -noupdate /float_multiplier_tb/overflow
add wave -noupdate /float_multiplier_tb/underflow
add wave -noupdate /float_multiplier_tb/inexact
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {1 ns}
