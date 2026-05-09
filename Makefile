IVERILOG := iverilog
VVP := vvp
GKTWAVE := gtkwave
IFLAGS := -g2012

# Verilator (faster sim for large gate-level DUTs)
VERILATOR := verilator
# --binary: build a self-contained executable from Verilog testbench
# --timing: support #delays in initial blocks
# --trace : enable $dumpfile/$dumpvars
# -j 0    : parallel build
VFLAGS := --binary --timing --trace -j 0 --quiet \
          -Wno-WIDTH -Wno-UNUSED -Wno-CASEINCOMPLETE \
          -Wno-DECLFILENAME -Wno-MULTITOP

# Source files
RTL_PRIMS := rtl/lib/primitives.v

RTL_ADD := rtl/arith/adder64.v
RTL_SHIFT := rtl/arith/barrel_shift.v
RTL_MULT := rtl/arith/mul64.v
RTL_DIV_SC := rtl/arith/div64_sc.v
RTL_ARITH := $(RTL_ADD) $(RTL_SHIFT) $(RTL_MULT) $(RTL_DIV_SC)


RTL_COMMON := $(RTL_PRIMS) $(RTL_ARITH)

# Testbench files
TB_PRIMS := tb/lib/tb_primitives.v

TB_ADD := tb/arith/tb_adder64.v
TB_SHIFT := tb/arith/tb_barrel_shift.v
TB_MULT := tb/arith/tb_mul64.v
TB_DIV_SC := tb/arith/tb_div64_sc.v
TB_ARITH := $(TB_ADD) $(TB_SHIFT) $(TB_MULT) $(TB_DIV_SC)


# Simulation Binaries
SIM_DIR := sim

BIN_PRIM := $(SIM_DIR)/tb_primitives

BIN_ADD := $(SIM_DIR)/tb_adder64
BIN_SHIFT := $(SIM_DIR)/tb_barrel_shift
BIN_MULT := $(SIM_DIR)/tb_mul64
BIN_DIV_SC := $(SIM_DIR)/tb_div64_sc
BIN_ARITH := $(SIM_DIR)/tb_arith

VCD := $(SIM_DIR)/dump.vcd

# Verilator build dirs
VSIM_DIR  := vsim
VDIR_PRIM := $(VSIM_DIR)/tb_primitives
VDIR_ADD  := $(VSIM_DIR)/tb_adder64
VDIR_SHIFT:= $(VSIM_DIR)/tb_barrel_shift
VDIR_MULT := $(VSIM_DIR)/tb_mul64
VDIR_DIV_SC := $(VSIM_DIR)/tb_div64_sc

.PHONY: all compile run wave clean \
		compile_prims compile_adder compile_shifter compile_mult compile_div_sc \
		run_prims run_adder run_shifter run_mult run_div_sc \
		vcompile_prims vcompile_adder vcompile_shifter vcompile_mult vcompile_div_sc \
		vrun_prims vrun_adder vrun_shifter vrun_mult vrun_div_sc vclean

# Default -> compile + run all
all: run

# Compile Targets
compile: compile_prims compile_adder compile_shifter compile_mult compile_div_sc

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

compile_mult:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_MULT) \
	  $(TB_MULT) $(RTL_PRIMS) $(RTL_ADD) $(RTL_MULT)

compile_div_sc:
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) $(IFLAGS) -o $(BIN_DIV_SC) \
	  $(TB_DIV_SC) $(RTL_PRIMS) $(RTL_ADD) $(RTL_DIV_SC)

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

run_div_sc: compile_div_sc
	$(VVP) $(BIN_DIV_SC)

run_arith: compile_arith
	$(VVP) $(BIN_ARITH)


# Wave Targets (run + wave)




# ============================
# Verilator Targets
# ============================
# Use these for much faster simulation of large gate-level DUTs (e.g. div64_sc).
# Each tb is built into its own vsim/<tb>/ directory; binary is V<topname>.

vcompile_prims:
	@mkdir -p $(VDIR_PRIM)
	$(VERILATOR) $(VFLAGS) --top-module tb_primitives --Mdir $(VDIR_PRIM) \
	  $(TB_PRIMS) $(RTL_PRIMS)

vcompile_adder:
	@mkdir -p $(VDIR_ADD)
	$(VERILATOR) $(VFLAGS) --top-module tb_adder64 --Mdir $(VDIR_ADD) \
	  $(TB_ADD) $(RTL_PRIMS) $(RTL_ADD)

vcompile_shifter:
	@mkdir -p $(VDIR_SHIFT)
	$(VERILATOR) $(VFLAGS) --top-module tb_barrel_shift --Mdir $(VDIR_SHIFT) \
	  $(TB_SHIFT) $(RTL_PRIMS) $(RTL_SHIFT)

vcompile_mult:
	@mkdir -p $(VDIR_MULT)
	$(VERILATOR) $(VFLAGS) --top-module tb_mul64 --Mdir $(VDIR_MULT) \
	  $(TB_MULT) $(RTL_PRIMS) $(RTL_ADD) $(RTL_MULT)

vcompile_div_sc:
	@mkdir -p $(VDIR_DIV_SC)
	$(VERILATOR) $(VFLAGS) --top-module tb_div64_sc --Mdir $(VDIR_DIV_SC) \
	  $(TB_DIV_SC) $(RTL_PRIMS) $(RTL_ADD) $(RTL_DIV_SC)

vrun_prims: vcompile_prims
	./$(VDIR_PRIM)/Vtb_primitives

vrun_adder: vcompile_adder
	./$(VDIR_ADD)/Vtb_adder64

vrun_shifter: vcompile_shifter
	./$(VDIR_SHIFT)/Vtb_barrel_shift

vrun_mult: vcompile_mult
	./$(VDIR_MULT)/Vtb_mul64

vrun_div_sc: vcompile_div_sc
	./$(VDIR_DIV_SC)/Vtb_div64_sc


vclean:
	rm -rf $(VSIM_DIR)


# Clean
clean: 
	rm -rf $(SIM_DIR)/*