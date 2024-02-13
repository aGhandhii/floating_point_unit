onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fpu_single_tb/opcode
add wave -noupdate -radix float32 /fpu_single_tb/a
add wave -noupdate -radix float32 /fpu_single_tb/b
add wave -noupdate -radix float32 /fpu_single_tb/out
add wave -noupdate -group Flags /fpu_single_tb/inexact
add wave -noupdate -group Flags /fpu_single_tb/overflow
add wave -noupdate -group Flags /fpu_single_tb/underflow
add wave -noupdate -group Flags /fpu_single_tb/divByZero
add wave -noupdate -group Flags /fpu_single_tb/invalid
add wave -noupdate -group {Special Value Flags} /fpu_single_tb/dut/A_is_zero
add wave -noupdate -group {Special Value Flags} /fpu_single_tb/dut/A_is_infinity
add wave -noupdate -group {Special Value Flags} /fpu_single_tb/dut/A_is_NaN
add wave -noupdate -group {Special Value Flags} /fpu_single_tb/dut/B_is_zero
add wave -noupdate -group {Special Value Flags} /fpu_single_tb/dut/B_is_infinity
add wave -noupdate -group {Special Value Flags} /fpu_single_tb/dut/B_is_NaN
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4 ps} 0}
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
WaveRestoreZoom {0 ps} {32 ps}
