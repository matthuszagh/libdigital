include Makefile.inc

test:
	iverilog $(INCLUDE_DIRS) -DMULT_ADD_SIMULATE mult_add.v -o tb/mult_add_tb
	./tb/mult_add_tb
	gtkwave tb/mult_add_tb.vcd

resources:
	vivado -nolog -nojournal -mode batch -source vivado_resources.tcl

.PHONY: test resources
