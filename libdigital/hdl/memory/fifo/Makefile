export
HDL_ROOT	?= $(abspath ../../../hdl)
# Source files
VERILOG_DIRS	:= $(shell pwd)
VERILOG_DIRS	+= $(HDL_ROOT)/memory/ram

VERILOG_INCS	= $(addprefix -I,$(VERILOG_DIRS))
VERILOG_SRCS	:= $(shell find $(VERILOG_DIRS) -maxdepth 1 -name '*.v')
TOP_MODULE      = async_fifo
TOP_MODULE_SRC	:= $(realpath $(TOP_MODULE).v)

# Synthesis, place and route and formal verification
SCRIPT_DIR	:= $(realpath scripts)

# Testing
TEST_DIR	:= $(realpath test)


.PHONY: test
test: test_cocotb

.PHONY: test_cocotb
test_cocotb:
	$(MAKE) -C $(TEST_DIR) cocotb

.PHONY: test_verilator
test_verilator:
	$(MAKE) -C $(TEST_DIR) verilator

.PHONY: test_icarus
test_icarus:
	$(MAKE) -C $(TEST_DIR) icarus

.PHONY: formal
formal:
	$(MAKE) -C $(SCRIPT_DIR) formal

.PHONY: synth
synth:
	$(MAKE) -C $(SCRIPT_DIR) synth

.PHONY: lint
lint:
	verilator $(VERILOG_INCS) \
		--lint-only \
		--Wall \
		$(TOP_MODULE_SRC)

.PHONY: clean
clean::
	$(MAKE) -C $(TEST_DIR) clean
	$(MAKE) -C $(SCRIPT_DIR) clean
