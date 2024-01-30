onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix float32 /float_adder_tb/a
add wave -noupdate -radix float32 /float_adder_tb/b
add wave -noupdate -radix float32 /float_adder_tb/out
add wave -noupdate /float_adder_tb/overflow
add wave -noupdate /float_adder_tb/underflow
add wave -noupdate /float_adder_tb/inexact
add wave -noupdate /float_adder_tb/zero
add wave -noupdate -group Sign /float_adder_tb/dut/sign_a
add wave -noupdate -group Sign /float_adder_tb/dut/sign_b
add wave -noupdate -group Sign /float_adder_tb/dut/sign_out
add wave -noupdate -group Exponent /float_adder_tb/dut/exponent_a
add wave -noupdate -group Exponent /float_adder_tb/dut/exponent_b
add wave -noupdate -group Exponent /float_adder_tb/dut/exponent_out
add wave -noupdate -group Mantissa /float_adder_tb/dut/mantissa_a
add wave -noupdate -group Mantissa /float_adder_tb/dut/mantissa_b
add wave -noupdate -group Mantissa /float_adder_tb/dut/mantissa_out
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/EB_greater
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/E_equal
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/MA_greater
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/MX_greater
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/sameSign
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/m_add_adjust
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/inexact_portions
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/E_shamt
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/mantissa_x
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/mantissa_y
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/leadingZeros
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/leadingZeros_raw
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/E_base
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/E_diff_raw
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/E_m_add
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/exponentShiftIn
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/exponentShiftedBits
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/mantissa_add
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/mantissa_add_shift
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/mantissa_sub
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/mantissa_add_ready
add wave -noupdate -expand -group {Internal Logic} /float_adder_tb/dut/mantissa_sub_ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7800 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 197
configure wave -valuecolwidth 364
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
WaveRestoreZoom {0 ps} {3370 ps}
