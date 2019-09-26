include Makefile.inc

test:
	iverilog $(INCLUDE_DIRS) -DSHIFT_REG_SIMULATE shift_reg.v -o tb/shift_reg_tb
	./tb/shift_reg_tb
	gtkwave tb/shift_reg_tb.vcd

resources:
	vivado -nolog -nojournal -mode batch -source vivado_resources.tcl

.PHONY: test resources
