include Makefile.inc

test:
	iverilog $(INCLUDE_DIRS) -DRAM_SINGLE_18K_SIMULATE ram_single_18k.v -o tb/ram_single_18k_tb
	./tb/ram_single_18k_tb
	gtkwave tb/ram_single_18k_tb.vcd

.PHONY: test
