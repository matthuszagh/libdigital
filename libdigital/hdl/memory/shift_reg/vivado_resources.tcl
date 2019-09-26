read_verilog -sv shift_reg.v
synth_design -top shift_reg -part xc7a15tftg256-1
report_utilization
