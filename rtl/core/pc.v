`timescale 1ns/1ps

// --- Program Counter (+4 incrementer + branch mux + stall-able PC Register)
//  Datapath built from this module:
//
//      pc ──► adder64(+4) ──► pc_plus4 ─┐
//                                        ├─ mux(branch_taken) ─► next_pc
//                       branch_target ──┘
//      next_pc ─ mux(pc_write) ─► pc_d ─► dff64 ─► pc   (rst -> pc = 0)
//                  hold = pc ──┘
//
//  - pc_plus4 is ALWAYS pc+4 (used as the BL link value, mem_to_reg=10, even on
//    a taken branch -- the link must be the *branch* instruction's pc+4).
//  - pc_write : 1 = accept next_pc, 0 = hold (pipeline stall / div_busy).
//               Single-cycle top ties this to 1'b1.
//  - Self-contained: builds its register from dff64 + mux2_1_64 primitives so it
//    does not depend on rtl/mem/reg64.v.
//
//  Inputs
//    clk, rst                 -- rst is synchronous (dff64), forces pc = 0
//    pc_write                 -- 1: advance, 0: hold current pc
//    branch_taken             -- 1: take branch_target, 0: take pc+4
//    branch_target[63:0]      -- resolved branch / jump target (from branch_unit)
//
//  Outputs
//    pc[63:0]                 -- current program counter (to instruction_mem)
//    pc_plus4[63:0]           -- pc + 4 (sequential next / BL link)
//
//  Style: module instances + constant literals only. No always@(*), no ternary,
//  no shift, no if/case.

module pc(
    output [63:0] pc,
    output [63:0] pc_plus4,
    input clk,
    input rst,
    input pc_write,
    input branch_taken,
    input [63:0] branch_target
);
    wire c_unused; // +4 carry out, intentionally unused
    wire [63:0] next_pc; // pc+4 or branch target
    wire [63:0] pc_d; // value presented to the PC Register

    // -- pc + 4 ---
    adder64 u_inc(
        .sum(pc_plus4),
        .cout(c_unused),
        .a(pc),
        .b(64'd4),
        .cin(1'b0)
    );

    // --- Branch mux: branch_taken ? branch_target : pc+4 ---
    mux2_1_64 u_branch_mux(
        .y(next_pc),
        .a(pc_plus4),
        .b(branch_target),
        .sel(branch_taken)
    );

    // --- Stall mux: pc_write ? next_pc : pc ---
    mux2_1_64 u_hold_mux(
        .y(pc_d),
        .a(pc),
        .b(next_pc),
        .sel(pc_write)
    );

    // --- PC Register ---
    dff64 u_pc_reg(
        .q(pc),
        .d(pc_d),
        .clk(clk),
        .rst(rst)
    );
endmodule
