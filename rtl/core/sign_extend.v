`timescale 1ns/1ps

// sign_extend -- immediate field extractor + 64-bit sign/zero extension
// 
//  The instruction is 32-bit but every immediate lives in a small field inside
//  it. Before the value can drive the 64-bit datapath (ALU operand, branch /
//  address offset) it must be widened to 64 bits (without changing its value):
//
//    - zero extension : upper bits := 0          (unsigned immediates)
//    - sign extension : upper bits := field MSB  (signed offsets, 2's complement)
//
//  This module ONLY extends. Scaling for PC-relative branches (the "x4" /
//  shift-left-2) is done in branch_unit.v, not here.
//
//  Inputs
//    instr[31:0]   -- the raw 32-bit instruction
//    imm_sel[2:0]  -- which instruction format / field to extract (from control.v)
//
//  imm_sel encoding
//    000  I-Type   ALU_imm   = instr[21:10]  (12b)  -> zero-ext  (ADDI/SUBI ...)
//    001  D-Type   DT_addr   = instr[20:12]  ( 9b)  -> sign-ext  (LDUR/STUR ...)
//    010  B-Type   BR_addr   = instr[25:0]   (26b)  -> sign-ext  (B / BL)
//    011  CB-Type  COND_addr = instr[23:5]   (19b)  -> sign-ext  (CBZ/CBNZ/B.cond)
//    100  IW-Type  MOV_imm   = instr[20:5]   (16b)  -> zero-ext  (MOVZ/MOVK)
//    101  P-Type   off       = instr[21:15]  ( 7b)  -> sign-ext  (LDP/STP)
//    110  unused                                      -> 0
//    111  unused                                      -> 0
//
//  Output
//    imm_ext[63:0] -- selected immediate, extended to 64 bits
//
//  Style: pure assign with concatenation / bit replication only (no arithmetic,
//  no shift, no ternary). Format selection uses the mux8_1_64 primitive.

module sign_extend(
    output [63:0] imm_ext,
    input [31:0] instr,
    input [2:0] imm_sel
);
    // --- Per-format extended candidates ---
    // I-type: 12-bit unsigned ALU immediate    -> zero-extend
    wire [63:0] imm_i;
    assign imm_i = {52'b0, instr[21:10]};

    // D-type: 9-bit signed load/store address offset   -> sign-extend (bit 20)
    wire [63:0] imm_d;
    assign imm_d = {{55{instr[20]}}, instr[20:12]};

    // B-type: 26-bit signed branch offset  -> sign-extend (bit 25)
    wire [63:0] imm_b;
    assign imm_b = {{38{instr[25]}}, instr[25:0]};

    // CB-Type : 19-bit signed conditional branch offset   -> sign-extend (bit 23)
    wire [63:0] imm_cb;
    assign imm_cb = {{45{instr[23]}}, instr[23:5]};

    // IW-Type : 16-bit MOVZ/MOVK immediate     -> zero-extend
    //           (the hw left-shift is applied by the MOV path, not here)
    wire [63:0] imm_iw;
    assign imm_iw = {48'b0, instr[20:5]};

    // P-Type  : 7-bit signed LDP/STP pair offset   -> sign-extend (bit 21)
    wire [63:0] imm_p;
    assign imm_p  = {{57{instr[21]}}, instr[21:15]};

    // --- Format select ---
    //   a0..a5 = the six formats above; a6/a7 unused -> tie to 0.
    mux8_1_64 u_sel(
        .y(imm_ext),
        .a0(imm_i),
        .a1(imm_d),
        .a2(imm_b),
        .a3(imm_cb),
        .a4(imm_iw),
        .a5(imm_p),
        .a6(64'b0),
        .a7(64'b0),
        .sel(imm_sel)
    );

endmodule