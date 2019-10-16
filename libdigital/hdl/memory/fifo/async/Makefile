LOCAL_DIRS   := -I$(HDL_ROOT)/memory/ram/
INCLUDE_DIRS := $(LOCAL_DIRS)
ICARUS_DIR   := tb

# Test
verilator:
	verilator -sv -trace -Wall $(INCLUDE_DIRS) --cc async_fifo.v --exe async_fifo.cc
	$(MAKE) -j$(shell nproc) -C obj_dir -f Vasync_fifo.mk Vasync_fifo
	./obj_dir/Vasync_fifo

icarus:
	iverilog $(INCLUDE_DIRS) -DASYNC_FIFO_SIMULATE async_fifo.v -o $(ICARUS_DIR)/async_fifo_tb
	./$(ICARUS_DIR)/async_fifo_tb
	gtkwave $(ICARUS_DIR)/async_fifo_tb.vcd

# Synthesis
synth: synth.ilang

synth.ilang: synth.ys async_fifo.v
	yosys synth.ys

xilinx: synth xilinx.ys
	yosys xilinx.ys

# Misc
clean:
	rm *.ilang
	rm -rf obj_dir

.PHONY: synth xilinx clean
