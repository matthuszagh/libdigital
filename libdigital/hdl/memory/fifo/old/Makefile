LOCAL_DIRS   := -I$(HDL_ROOT)/memory/ram/
INCLUDE_DIRS := $(LOCAL_DIRS)
ICARUS_DIR   := icarus

# Test
verilator_test:
	verilator -sv -trace -Wall $(INCLUDE_DIRS) --cc sync_fifo.v --exe sync_fifo.cc
	$(MAKE) -j$(shell nproc) -C obj_dir -f Vsync_fifo.mk Vsync_fifo
	./obj_dir/Vsync_fifo

icarus_test:
	iverilog $(INCLUDE_DIRS) -DSYNC_FIFO_ICARUS sync_fifo.v -o $(ICARUS_DIR)/sync_fifo_tb
	./$(ICARUS_DIR)/sync_fifo_tb
	gtkwave $(ICARUS_DIR)/sync_fifo_tb.vcd

# Synthesis
synth: synth.ilang

synth.ilang: synth.ys sync_fifo.v
	yosys synth.ys

xilinx: synth xilinx.ys
	yosys xilinx.ys

# Misc
clean:
	rm *.ilang
	rm -rf obj_dir

.PHONY: synth xilinx clean icarus_test verilator_test
