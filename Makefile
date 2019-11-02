export
HDL_ROOT	= $(abspath libdigital/hdl)
FFT_DIR		= $(HDL_ROOT)/fft/r22sdf
FIFO_DIR	= $(HDL_ROOT)/memory/fifo
SHIFT_REG_DIR	= $(HDL_ROOT)/memory/shift_reg
RAM_DIR		= $(HDL_ROOT)/memory/ram
FIR_POLY_DIR	= $(HDL_ROOT)/filters/fir_poly

# unit tests
.PHONY: test
test: test_fft test_fifo test_shift_reg test_ram test_fir_poly

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

.PHONY: test_fir_poly
test_fir_poly:
	$(MAKE) -C $(FIR_POLY_DIR) test

# formal verification
.PHONY: formal
formal: formal_fifo

.PHONY: formal_fifo
formal_fifo:
	$(MAKE) -C $(FIFO_DIR) formal
