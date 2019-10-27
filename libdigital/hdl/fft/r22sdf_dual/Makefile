include Makefile.inc

test:
	iverilog $(INCLUDE_DIRS) -DFFT_SIMULATE fft_dual.v -o tb/fft_dual_tb
	./tb/fft_dual_tb
	gtkwave tb/fft_dual_tb.vcd

resources:
	vivado -nolog -nojournal -mode batch -source vivado_resources.tcl

.PHONY: test resources
