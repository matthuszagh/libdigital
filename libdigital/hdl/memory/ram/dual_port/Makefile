include Makefile.inc

test:
	iverilog $(INCLUDE_DIRS) -DRAM_TDP_18K_BASE_SIMULATE ram_tdp_18k.v -o tb/ram_tdp_18k_tb
	./tb/ram_tdp_18k_tb
	gtkwave tb/ram_tdp_18k_tb.vcd

test-ce:
	iverilog $(INCLUDE_DIRS) -DRAM_TDP_18K_CE_SIMULATE ram_tdp_18k.v -o tb/ram_tdp_18k_tb
	./tb/ram_tdp_18k_tb
	gtkwave tb/ram_tdp_18k_tb.vcd

.PHONY: test test-ce
