export

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
VERILOG_SOURCES		= $(VERILOG_SRCS)
# Cocotb has trouble finding verilog files. Pass them directly to
# the simulator instead.
COMPILE_ARGS		= $(addprefix -I,$(VERILOG_DIRS))
# Parameters must be set through the simulator.
# EXTRA_ARGS		= "-PWIDTH=64 -PSIZE=1024"

ICARUS_BUILD_DIR	:= icarus/build

.PHONY: cocotb
cocotb:
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
