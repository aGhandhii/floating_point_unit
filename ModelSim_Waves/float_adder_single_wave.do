onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix float32 /float_adder_single_tb/a
add wave -noupdate -radix float32 /float_adder_single_tb/b
add wave -noupdate -radix float32 /float_adder_single_tb/out
add wave -noupdate -group Flags /float_adder_single_tb/overflow
add wave -noupdate -group Flags /float_adder_single_tb/underflow
add wave -noupdate -group Flags /float_adder_single_tb/inexact
add wave -noupdate -group Flags /float_adder_single_tb/zero
add wave -noupdate -group Sign /float_adder_single_tb/dut/sign_a
add wave -noupdate -group Sign /float_adder_single_tb/dut/sign_b
add wave -noupdate -group Sign /float_adder_single_tb/dut/sign_out
add wave -noupdate -group Exponent /float_adder_single_tb/dut/exponent_a
add wave -noupdate -group Exponent /float_adder_single_tb/dut/exponent_b
add wave -noupdate -group Exponent /float_adder_single_tb/dut/exponent_out
add wave -noupdate -group Mantissa /float_adder_single_tb/dut/mantissa_a
add wave -noupdate -group Mantissa /float_adder_single_tb/dut/mantissa_b
add wave -noupdate -group Mantissa /float_adder_single_tb/dut/mantissa_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4725 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 197
configure wave -valuecolwidth 171
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
WaveRestoreZoom {3799 ps} {10743 ps}
