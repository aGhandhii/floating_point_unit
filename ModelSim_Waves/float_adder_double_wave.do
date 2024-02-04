onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix float64 /float_adder_double_tb/a
add wave -noupdate -radix float64 /float_adder_double_tb/b
add wave -noupdate -radix float64 /float_adder_double_tb/out
add wave -noupdate -group Flags /float_adder_double_tb/overflow
add wave -noupdate -group Flags /float_adder_double_tb/underflow
add wave -noupdate -group Flags /float_adder_double_tb/inexact
add wave -noupdate -group Flags /float_adder_double_tb/zero
add wave -noupdate -group Sign /float_adder_double_tb/dut/sign_a
add wave -noupdate -group Sign /float_adder_double_tb/dut/sign_b
add wave -noupdate -group Sign /float_adder_double_tb/dut/sign_out
add wave -noupdate -group Exponent /float_adder_double_tb/dut/exponent_a
add wave -noupdate -group Exponent /float_adder_double_tb/dut/exponent_b
add wave -noupdate -group Exponent /float_adder_double_tb/dut/exponent_out
add wave -noupdate -group Mantissa /float_adder_double_tb/dut/mantissa_a
add wave -noupdate -group Mantissa /float_adder_double_tb/dut/mantissa_b
add wave -noupdate -group Mantissa /float_adder_double_tb/dut/mantissa_out
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
