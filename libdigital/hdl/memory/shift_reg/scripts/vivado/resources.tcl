read_verilog -sv ../shift_reg.v
synth_design -top shift_reg \
    -include_dirs ../../ram \
    -part xc7a15tftg256-1
report_utilization
report_timing
