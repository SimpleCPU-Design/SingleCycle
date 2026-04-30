IVERILOG := iverilog
VVP := vvp
GKTWAVE := gtkwave
IFLAGS := -g2012

# Source files
RTL_PRIMS := rtl/lib/primitives.v


RTL_COMMON := $(RTL_PRIMS)

# Testbench files
TB_PRIMS := tb/lib/tb_primitives.v

# Simulation Binaries
SIM_DIR := sim
BIN_PRIM := $(SIM_DIR)/tb_primitives

VCD := $(SIM_DIR)/dump.vcd

.PHONY: all compile run wave clean \
		compile_prims \
		run_prims \

# Default -> compile + run all
all: run

# Compile Targets
compile: compile_prims

compile_prims:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_PRIM) \
	$(TB_PRIMS) $(RTL_PRIMS)

run: run_prims

run_prims: compile_prims
	$(VVP) $(BIN_PRIM)


# Wave Targets (run + wave)





# Clean
clean: 
	rm -rf $(SIM_DIR)/*