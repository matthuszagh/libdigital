export
YOSYS_DIR	= yosys
TOP_MODULE_DIR	= $(abspath $(dir $(TOP_MODULE_SRC)))
# yosys doesn't like when the top module directory is also specified
# as an include directory.
VERILOG_INCS	:= $(filter-out -I$(TOP_MODULE_DIR),$(VERILOG_INCS))
VERILOG_SRCS    := $(filter-out $(TOP_MODULE_SRC),$(VERILOG_SRCS))

VIVADO_DIR	= vivado
VIVADO_INCS	= $(subst -I,,$(VERILOG_INCS))

.PHONY: synth
synth: synth_xilinx

.PHONY: synth_xilinx
synth_xilinx: $(TOP_MODULE).ilang $(YOSYS_DIR)/xilinx.tcl
	yosys $(YOSYS_DIR)/xilinx.tcl

$(TOP_MODULE).ilang: $(YOSYS_DIR)/synth.tcl $(VERILOG_SRCS)
	yosys $(YOSYS_DIR)/synth.tcl

.PHONY: formal
formal:
	sby -f $(YOSYS_DIR)/formal.sby

.PHONY: coeffs
coeffs:
	python coeff_rom.py

.PHONY: clean
clean::
	rm -f *.ilang
	rm -rf .Xil
