yosys -import
read_verilog -sv $::env(TOP_MODULE_SRC)
hierarchy
procs;;
write_ilang $::env(TOP_MODULE).ilang