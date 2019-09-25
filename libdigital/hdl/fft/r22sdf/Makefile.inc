# vivado paths
VIVADO_SRC_PATH	:= -I/home/matt/src/vivado/2019_libs
UNIMACRO_PATH	:= $(VIVADO_SRC_PATH)/unimacro
UNISIMS_PATH	:= $(VIVADO_SRC_PATH)/unisims

# local dirs
HDL_ROOT        := $(shell git rev-parse --show-toplevel)/libdigital/hdl
LOCAL_DIRS      := -I$(HDL_ROOT)/ram

INCLUDE_DIRS	:= $(VIVADO_SRC_PATH) $(UNIMACRO_PATH) $(UNISIMS_PATH) $(LOCAL_DIRS)
