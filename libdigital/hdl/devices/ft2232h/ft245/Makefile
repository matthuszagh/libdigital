export
HDL_ROOT	?= /home/matt/src/libdigital/libdigital/hdl
# source files
VERILOG_DIRS	:= $(shell pwd)
VERILOG_DIRS	+= $(HDL_ROOT)/memory/fifo
VERILOG_DIRS	+= $(HDL_ROOT)/memory/ram

VERILOG_INCS	= $(addprefix -I,$(VERILOG_DIRS))
VERILOG_SRCS	:= $(shell find $(VERILOG_DIRS) -maxdepth 1 -name '*.v')
TOP_MODULE	= ft245
TOP_MODULE_SRC	:= $(realpath $(TOP_MODULE).v)

# Synthesis, place and route and formal verification
SCRIPT_DIR	:= $(realpath scripts)

# Testing
TEST_DIR	:= $(realpath test)


.PHONY: test_cocotb
test_cocotb:
	$(MAKE) -C $(TEST_DIR) sim

# .PHONY: synth
# synth: synth.ilang

# synth.ilang: $(YOSYS_SYNTH_DIR)/synth.tcl ft245.v
# 	$(YOSYS) $(YOSYS_SYNTH_DIR)/synth.tcl

# .PHONY: xilinx
# xilinx: synth $(YOSYS_SYNTH_DIR)/xilinx.tcl
# 	$(YOSYS) $(YOSYS_SYNTH_DIR)/xilinx.tcl

# .PHONY: clean
# clean::
# 	rm -f *.ilang
# 	rm -rf $(VERILATOR_OBJ_DIR)
# 	rm -f *.vcd
