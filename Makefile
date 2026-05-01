IVERILOG := iverilog
VVP := vvp
GKTWAVE := gtkwave
IFLAGS := -g2012

# Source files
RTL_PRIMS := rtl/lib/primitives.v
RTL_ADD := rtl/arith/adder64.v
RTL_ARITH := $(RTL_ADD)


RTL_COMMON := $(RTL_PRIMS) $(RTL_ARITH)

# Testbench files
TB_PRIMS := tb/lib/tb_primitives.v
TB_ADD := tb/arith/tb_adder64.v

# Simulation Binaries
SIM_DIR := sim
BIN_PRIM := $(SIM_DIR)/tb_primitives
BIN_ADD := $(SIM_DIR)/tb_adder64

VCD := $(SIM_DIR)/dump.vcd

.PHONY: all compile run wave clean \
		compile_prims compile_adder \
		run_prims run_adder \

# Default -> compile + run all
all: run

# Compile Targets
compile: compile_prims compile_adder

compile_prims:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_PRIM) \
	$(TB_PRIMS) $(RTL_PRIMS)

compile_adder:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_ADD) \
	$(TB_ADD) $(RTL_PRIMS) $(RTL_ADD)

	
# Run Targets
run: run_prims run_adder

run_prims: compile_prims
	$(VVP) $(BIN_PRIM)

run_adder: compile_adder
	$(VVP) $(BIN_ADD)


# Wave Targets (run + wave)





# Clean
clean: 
	rm -rf $(SIM_DIR)/*