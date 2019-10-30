read_verilog -sv ../fir_poly.v
synth_design -top fir_poly \
    -part xc7a15tftg256-1
report_utilization
report_timing
