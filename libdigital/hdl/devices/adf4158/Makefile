test:
	iverilog -DADF4158_SIMULATE adf4158.v -o tb/adf4158_tb
	./tb/adf4158_tb
	gtkwave tb/adf4158_tb.vcd

resources:
	vivado -nolog -nojournal -mode batch -source resources.tcl
