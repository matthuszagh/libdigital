VIVADO_INCS	:= $(VIVADO_SRC_PATH)
VIVADO_INCS	+= $(VIVADO_SRC_PATH)/unisims
VIVADO_INCS	+= $(VIVADO_SRC_PATH)/unimacro

ICARUS_BUILD_DIR	:= icarus/build

.PHONY: icarus
icarus: $(ICARUS_BUILD_DIR)/$(TOP_MODULE)_tb.vcd

$(ICARUS_BUILD_DIR)/$(TOP_MODULE)_tb.vcd: $(VERILOG_SRCS)
	iverilog $(VERILOG_INCS) $(addprefix -I,$(VIVADO_INCS)) \
		-DICARUS $(TOP_MODULE_SRC) -o $(ICARUS_BUILD_DIR)/fft_r22sdf_tb
	./$(ICARUS_BUILD_DIR)/fft_r22sdf_tb
	gtkwave $(ICARUS_BUILD_DIR)/fft_r22sdf_tb.vcd
