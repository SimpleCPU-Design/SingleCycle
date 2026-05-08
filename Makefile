IVERILOG := iverilog
VVP := vvp
GKTWAVE := gtkwave
IFLAGS := -g2012

# Source files
RTL_PRIMS := rtl/lib/primitives.v

RTL_ADD := rtl/arith/adder64.v
RTL_SHIFT := rtl/arith/barrel_shift.v
RTL_MULT := rtl/arith/mul64.v
RTL_ARITH := $(RTL_ADD) $(RTL_SHIFT) $(RTL_MULT) 


RTL_COMMON := $(RTL_PRIMS) $(RTL_ARITH)

# Testbench files
TB_PRIMS := tb/lib/tb_primitives.v

TB_ADD := tb/arith/tb_adder64.v
TB_SHIFT := tb/arith/tb_barrel_shift.v
TB_MULT := tb/arith/tb_mul64.v
TB_ARITH := $(TB_ADD) $(TB_SHIFT) $(TB_MULT)

# Simulation Binaries
SIM_DIR := sim

BIN_PRIM := $(SIM_DIR)/tb_primitives

BIN_ADD := $(SIM_DIR)/tb_adder64
BIN_SHIFT := $(SIM_DIR)/tb_barrel_shift
BIN_MULT := $(SIM_DIR)/tb_mul64
BIN_ARITH := $(SIM_DIR)/tb_arith

VCD := $(SIM_DIR)/dump.vcd

.PHONY: all compile run wave clean \
		compile_prims compile_adder compile_shifter compile_mult \
		run_prims run_adder \

# Default -> compile + run all
all: run

# Compile Targets
compile: compile_prims compile_adder compile_shifter compile_mult

compile_prims:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_PRIM) \
	$(TB_PRIMS) $(RTL_PRIMS)

compile-prims:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_PRIM) \
	  $(TB_PRIMS) $(RTL_PRIMS)

compile-adder:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_ADD) \
	  $(TB_ADD) $(RTL_PRIMS) $(RTL_ADD)

compile-shift:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_BSH) \
	  $(TB_SHIFT) $(RTL_PRIMS) $(RTL_SHIFT)

compile-mul:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_MUL) \
	  $(TB_MULT) $(RTL_PRIMS) $(RTL_ADD) $(RTL_MULT)

compile_arith:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_ARITH) \
	$(TB_ARITH) $(RTL_PRIMS) $(RTL_ARITH)

	
# Run Targets
run: run_prims run_arith

run_prims: compile_prims
	$(VVP) $(BIN_PRIM)

run_adder: compile_adder
	$(VVP) $(BIN_ADD)

run_shifter: compile_shifter
	$(VVP) $(BIN_SHIFT)

run_mult: compile_mult
	$(VVP) $(BIN_MULT)

run_arith: compile_arith
	$(VVP) $(BIN_ARITH)


# Wave Targets (run + wave)





# Clean
clean: 
	rm -rf $(SIM_DIR)/*