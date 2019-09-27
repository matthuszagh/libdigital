include Makefile.inc

test:
	iverilog $(INCLUDE_DIRS) -DFFT_SIMULATE fft_r22sdf.v -o tb/fft_r22sdf_tb
	./tb/fft_r22sdf_tb
	gtkwave tb/fft_r22sdf_tb.vcd

resources:
	vivado -nolog -nojournal -mode batch -source vivado_resources.tcl

.PHONY: test resources
