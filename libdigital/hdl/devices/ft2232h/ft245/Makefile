LOCAL_DIRS		:= $(HDL_ROOT)/memory/ram \
	                   $(HDL_ROOT)/memory/fifo/async \
	                   $(HDL_ROOT)/memory/fifo/sync

VERILOG_INCLUDE_DIRS	:= $(addprefix -I,$(LOCAL_DIRS))
VERILOG_INCLUDE_DEPS    := $(realpath $(shell find . $(LOCAL_DIRS) -name '*.v'))

SYNTH_DIR		:= synth
YOSYS_SYNTH_DIR		:= $(SYNTH_DIR)/yosys
YOSYS			:= yosys

# Verilator setup
VERILATOR_DIR           := test/verilator
VERILATOR_OBJ_DIR	:= $(VERILATOR_DIR)/build
VERILATOR_SRC_DIR       := $(VERILATOR_DIR)/src
CC_INCLUDE_DIR		:= $(realpath $(HDL_ROOT)/../verilator/include)
CC_INCLUDES		:= $(addprefix -I,$(realpath $(HDL_ROOT)/../verilator/include))
CC_HEADERS		:= $(realpath $(shell find $(CC_INCLUDE_DIR) -name '*.hh'))
DEBUG                   := 0
ifeq ($(DEBUG),1)
VERILATOR_DEBUG_FLAGS   := -CFLAGS "-g3 -O0"
else
VERILATOR_DEBUG_FLAGS   :=
endif
CC_DEPS                 := $(VERILATOR_SRC_DIR)/testbench.cc $(CC_HEADERS)
VERILOG_DEPS            := $(VERILATOR_SRC_DIR)/ft245_wrapper.v ft245.v $(VERILOG_INCLUDE_DEPS)

# Cocotb setup
COCOTB_DIR              = test/cocotb
# VERILOG_SOURCES         = $(VERILOG_INCLUDE_DEPS)
VERILOG_SOURCES         = ft245.v
TOPLEVEL                = ft245
COCOTB_PY_DIR           = test/cocotb/src
MODULE                  = test
include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
SIM                     = icarus
SIM_BUILD               = $(COCOTB_DIR)/build
COMPILE_ARGS            = $(VERILOG_INCLUDE_DIRS) -lxt2

.PHONY: test_cocotb
test_cocotb:
	$(MAKE) sim

.PHONY: test_verilator
test_verilator: verilator_wrapper
	./$(VERILATOR_OBJ_DIR)/Vft245_wrapper

.PHONY: verilator_wrapper
verilator_wrapper: $(VERILATOR_OBJ_DIR)/Vft245_wrapper

$(VERILATOR_OBJ_DIR)/Vft245_wrapper: $(CC_DEPS) $(VERILOG_DEPS) Makefile
	verilator -sv -trace -Wall \
		$(VERILOG_INCLUDE_DIRS) \
		-CFLAGS "$(CC_INCLUDES)" \
		$(VERILATOR_DEBUG_FLAGS) \
		-I$(VERILATOR_SRC_DIR) \
		--top-module ft245_wrapper \
		--cc $(VERILATOR_SRC_DIR)/ft245_wrapper.v \
		--exe $(realpath $(VERILATOR_SRC_DIR))/testbench.cc \
		--Mdir $(VERILATOR_OBJ_DIR)
	$(MAKE) -j$(shell nproc) -C $(VERILATOR_OBJ_DIR) -f Vft245_wrapper.mk Vft245_wrapper

.PHONY: synth
synth: synth.ilang

synth.ilang: $(YOSYS_SYNTH_DIR)/synth.tcl ft245.v
	$(YOSYS) $(YOSYS_SYNTH_DIR)/synth.tcl

.PHONY: xilinx
xilinx: synth $(YOSYS_SYNTH_DIR)/xilinx.tcl
	$(YOSYS) $(YOSYS_SYNTH_DIR)/xilinx.tcl

.PHONY: clean
clean::
	rm -f *.ilang
	rm -rf $(VERILATOR_OBJ_DIR)
	rm -f *.vcd
