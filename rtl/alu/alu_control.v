`timescale 1ns/1ps

// ================================================================================
//  Maps the instruction opcode (plus the funct/op2 field for the ambiguous
//  groups) into the 6-bit alu_op consumed by alu.v.
//
//  Inputs
//    alu_op_main[1:0]  -- from control.v
//        00 -> ADD   (LDUR/STUR address calc, etc.)
//        01 -> SUB   (CBZ/CBNZ compare, etc.)
//        10 -> R-type (decode from opcode[10:0] + funct[5:0])
//        11 -> I-type (decode from opcode[10:1] = instr[31:22])
//    opcode[10:0]      -- instr[31:21]  (R/D-type opcode field; I-type uses [10:1])
//    funct[5:0]        -- instr[15:10]  (shamt / op2 / Ra+o0 field)
//
//  Output
//    alu_op[5:0]       -- see encoding table in alu.v
//
// -- alu_op encoding --
//    000000 ADD    000001 SUB    000010 AND    000011 ORR
//    000100 EOR    000101 BIC    000110 ORN    000111 EON
//    001000 LSL    001001 LSR    001010 ASR    001011 ROR
//    001100 MUL    001101 SMULH  001110 UMULH  001111 MADD
//    010000 MSUB   010001 SDIV   010010 UDIV   010011 PASS_B
//
// - MUL / MADD / MSUB share same opcode
// 
// opcode 10011011000 -> MUL / MADD / MSUB. This sharing is intentional.
//      instr[15] (= funct[5], the ARMv8 "o0" bit):  0 -> MADD   1 -> MSUB
//      Ra = instr[14:10] (5 bits);  MUL ≡ MADD with Ra = XZR (reads 0, so
//      c + a*b = a*b).  Standalone alu_op MUL (001100) is therefore left
//      unused by this decoder but remains valid in alu.v.

module alu_control(
    output [5:0] alu_op,
    input [1:0] alu_op_main,
    input [10:0] opcode,
    input [5:0] funct
);
    // --- alu_op_main one-hot ---
    wire nm1, nm0;
    not n_m1(nm1, alu_op_main[1]);
    not n_m0(nm0, alu_op_main[0]);

    wire m_add_main;    // 00 -> force ADD
    wire m_sub_main;    // 01 -> force SUB
    wire m_rtype;       // 10 -> R-type decode
    wire m_itype;       // 11 -> I-type decode
    and a_ma(m_add_main, nm1, nm0);
    and a_ms(m_sub_main, nm1, alu_op_main[0]);
    and a_mr(m_rtype, alu_op_main[1], nm0);
    and a_mi(m_itype, alu_op_main[1], alu_op_main[0]);

    // --- Inverted opcode / funct bits ---
    wire no10, no9, no8, no7, no6, no5, no4, no3, no2, no1, no0;
    not n_o10(no10, opcode[10]);
    not n_o9(no9, opcode[9]);
    not n_o8(no8, opcode[8]);
    not n_o7(no7, opcode[7]);
    not n_o6(no6, opcode[6]);
    not n_o5(no5, opcode[5]);
    not n_o4(no4, opcode[4]);
    not n_o3(no3, opcode[3]);
    not n_o2(no2, opcode[2]);
    not n_o1(no1, opcode[1]);
    not n_o0(no0, opcode[0]);

    // Only funct[5] (= instr[15], o0) is consumed -- MADD/MSUB split
    wire nf5;
    not n_f5(nf5, funct[5]);

    // --- R-type opcode matches (instr[31:21]) ---
    wire d_add, d_adds, d_sub, d_subs;
    wire d_and, d_ands, d_orr, d_eor;
    wire d_bic, d_orn, d_eon;
    wire d_lsl, d_lsr;
    wire d_smulh, d_umulh;
    wire d_asr, d_ror, d_sdiv, d_udiv;
    wire d_grp_mac; // 10011011000 -> MUL / MADD / MSUB

    assign d_add = opcode[10] & no9 & no8 & no7 & opcode[6] & no5 & opcode[4] & opcode[3] & no2 & no1 & no0; // 10001011000
    assign d_adds = opcode[10] & no9 & opcode[8] & no7 & opcode[6] & no5 & opcode[4] & opcode[3] & no2 & no1 & no0; // 10101011000
    assign d_sub = opcode[10] & opcode[9] & no8 & no7 & opcode[6] & no5 & opcode[4] & opcode[3] & no2 & no1 & no0; // 11001011000
    assign d_subs = opcode[10] & opcode[9] & opcode[8] & no7 &  opcode[6] & no5 & opcode[4] & opcode[3] & no2 & no1 & no0; // 11101011000
    assign d_and = opcode[10] & no9 & no8 & no7 & opcode[6] & no5 & opcode[4] & no3 & no2 & no1 & no0; // 10001010000
    assign d_ands = opcode[10] & opcode[9] & opcode[8] & no7 & opcode[6] & no5 & opcode[4] & no3 & no2 & no1 & no0; // 11101010000
    assign d_orr = opcode[10] & no9 & opcode[8] & no7 & opcode[6] & no5 & opcode[4] & no3 & no2 & no1 & no0; // 10101010000
    assign d_eor = opcode[10] & opcode[9] & no8 & no7 & opcode[6] & no5 & opcode[4] & no3 & no2 & no1 & no0; // 11001010000
    assign d_bic = no10 & no9 & no8 & no7 & opcode[6] & no5 & opcode[4] & no3 & no2 & no1 & opcode[0]; // 00001010001
    assign d_orn = no10 & no9 & opcode[8] & no7 & opcode[6] & no5 & opcode[4] & no3 & no2 & no1 & opcode[0]; // 00101010001
    assign d_eon = no10 & opcode[9] & no8 & no7 & opcode[6] & no5 & opcode[4] & no3 & no2 & no1 & opcode[0]; // 01001010001
    assign d_lsl = opcode[10] & opcode[9] & no8 & opcode[7] & no6 & no5 & opcode[4] & opcode[3] & no2 & opcode[1] & opcode[0]; // 1101001101
    assign d_lsr = opcode[10] & opcode[9] & no8 & opcode[7] & no6 & no5 & opcode[4] & opcode[3] & no2 & opcode[1] & no0; // 11010011010
    assign d_smulh = opcode[10] & no9 & no8 & opcode[7] & opcode[6] & no5 & opcode[4] & opcode[3] & no2 & opcode[1] & no0; // 10011011010
    assign d_umulh = opcode[10] & no9 & no8 & opcode[7] & opcode[6] & no5 & opcode[4] & opcode[3] & opcode[2] & opcode[1] & no0; // 10011011110
    assign d_asr = opcode[10] & opcode[9] & no8 & opcode[7] & no6 & no5 & opcode[4] & opcode[3] & no2 & no1 & opcode[0]; // 11010011001
    assign d_ror = opcode[10] & opcode[9] & no8 & opcode[7] & no6 & no5 & opcode[4] & opcode[3] & no2 & no1 & no0; // 11010011000
    assign d_sdiv = opcode[10] & no9 & no8 & opcode[7] & opcode[6] & no5 & opcode[4] & no3 & opcode[2] & opcode[1] & no0; // 10011010110
    assign d_udiv = opcode[10] & no9 & no8 & opcode[7] & opcode[6] & no5 & opcode[4] & no3 & opcode[2] & opcode[1] & opcode[0]; // 10011010111
    assign d_grp_mac = opcode[10] & no9 & no8 & opcode[7] & opcode[6] & no5 & opcode[4] & opcode[3] & no2 & no1 & no0; // 10011011000
    
    // MUL / MADD / MSUB 
    //   d_grp_mac & ~o0 -> MADD (also covers MUL: Ra=XZR makes c=0 -> a*b)
    //   d_grp_mac &  o0 -> MSUB 
    wire d_madd, d_msub;
    and a_madd(d_madd, d_grp_mac, nf5);
    and a_msub(d_msub, d_grp_mac, funct[5]);

    // --- R-type alu_op assembly
    //   alu_op codes:
    //     SUB 000001  AND 000010  ORR 000011  EOR 000100  BIC 000101
    //     ORN 000110  EON 000111  LSL 001000  LSR 001001  ASR 001010
    //     ROR 001011  SMULH 001101  UMULH 001110  MADD 001111
    //     MSUB 010000  SDIV 010001  UDIV 010010
    //   (ADD/ADDS/ANDS contribute 0 in the bits not listed; ADD = 000000)
    wire r_op0, r_op1, r_op2, r_op3, r_op4;
    or o_rop0(r_op0, d_sub, d_subs, d_orr, d_bic, d_eon, d_lsr, d_ror, d_smulh, d_madd, d_sdiv);
    or o_rop1(r_op1, d_and, d_ands, d_orr, d_orn, d_eon, d_asr, d_ror, d_umulh, d_madd, d_udiv);
    or o_rop2(r_op2, d_eor, d_bic, d_orn, d_eon, d_smulh, d_umulh, d_madd);
    or o_rop3(r_op3, d_lsl, d_lsr, d_asr, d_ror, d_smulh, d_umulh, d_madd);
    or o_rop4(r_op4, d_msub, d_sdiv, d_udiv);
    
    // --- I-type opcode matches (instr[31:21] = opcode[10:1])
    wire di_subi, di_subis, di_andi, di_orri, di_eori;
    // ADDI 1001000100 / ADDIS 1011000100 -> ADD (no bits) ; not matched explicitly
    assign di_subi  = opcode[10] & opcode[9] & no8 & opcode[7] & no6 & no5 & no4 & opcode[3] & no2 & no1; // 1101000100
    assign di_subis = opcode[10] & opcode[9] & opcode[8] & opcode[7] & no6 & no5 & no4 & opcode[3] & no2 & no1; // 1111000100
    assign di_andi  = opcode[10] & no9 & no8 & opcode[7] & no6 & no5 & opcode[4] & no3 & no2 & no1;       // 1001001000
    assign di_orri  = opcode[10] & no9 & opcode[8] & opcode[7] & no6 & no5 & opcode[4] & no3 & no2 & no1; // 1011001000
    assign di_eori  = opcode[10] & opcode[9] & no8 & opcode[7] & no6 & no5 & opcode[4] & no3 & no2 & no1; // 1101001000

    //   SUBI/SUBIS -> SUB 000001 ; ANDI -> AND 000010 ; ORRI → ORR 000011 ;
    //   EORI -> EOR 000100 ; ADDI/ADDIS -> ADD 000000
    wire i_op0, i_op1, i_op2;
    or o_iop0(i_op0, di_subi, di_subis, di_orri);
    or o_iop1(i_op1, di_andi, di_orri);
    assign i_op2 = di_eori;

    // --- Final alu_op mux ---
    //   00 -> ADD (000000)        -- no terms
    //   01 -> SUB (000001)        -- bit0 only
    //   10 -> R-type r_op[4:0]
    //   11 -> I-type i_op[2:0]
    wire a0_r, a0_i, a1_r, a1_i, a2_r, a2_i, a3_r, a4_r;
    and ga0r(a0_r, m_rtype, r_op0);
    and ga0i(a0_i, m_itype, i_op0);
    and ga1r(a1_r, m_rtype, r_op1);
    and ga1i(a1_i, m_itype, i_op1);
    and ga2r(a2_r, m_rtype, r_op2);
    and ga2i(a2_i, m_itype, i_op2);
    and ga3r(a3_r, m_rtype, r_op3);
    and ga4r(a4_r, m_rtype, r_op4);

    or o_aluop0(alu_op[0], a0_r, a0_i, m_sub_main);
    or o_aluop1(alu_op[1], a1_r, a1_i);
    or o_aluop2(alu_op[2], a2_r, a2_i);
    or o_aluop3(alu_op[3], a3_r, 1'b0);
    or o_aluop4(alu_op[4], a4_r, 1'b0);
    assign alu_op[5] = 1'b0;
    
endmodule
