yosys -import
read_verilog -sv -I$::env(HDL_ROOT)/memory/ram \
    -I$::env(HDL_ROOT)/memory/fifo/async \
    $::env(HDL_ROOT)/device_interfaces/ft2232h/ft245/ft245.v
hierarchy
procs;;
write_ilang synth.ilang
