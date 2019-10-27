read_verilog -sv fft_dual.v
synth_design -top fft_dual \
    -include_dirs ../../../../memory/ram/ \
    -include_dirs ../../../../memory/shift_reg/ \
    -include_dirs ../../../../dsp/multiply_add/ \
    -part xc7a15tftg256-1
report_utilization
report_timing
