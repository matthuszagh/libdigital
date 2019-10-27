yosys -import
read_ilang $::env(TOP_MODULE).ilang
synth_xilinx -top $::env(TOP_MODULE)
