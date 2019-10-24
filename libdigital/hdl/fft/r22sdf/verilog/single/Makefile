export
# Source files
VERILOG_DIRS	:= $(shell pwd)
VERILOG_DIRS	+= $(HDL_ROOT)/memory/shift_reg
VERILOG_DIRS	+= $(HDL_ROOT)/memory/ram/single_port
VERILOG_DIRS	+= $(HDL_ROOT)/dsp/multiply_add

VERILOG_INCS	= $(addprefix -I,$(VERILOG_DIRS))
VERILOG_SRCS	:= $(shell find $(VERILOG_DIRS) -maxdepth 1 -name '*.v')
TOP_MODULE	= fft_r22sdf
TOP_MODULE_SRC	:= $(realpath $(TOP_MODULE).v)

# Synthesis, place and route and formal verification
SCRIPT_DIR	:= $(realpath scripts)

# Testing
TEST_DIR	:= $(realpath test)

.PHONY: test
test: test_cocotb

# .PHONY: test_cocotb
# test_cocotb:
# 	$(MAKE) -C $(TEST_DIR) cocotb

# test_icarus:
# 	iverilog $(INCLUDE_DIRS) -DFFT_SIMULATE fft_r22sdf.v -o tb/fft_r22sdf_tb
# 	./tb/fft_r22sdf_tb
# 	gtkwave tb/fft_r22sdf_tb.vcd

.PHONY: formal
formal:
	$(MAKE) -C $(SCRIPT_DIR) formal

.PHONY: synth
synth:
	$(MAKE) -C $(SCRIPT_DIR) synth

.PHONY: synth_vivado
synth_vivado:
	$(MAKE) -C $(SCRIPT_DIR) synth_vivado

.PHONY: lint
lint:
	verilator $(VERILOG_INCS) \
		--lint-only \
		--Wall \
		$(TOP_MODULE_SRC)

.PHONY: resources
resources:
	vivado -nolog -nojournal -mode batch -source vivado_resources.tcl
