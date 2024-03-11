# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.

vlog "*.sv"
vlog "*.svh"
vlog "./Count_Leading_Zeros/*.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work fpu_single_tb

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do ./ModelSim_Waves/fpu_single_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
