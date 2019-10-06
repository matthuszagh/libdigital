test:
	iverilog -DPARITY_SIMULATE parity.v -o tb/parity_tb
	./tb/parity_tb
	gtkwave tb/parity_tb.vcd
