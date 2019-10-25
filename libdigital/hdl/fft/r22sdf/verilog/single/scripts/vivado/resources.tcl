read_verilog -sv ../fft_r22sdf.v
synth_design -top fft_r22sdf \
    -include_dirs { /home/matt/src/libdigital/libdigital/hdl/memory/shift_reg/ \
                        /home/matt/src/libdigital/libdigital/hdl/fft/r22sdf/verilog/single/ \
                        /home/matt/src/libdigital/libdigital/hdl/fft/r22sdf/verilog/single/ \
                        /home/matt/src/libdigital/libdigital/hdl/fft/r22sdf/verilog/single/ \
                        /home/matt/src/libdigital/libdigital/hdl/fft/r22sdf/verilog/single/ \
                        /home/matt/src/libdigital/libdigital/hdl/memory/ram/old/single_port/ \
                        /home/matt/src/libdigital/libdigital/hdl/memory/ram/ \
                        /home/matt/src/libdigital/libdigital/hdl/dsp/multiply_add/ } \
    -part xc7a15tftg256-1
report_utilization
report_timing
