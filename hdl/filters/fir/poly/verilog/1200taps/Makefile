include Makefile.inc

tb: fir_poly.v bank.v dsp.v ram.v
	iverilog $(INCLUDE_DIRS) \
		-DSIMULATE fir_poly.v -o tb/fir_poly_tb
	./tb/fir_poly_tb
	gtkwave tb/fir_poly.vcd

resources:
	vivado -nolog -nojournal -mode batch -source vivado_resources.tcl

.PHONY: resources
