IVERILOG := iverilog
VVP := vvp
GKTWAVE := gtkwave
IFLAGS := -g2012

# Source files
RTL_PRIMS := rtl/lib/primitives.v
RTL_ADD := rtl/arith/adder64.v
RTL_SHIFT := rtl/arith/barrel_shift.v
RTL_ARITH := $(RTL_ADD) $(RTL_SHIFT)


RTL_COMMON := $(RTL_PRIMS) $(RTL_ARITH)

# Testbench files
TB_PRIMS := tb/lib/tb_primitives.v
TB_ADD := tb/arith/tb_adder64.v
TB_SHIFT := tb/arith/tb_barrel_shift.v

# Simulation Binaries
SIM_DIR := sim
BIN_PRIM := $(SIM_DIR)/tb_primitives
BIN_ADD := $(SIM_DIR)/tb_adder64
BIN_SHIFT := $(SIM_DIR)/tb_barrel_shift

VCD := $(SIM_DIR)/dump.vcd

.PHONY: all compile run wave clean \
		compile_prims compile_adder compile_shifter \
		run_prims run_adder \

# Default -> compile + run all
all: run

# Compile Targets
compile: compile_prims compile_adder compile_shifter

compile_prims:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_PRIM) \
	$(TB_PRIMS) $(RTL_PRIMS)

compile_adder:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_ADD) \
	$(TB_ADD) $(RTL_PRIMS) $(RTL_ADD)

compile_shifter:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_SHIFT) \
	$(TB_SHIFT) $(RTL_PRIMS) $(RTL_SHIFT)

	
# Run Targets
run: run_prims run_adder run_shifter

run_prims: compile_prims
	$(VVP) $(BIN_PRIM)

run_adder: compile_adder
	$(VVP) $(BIN_ADD)

run_shifter: compile_shifter
	$(VVP) $(BIN_SHIFT)


# Wave Targets (run + wave)





# Clean
clean: 
	rm -rf $(SIM_DIR)/*