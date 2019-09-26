read_verilog -sv mult_accum.v
synth_design -top mult_accum -part xc7a15tftg256-1
report_utilization
