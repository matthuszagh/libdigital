FFT_DIR		= libdigital/hdl/fft/r22sdf/verilog/single
FIFO_DIR	= libdigital/hdl/memory/fifo/async
SHIFT_REG_DIR	= libdigital/hdl/memory/shift_reg
RAM_DIR		= libdigital/hdl/memory/ram

.PHONY: test
test: test_fft test_fifo test_shift_reg test_ram

.PHONY: test_fft
test_fft:
	$(MAKE) -C $(FFT_DIR) test

.PHONY: test_fifo
test_fifo:
	$(MAKE) -C $(FIFO_DIR) test

.PHONY: test_shift_reg
test_shift_reg:
	$(MAKE) -C $(SHIFT_REG_DIR) test

.PHONY: test_ram
test_ram:
	$(MAKE) -C $(RAM_DIR) test
