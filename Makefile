FFT_DIR		= libdigital/hdl/fft/r22sdf/verilog/single
FIFO_DIR	= libdigital/hdl/memory/fifo/async

.PHONY: test
test: test_fft test_fifo

.PHONY: test_fft
test_fft:
	$(MAKE) -C $(FFT_DIR) test

.PHONY: test_fifo
test_fifo:
	$(MAKE) -C $(FIFO_DIR) test
