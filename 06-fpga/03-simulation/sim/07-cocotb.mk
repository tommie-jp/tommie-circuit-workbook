# Makefile
SIM ?= icarus
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(PWD)/counter4.v
COCOTB_TOPLEVEL = counter4
COCOTB_TEST_MODULES = test_counter4
include $(shell cocotb-config --makefiles)/Makefile.sim
