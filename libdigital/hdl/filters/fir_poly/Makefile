export
# source files
VERILOG_DIRS	:= $(shell pwd)

VERILOG_INCS	= $(addprefix -I,$(VERILOG_DIRS))
VERILOG_SRCS	:= $(shell find $(VERILOG_DIRS) -maxdepth 1 -name '*.v')
TOP_MODULE	= fir_poly
TOP_MODULE_SRC	:= $(realpath $(TOP_MODULE).v)

SCRIPT_DIR	:= $(realpath scripts)
TEST_DIR	:= $(realpath test)

.PHONY: test
test: test_cocotb

.PHONY: test_cocotb
test_cocotb:
	$(MAKE) -C $(TEST_DIR) cocotb

.PHONY: test_icarus
test_icarus:
	$(MAKE) -C $(TEST_DIR) icarus

.PHONY: resources
resources:
	$(MAKE) -C $(SCRIPT_DIR) synth_vivado

.PHONY: taps
taps:
	$(MAKE) -C $(SCRIPT_DIR) taps

.PHONY: clean
clean::
	$(MAKE) -C $(TEST_DIR) clean
	$(MAKE) -C $(SCRIPT_DIR) clean
