yosys -import
# read_verilog -sv $::env(VERILOG_INCS) $::env(TOP_MODULE_SRC)
read_verilog -sv -I/home/matt/src/libdigital/libdigital/hdl/memory/shift_reg \
    -I/home/matt/src/libdigital/libdigital/hdl/memory/ram \
    $::env(TOP_MODULE_SRC)
hierarchy
procs;;
write_ilang $::env(TOP_MODULE).ilang
