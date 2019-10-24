yosys -import
# read_verilog -sv $::env(VERILOG_INCS) $::env(TOP_MODULE_SRC)
read_verilog -sv -I/home/matt/src/libdigital/libdigital/hdl/memory/shift_reg \
    -I/home/matt/src/libdigital/libdigital/hdl/memory/ram/single_port \
    -I/home/matt/src/libdigital/libdigital/hdl/dsp/multiply_add \
    $::env(TOP_MODULE_SRC)
hierarchy
procs;;
write_ilang $::env(TOP_MODULE).ilang
