add_files fft_r22sdf.v
synth_design -top fft_r22sdf -include_dirs ../../ram/ -part xc7a15tftg256-1
report_utilization
report_timing
