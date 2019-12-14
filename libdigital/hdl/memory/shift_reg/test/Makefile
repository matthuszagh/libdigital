export
# Cocotb requires some specific enviro variable definitions. Provide
# them here.

# cocotb places build files relative to this directory.
USER_DIR		= $(TEST_DIR)/cocotb
TOPLEVEL		= $(TOP_MODULE) # top-level verilog module
MODULE			= test_$(TOP_MODULE) # name of the python test module
COCOTB_PY_DIR		= $(USER_DIR)
SIM			= icarus
# # use random 0s and 1s instead of x
# COCOTB_RESOLVE_X	= RANDOM
# # keep random values the same between iterations
# RANDOM_SEED		= 1377424946
# places the simulation executable inside the build directory.
SIM_BUILD		= $(USER_DIR)/build
# place simulation results file in build dir
COCOTB_RESULTS_FILE	= $(SIM_BUILD)/results.xml
include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
VERILOG_SOURCES		= $(VERILOG_SRCS)
# Cocotb has trouble finding verilog files. Pass them directly to
# the simulator instead.
COMPILE_ARGS		= $(addprefix -I,$(VERILOG_DIRS))
# Parameters must be set through the simulator.
EXTRA_ARGS		= "-PDATA_WIDTH=25 -PLEN=512"
# TODO zlib should be a build dependency of iverilog
# SIM_ARGS		= -lxt2

# Verilator
VERILATOR_DIR		= $(TEST_DIR)/verilator
VERILATOR_BUILD_DIR	= $(VERILATOR_DIR)/build
VERILATOR_CC_SRCS	= $(shell find $(VERILATOR_DIR) -maxdepth 1 -name '*.cc')
VERILATOR_CC_INCS	= $(addprefix -I,$(VERILATOR_DIR))
VERILATOR_EXEC		= $(VERILATOR_BUILD_DIR)/$(TOP_MODULE)

# Icarus
ICARUS_DIR		= $(TEST_DIR)/icarus
ICARUS_BUILD_DIR	= $(ICARUS_DIR)/build
ICARUS_EXEC		= $(ICARUS_BUILD_DIR)/$(TOP_MODULE)


.PHONY: cocotb
cocotb:
	$(MAKE) sim

.PHONY: verilator
verilator: $(VERILATOR_EXEC)

$(VERILATOR_EXEC): $(VERILATOR_EXEC).mk
	$(MAKE) -j$(shell nproc) -C $(VERILATOR_BUILD_DIR) \
		-f $(VERILATOR_EXEC).mk \
		$(VERILATOR_EXEC)

$(VERILATOR_EXEC).mk:
	verilator -sv -trace -Wall $(VERILOG_INCS) \
		--top-module $(TOP_MODULE) \
		--cc \
		-CFLAGS "$(VERILATOR_CC_INCS)" \
		--exe $(TOP_MODULE).cc \
		-Mdir $(VERILATOR_BUILD_DIR)

.PHONY: icarus
icarus: $(ICARUS_EXEC).lxt
	gtkwave $(ICARUS_EXEC).lxt

$(ICARUS_EXEC).lxt: $(ICARUS_EXEC)
	vvp -lxt2 $(ICARUS_EXEC)

$(ICARUS_EXEC): $(VERILOG_INCS)
	iverilog $(VERILOG_INCS) -s $(TOP_MODULE) -o $(ICARUS_EXEC)

.PHONY: clean
clean::
	rm -rf $(USER_DIR)/build # equivalent to COCOTB_BUILD_DIR
	rm -rf $(ICARUS_BUILD_DIR)
	rm -rf $(VERILATOR_BUILD_DIR)
