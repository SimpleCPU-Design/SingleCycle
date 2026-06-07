`timescale 1ns/1ps

// ================================================================================
//  branch_unit -- branch decision + branch target computation (ID stage).
//
//  Evaluates whether a branch is taken and produces its target address.
//
//  Inputs
//    branch_type[2:0]  from control.v:
//        000 none  001 B  010 BL  011 BR  100 BLR  101 CBZ  110 CBNZ  111 B.cond
//    pc[63:0]          PC of the branch instruction (target base for PC-relative)
//    imm_ext[63:0]     sign-extended branch offset from sign_extend.v (word count;
//                      this block applies the x4 / shift-left-2 scaling)
//    reg_rt[63:0]      Rt operand, tested for zero by CBZ / CBNZ
//    reg_rn[63:0]      Rn operand, used as the absolute target by BR / BLR
//    cond[3:0]         B.cond condition code (instr[3:0])
//    nzcv[3:0]         current flags, {N, Z, C, V} = nzcv[3], nzcv[2], nzcv[1], nzcv[0]
//
//  Outputs
//    branch_taken      1 -> redirect the PC to branch_target
//    branch_target     PC-relative (pc + imm_ext*4) for B/BL/CBZ/CBNZ/B.cond,
//                      or the register value reg_rn for BR / BLR
// ================================================================================

module branch_unit(
    output        branch_taken,
    output [63:0] branch_target,
    input  [2:0]  branch_type,
    input  [63:0] pc,
    input  [63:0] imm_ext,
    input  [63:0] reg_rt,
    input  [63:0] reg_rn,
    input  [3:0]  cond,
    input  [3:0]  nzcv
);
    // --- Named flag bits: NZCV = {N, Z, C, V} ---
    wire n_flag, z_flag, c_flag, v_flag;
    assign n_flag = nzcv[3];
    assign z_flag = nzcv[2];
    assign c_flag = nzcv[1];
    assign v_flag = nzcv[0];

    // ===== branch_type one hot decode =====
    wire is_b, is_bl, is_br, is_blr, is_cbz, is_cbnz, is_bcond;
    assign is_b     = ~branch_type[2] & ~branch_type[1] &  branch_type[0]; // 001
    assign is_bl    = ~branch_type[2] &  branch_type[1] & ~branch_type[0]; // 010
    assign is_br    = ~branch_type[2] &  branch_type[1] &  branch_type[0]; // 011
    assign is_blr   =  branch_type[2] & ~branch_type[1] & ~branch_type[0]; // 100
    assign is_cbz   =  branch_type[2] & ~branch_type[1] &  branch_type[0]; // 101
    assign is_cbnz  =  branch_type[2] &  branch_type[1] & ~branch_type[0]; // 110
    assign is_bcond =  branch_type[2] &  branch_type[1] &  branch_type[0]; // 111

    // ===== B.cond condition evaluation =====
    //    base condition selected by cond[3:1]; cond[0] inverts it (except AL/NV).
    //      000 EQ/NE   : Z
    //      001 CS/CC   : C
    //      010 MI/PL   : N
    //      011 VS/VC   : V
    //      100 HI/LS   : C & ~Z
    //      101 GE/LT   : N == V        (~(N ^ V))
    //      110 GT/LE   : (N == V) & ~Z
    //      111 AL/NV   : 1  (always; never inverted)
    wire n_eq_v;                       // N == V
    assign n_eq_v = ~(n_flag ^ v_flag);

    // one-hot decode of cond[3:1]
    wire [7:0] csel;
    assign csel[0] = ~cond[3] & ~cond[2] & ~cond[1];
    assign csel[1] = ~cond[3] & ~cond[2] &  cond[1];
    assign csel[2] = ~cond[3] &  cond[2] & ~cond[1];
    assign csel[3] = ~cond[3] &  cond[2] &  cond[1];
    assign csel[4] =  cond[3] & ~cond[2] & ~cond[1];
    assign csel[5] =  cond[3] & ~cond[2] &  cond[1];
    assign csel[6] =  cond[3] &  cond[2] & ~cond[1];
    assign csel[7] =  cond[3] &  cond[2] &  cond[1];

    wire cond_base;
    assign cond_base = (csel[0] & z_flag)
                    | (csel[1] & c_flag)
                    | (csel[2] & n_flag)
                    | (csel[3] & v_flag)
                    | (csel[4] & (c_flag & ~z_flag))
                    | (csel[5] & n_eq_v)
                    | (csel[6] & (n_eq_v & ~z_flag))
                    | (csel[7]);                       // AL/NV -> 1

    // invert on odd code, but NOT for the AL/NV group (csel[7])
    wire cond_invert, cond_true;
    assign cond_invert = cond[0] & ~csel[7];
    assign cond_true   = cond_base ^ cond_invert;

    // ===== Zero test for CBZ / CBNZ =====
    wire rt_is_zero;
    assign rt_is_zero = ~(|reg_rt);

    // ===== branch_taken =====
    assign branch_taken = is_b | is_bl | is_br | is_blr
                        | (is_cbz   &  rt_is_zero)
                        | (is_cbnz  & ~rt_is_zero)
                        | (is_bcond &  cond_true);

    
    // ===== branch_target =====
    //    PC-relative : pc + (imm_ext << 2)   -- scale word offset to bytes
    //    BR / BLR    : reg_rn                -- absolute register target
    wire [63:0] off_x4;
    assign off_x4 = {imm_ext[61:0], 2'b00};   // imm_ext * 4 (concat, no shift op)

    wire [63:0] pc_rel;
    adder64 u_pc_add(
        .sum (pc_rel),
        .cout(),
        .a   (pc),
        .b   (off_x4),
        .cin (1'b0)
    );

    // select reg_rn for register-indirect branches (BR/BLR), else PC-relative
    wire use_reg;
    assign use_reg = is_br | is_blr;

    mux2_1_64 u_tgt_mux(
        .y  (branch_target),
        .a  (pc_rel),     // sel=0 -> PC-relative
        .b  (reg_rn),     // sel=1 -> register target
        .sel(use_reg)
    );
    
    


endmodule