# Makefile

# defaults
SIM ?= ghdl
EXTRA_ARGS += --std=08
TOPLEVEL_LANG ?= vhdl

SIM_ARGS+=--vcd=tb_axi_stream.vcd

VHDL_SOURCES += $(PWD)/../hdl/axi_stream_dut.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = axi_stream_dut

# MODULE is the basename of the Python test file
MODULE = tb_axi_stream

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim