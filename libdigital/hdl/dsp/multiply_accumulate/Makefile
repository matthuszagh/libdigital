include Makefile.inc

test:
	iverilog $(INCLUDE_DIRS) -DMULT_ACCUM_SIMULATE mult_accum.v -o tb/mult_accum_tb
	./tb/mult_accum_tb
	gtkwave tb/mult_accum_tb.vcd

resources:
	vivado -nolog -nojournal -mode batch -source vivado_resources.tcl

.PHONY: test resources
