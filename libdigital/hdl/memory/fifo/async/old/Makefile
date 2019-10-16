include Makefile.inc

test:
	iverilog $(INCLUDE_DIRS) -DASYNC_FIFO_SIMULATE async_fifo.v -o tb/async_fifo_tb
	./tb/async_fifo_tb
	gtkwave tb/async_fifo_tb.vcd

.PHONY: test
