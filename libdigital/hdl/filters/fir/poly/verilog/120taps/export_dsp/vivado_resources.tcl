add_files fir_poly_2channel.v
synth_design -top fir_poly_2channel -part xc7a15tftg256-1
report_utilization
report_timing
