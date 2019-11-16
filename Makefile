export
HDL_ROOT	= $(abspath libdigital/hdl)
FFT_DIR		= $(HDL_ROOT)/fft/r22sdf
FIFO_DIR	= $(HDL_ROOT)/memory/fifo
SHIFT_REG_DIR	= $(HDL_ROOT)/memory/shift_reg
RAM_DIR		= $(HDL_ROOT)/memory/ram
FIR_POLY_DIR	= $(HDL_ROOT)/filters/fir_poly
WINDOW_DIR	= $(HDL_ROOT)/window

# unit tests
.PHONY: test
test: test_fft test_fifo test_fir_poly test_window

.PHONY: test_fft
test_fft:
	$(MAKE) -C $(FFT_DIR) test

.PHONY: test_fifo
test_fifo:
	$(MAKE) -C $(FIFO_DIR) test

.PHONY: test_window
test_window:
	$(MAKE) -C $(WINDOW_DIR) test

# TODO
.PHONY: test_shift_reg
test_shift_reg:
	$(MAKE) -C $(SHIFT_REG_DIR) test

# TODO
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

# synthesis
.PHONY: synth
synth: synth_fft synth_fifo synth_shift_reg synth_ram synth_fir_poly

.PHONY: synth_fft
synth_fft:
	$(MAKE) -C $(FFT_DIR) synth

.PHONY: synth_fifo
synth_fifo:
	$(MAKE) -C $(FIFO_DIR) synth

.PHONY: synth_shift_reg
synth_shift_reg:
	$(MAKE) -C $(SHIFT_REG_DIR) synth

.PHONY: synth_ram
synth_ram:
	$(MAKE) -C $(RAM_DIR) synth

.PHONY: synth_fir_poly
synth_fir_poly:
	$(MAKE) -C $(FIR_POLY_DIR) synth
