export
# source files
VERILOG_DIRS	:= $(shell pwd)

VERILOG_INCS	= $(addprefix -I,$(VERILOG_DIRS))
VERILOG_SRCS	:= $(shell find $(VERILOG_DIRS) -maxdepth 1 -name '*.v')
TOP_MODULE	= window
TOP_MODULE_SRC	:= $(realpath $(TOP_MODULE).v)

SCRIPT_DIR	:= $(realpath scripts)
TEST_DIR	:= $(realpath test)

.PHONY: test
test: test_cocotb

.PHONY: test_cocotb
test_cocotb:
	$(MAKE) -C $(TEST_DIR) cocotb

.PHONY: synth
synth:
	$(MAKE) -C $(SCRIPT_DIR) synth

.PHONY: synth_vivado
synth_vivado:
	$(MAKE) -C $(SCRIPT_DIR) synth_vivado

.PHONY: coeffs
coeffs:
	$(MAKE) -C $(SCRIPT_DIR) coeffs

.PHONY: lint
lint:
	verilator $(VERILOG_INCS) \
		--lint-only \
		--Wall \
		--top-module $(TOP_MODULE) \
		$(TOP_MODULE_SRC)

.PHONY: clean
clean::
	$(MAKE) -C $(TEST_DIR) clean
	$(MAKE) -C $(SCRIPT_DIR) clean
