read_verilog -sv mult_add.v
synth_design -top mult_add -part xc7a15tftg256-1
report_utilization
