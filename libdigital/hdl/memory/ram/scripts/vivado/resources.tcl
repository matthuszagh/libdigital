read_verilog -sv ../ram.v
synth_design -top ram \
    -part xc7a15tftg256-1
report_utilization
report_timing
