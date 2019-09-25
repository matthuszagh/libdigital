include Makefile.inc

tb: fft_r22sdf.v fft_r22sdf_bfi.v fft_r22sdf_bfii.v fft_r22sdf_wm.v
	iverilog $(INCLUDE_DIRS) -DSIMULATE fft_r22sdf.v -o tb/fft_r22sdf_tb
	./tb/fft_r22sdf_tb
	gtkwave tb/fft_r22sdf_tb.vcd

resources:
	vivado -nolog -nojournal -mode batch -source vivado_resources.tcl

.PHONY: tb resources
