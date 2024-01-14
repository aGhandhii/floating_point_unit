onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix float32 /float_divider_tb/a
add wave -noupdate -radix float32 /float_divider_tb/b
add wave -noupdate -radix float32 /float_divider_tb/out
add wave -noupdate /float_divider_tb/overflow
add wave -noupdate /float_divider_tb/underflow
add wave -noupdate /float_divider_tb/inexact
add wave -noupdate -expand -group Exponent /float_divider_tb/dut/exponent_a
add wave -noupdate -expand -group Exponent /float_divider_tb/dut/exponent_b
add wave -noupdate -expand -group Exponent /float_divider_tb/dut/exponent_out
add wave -noupdate -expand -group Mantissa /float_divider_tb/dut/mantissa_a
add wave -noupdate -expand -group Mantissa /float_divider_tb/dut/mantissa_b
add wave -noupdate -expand -group Mantissa /float_divider_tb/dut/mantissa_out
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
