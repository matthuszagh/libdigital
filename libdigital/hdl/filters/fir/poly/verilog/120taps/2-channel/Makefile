include Makefile.inc

tb: fir_poly_2channel.v fir_poly.v bank.v dsp.v ram.v
	iverilog $(INCLUDE_DIRS) -DSIMULATE fir_poly_2channel.v -o tb/fir_poly_2channel_tb
	./tb/fir_poly_2channel_tb
	gtkwave tb/fir_poly_2channel.vcd

resources:
	vivado -nolog -nojournal -mode batch -source vivado_resources.tcl

.PHONY: tb resources
