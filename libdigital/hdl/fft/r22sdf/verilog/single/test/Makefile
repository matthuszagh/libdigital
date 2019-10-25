export

VIVADO_INCS	:= $(VIVADO_SRC_PATH)
VIVADO_INCS	+= $(VIVADO_SRC_PATH)/unisims
VIVADO_INCS	+= $(VIVADO_SRC_PATH)/unimacro

# Cocotb requires some specific enviro variable definitions. Provide
# them here.

# cocotb places build files relative to this directory.
USER_DIR		= $(TEST_DIR)/cocotb
TOPLEVEL		= $(TOP_MODULE) # top-level verilog module
MODULE			= test_$(TOP_MODULE) # name of the python test module
COCOTB_PY_DIR		= $(USER_DIR)
SIM			= icarus
# places the simulation executable inside the build directory.
SIM_BUILD		= $(USER_DIR)/build
# place simulation results file in build dir
COCOTB_RESULTS_FILE	= $(SIM_BUILD)/results.xml
include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
# TODO setting glbl here is a temporary workaround
VERILOG_SOURCES		= /home/matt/src/vivado/2019_libs/glbl.v $(VERILOG_SRCS)
# Cocotb has trouble finding verilog files. Pass them directly to
# the simulator instead.
COMPILE_ARGS		= $(addprefix -I,$(VERILOG_DIRS) $(VIVADO_INCS))
# Parameters must be set through the simulator.
# EXTRA_ARGS		= "-PWIDTH=64 -PSIZE=1024"
# TODO zlib should be a build dependency of iverilog
# SIM_ARGS		= -lxt2

ICARUS_BUILD_DIR	:= icarus/build

.PHONY: cocotb
cocotb:
	$(MAKE) sim

.PHONY: icarus
icarus: $(ICARUS_BUILD_DIR)/$(TOP_MODULE)_tb.vcd

$(ICARUS_BUILD_DIR)/$(TOP_MODULE)_tb.vcd: $(VERILOG_SRCS)
	iverilog $(VERILOG_INCS) $(addprefix -I,$(VIVADO_INCS)) \
		-DICARUS $(TOP_MODULE_SRC) -o $(ICARUS_BUILD_DIR)/fft_r22sdf_tb
	./$(ICARUS_BUILD_DIR)/fft_r22sdf_tb
	gtkwave $(ICARUS_BUILD_DIR)/fft_r22sdf_tb.vcd
