`timescale 1ns/1ps

// ================================================================================
//  control -- main control decoder.
//
//  Maps the 11-bit opcode field instr[31:21] into every datapath control signal.
//
//  Format detection from the 11-bit opcode field:
//    R-Type  : full 11-bit match  (operands live in instr[20:0])
//    D-Type  : full 11-bit match  (DT_addr/op2/Rn/Rt in instr[20:0])
//    P-Type  : full 11-bit match  (LDP/STP)
//    I-Type  : 10-bit match on opcode[10:1] (instr[31:22]; opcode[0]=imm MSB)
//    IW-Type :  9-bit match on opcode[10:2] (instr[31:23])
//    CB-Type :  8-bit match on opcode[10:3] (instr[31:24])
//    B-Type  :  6-bit match on opcode[10:5] (instr[31:26])
//  The ISA encoding is prefix-free across these widths, so at most one decode
//  line fires for any opcode.
//
//  Output signal table (CLAUDE.md + imm_sel from DESIGN_NOTES #1):
//    reg_write     1   write the register file
//    alu_src       1   0 = Rm, 1 = immediate (ALU operand B)
//    mem_to_reg    2   00 = ALU, 01 = Mem, 10 = PC+4 (BL/BLR link), 11 = MUL hi
//    mem_read      1   memory load
//    mem_write     1   memory store
//    mem_width     3   000=64b 001=32b 010=16b 011=8b
//    mem_sign_ext  1   sign-extend a load result
//    flag_write    1   update NZCV (only *S forms)
//    branch_type   3   000=none 001=B 010=BL 011=BR 100=BLR 101=CBZ 110=CBNZ 111=B.cond
//    alu_op_main   2   00=ADD 01=SUB 10=R-type 11=I-type   (feeds alu_control)
//    mov_type      2   00=normal 01=MOVZ 10=MOVK
//    pair_op       1   LDP/STP
//    reg2_loc      1   0=Rm[20:16], 1=Rt[4:0]  (register file 2nd read port)
//    imm_sel       3   000=I 001=D 010=B 011=CB 100=IW 101=P  (sign_extend select)
//
//  NOT decoded here (fall through to an all-zero / NOP-like control vector):
//    CSEL/CSINC/CSINV/CSNEG -- need a conditional-select control not yet in the
//                              signal table (deferred, see DESIGN_NOTES).
//    Vector VADD..VSTUR     -- handled by vector_stub.
//    NOP/HLT/BRK            -- inert; HLT/BRK halt signalling is deferred.
//    Any unknown opcode     -- safely decodes to NOP (all signals 0).
// ================================================================================

module control(
    output       reg_write,
    output       alu_src,
    output [1:0] mem_to_reg,
    output       mem_read,
    output       mem_write,
    output [2:0] mem_width,
    output       mem_sign_ext,
    output       flag_write,
    output [2:0] branch_type,
    output [1:0] alu_op_main,
    output [1:0] mov_type,
    output       pair_op,
    output       reg2_loc,
    output [2:0] imm_sel,
    input  [10:0] opcode          // instr[31:21]
);
    // --- Inverted opcode bits ---
    wire no10, no9, no8, no7, no6, no5, no4, no3, no2, no1, no0;
    not n_o10(no10, opcode[10]);
    not n_o9 (no9,  opcode[9]);
    not n_o8 (no8,  opcode[8]);
    not n_o7 (no7,  opcode[7]);
    not n_o6 (no6,  opcode[6]);
    not n_o5 (no5,  opcode[5]);
    not n_o4 (no4,  opcode[4]);
    not n_o3 (no3,  opcode[3]);
    not n_o2 (no2,  opcode[2]);
    not n_o1 (no1,  opcode[1]);
    not n_o0 (no0,  opcode[0]);

    // ===== Per-instruction decode (1 = this opcode) =====

    // --- R-type arithmetic / logical / shift (full 11-bit) ---
    wire d_add, d_sub, d_adds, d_subs;
    wire d_and, d_orr, d_eor, d_ands;
    wire d_lsl, d_lsr, d_asr, d_ror;
    wire d_bic, d_orn, d_eon;
    wire d_mac, d_smulh, d_umulh, d_sdiv, d_udiv;

    assign d_add   = opcode[10]&no9&no8&no7&opcode[6]&no5&opcode[4]&opcode[3]&no2&no1&no0; // 10001011000
    assign d_sub   = opcode[10]&opcode[9]&no8&no7&opcode[6]&no5&opcode[4]&opcode[3]&no2&no1&no0; // 11001011000
    assign d_adds  = opcode[10]&no9&opcode[8]&no7&opcode[6]&no5&opcode[4]&opcode[3]&no2&no1&no0; // 10101011000
    assign d_subs  = opcode[10]&opcode[9]&opcode[8]&no7&opcode[6]&no5&opcode[4]&opcode[3]&no2&no1&no0; // 11101011000
    assign d_and   = opcode[10]&no9&no8&no7&opcode[6]&no5&opcode[4]&no3&no2&no1&no0; // 10001010000
    assign d_orr   = opcode[10]&no9&opcode[8]&no7&opcode[6]&no5&opcode[4]&no3&no2&no1&no0; // 10101010000
    assign d_eor   = opcode[10]&opcode[9]&no8&no7&opcode[6]&no5&opcode[4]&no3&no2&no1&no0; // 11001010000
    assign d_ands  = opcode[10]&opcode[9]&opcode[8]&no7&opcode[6]&no5&opcode[4]&no3&no2&no1&no0; // 11101010000
    assign d_lsl   = opcode[10]&opcode[9]&no8&opcode[7]&no6&no5&opcode[4]&opcode[3]&no2&opcode[1]&opcode[0]; // 11010011011
    assign d_lsr   = opcode[10]&opcode[9]&no8&opcode[7]&no6&no5&opcode[4]&opcode[3]&no2&opcode[1]&no0; // 11010011010
    assign d_asr   = opcode[10]&opcode[9]&no8&opcode[7]&no6&no5&opcode[4]&opcode[3]&no2&no1&opcode[0]; // 11010011001
    assign d_ror   = opcode[10]&opcode[9]&no8&opcode[7]&no6&no5&opcode[4]&opcode[3]&no2&no1&no0; // 11010011000
    assign d_bic   = no10&no9&no8&no7&opcode[6]&no5&opcode[4]&no3&no2&no1&opcode[0]; // 00001010001
    assign d_orn   = no10&no9&opcode[8]&no7&opcode[6]&no5&opcode[4]&no3&no2&no1&opcode[0]; // 00101010001
    assign d_eon   = no10&opcode[9]&no8&no7&opcode[6]&no5&opcode[4]&no3&no2&no1&opcode[0]; // 01001010001
    assign d_mac   = opcode[10]&no9&no8&opcode[7]&opcode[6]&no5&opcode[4]&opcode[3]&no2&no1&no0; // 10011011000 (MUL/MADD/MSUB)
    assign d_smulh = opcode[10]&no9&no8&opcode[7]&opcode[6]&no5&opcode[4]&opcode[3]&no2&opcode[1]&no0; // 10011011010
    assign d_umulh = opcode[10]&no9&no8&opcode[7]&opcode[6]&no5&opcode[4]&opcode[3]&opcode[2]&opcode[1]&no0; // 10011011110
    assign d_sdiv  = opcode[10]&no9&no8&opcode[7]&opcode[6]&no5&opcode[4]&no3&opcode[2]&opcode[1]&no0; // 10011010110
    assign d_udiv  = opcode[10]&no9&no8&opcode[7]&opcode[6]&no5&opcode[4]&no3&opcode[2]&opcode[1]&opcode[0]; // 10011010111

    // --- R-type branch / register indirect (full 11-bit) ---
    wire d_br, d_blr;
    assign d_br  = opcode[10]&opcode[9]&no8&opcode[7]&no6&opcode[5]&opcode[4]&no3&no2&no1&no0; // 11010110000
    assign d_blr = opcode[10]&opcode[9]&no8&opcode[7]&no6&opcode[5]&opcode[4]&no3&no2&no1&opcode[0]; // 11010110001

    // --- D-type loads / stores (full 11-bit) ---
    wire d_ldur, d_stur, d_ldursw, d_sturw, d_ldurh, d_sturh;
    wire d_ldurb, d_sturb, d_ldursh, d_ldursb, d_ldxr, d_stxr;
    assign d_ldur   = opcode[10]&opcode[9]&opcode[8]&opcode[7]&opcode[6]&no5&no4&no3&no2&opcode[1]&no0; // 11111000010
    assign d_stur   = opcode[10]&opcode[9]&opcode[8]&opcode[7]&opcode[6]&no5&no4&no3&no2&no1&no0; // 11111000000
    assign d_ldursw = opcode[10]&no9&opcode[8]&opcode[7]&opcode[6]&no5&no4&no3&opcode[2]&no1&no0; // 10111000100
    assign d_sturw  = opcode[10]&no9&opcode[8]&opcode[7]&opcode[6]&no5&no4&no3&no2&no1&no0; // 10111000000
    assign d_ldurh  = no10&opcode[9]&opcode[8]&opcode[7]&opcode[6]&no5&no4&no3&no2&opcode[1]&no0; // 01111000010
    assign d_sturh  = no10&opcode[9]&opcode[8]&opcode[7]&opcode[6]&no5&no4&no3&no2&no1&no0; // 01111000000
    assign d_ldurb  = no10&no9&opcode[8]&opcode[7]&opcode[6]&no5&no4&no3&no2&opcode[1]&no0; // 00111000010
    assign d_sturb  = no10&no9&opcode[8]&opcode[7]&opcode[6]&no5&no4&no3&no2&no1&no0; // 00111000000
    assign d_ldursh = no10&opcode[9]&opcode[8]&opcode[7]&opcode[6]&no5&no4&no3&opcode[2]&no1&no0; // 01111000100
    assign d_ldursb = no10&no9&opcode[8]&opcode[7]&opcode[6]&no5&no4&no3&opcode[2]&no1&no0; // 00111000100
    assign d_ldxr   = opcode[10]&opcode[9]&no8&no7&opcode[6]&no5&no4&no3&no2&opcode[1]&no0; // 11001000010
    assign d_stxr   = opcode[10]&opcode[9]&no8&no7&opcode[6]&no5&no4&no3&no2&no1&no0; // 11001000000

    // --- P-type pair load / store (full 11-bit) ---
    wire d_ldp, d_stp;
    assign d_ldp = opcode[10]&no9&opcode[8]&no7&opcode[6]&no5&no4&opcode[3]&no2&opcode[1]&no0; // 10101001010
    assign d_stp = opcode[10]&no9&opcode[8]&no7&opcode[6]&no5&no4&opcode[3]&no2&no1&no0; // 10101001000

    // --- I-type (10-bit: opcode[10:1], opcode[0] is the immediate MSB) ---
    wire d_addi, d_subi, d_addis, d_subis, d_andi, d_orri, d_eori;
    assign d_addi  = opcode[10]&no9&no8&opcode[7]&no6&no5&no4&opcode[3]&no2&no1; // 1001000100
    assign d_subi  = opcode[10]&opcode[9]&no8&opcode[7]&no6&no5&no4&opcode[3]&no2&no1; // 1101000100
    assign d_addis = opcode[10]&no9&opcode[8]&opcode[7]&no6&no5&no4&opcode[3]&no2&no1; // 1011000100
    assign d_subis = opcode[10]&opcode[9]&opcode[8]&opcode[7]&no6&no5&no4&opcode[3]&no2&no1; // 1111000100
    assign d_andi  = opcode[10]&no9&no8&opcode[7]&no6&no5&opcode[4]&no3&no2&no1; // 1001001000
    assign d_orri  = opcode[10]&no9&opcode[8]&opcode[7]&no6&no5&opcode[4]&no3&no2&no1; // 1011001000
    assign d_eori  = opcode[10]&opcode[9]&no8&opcode[7]&no6&no5&opcode[4]&no3&no2&no1; // 1101001000

    // --- IW-type (9-bit: opcode[10:2]) ---
    wire d_movz, d_movk;
    assign d_movz = opcode[10]&opcode[9]&no8&opcode[7]&no6&no5&opcode[4]&no3&opcode[2]; // 110100101
    assign d_movk = opcode[10]&opcode[9]&opcode[8]&opcode[7]&no6&no5&opcode[4]&no3&opcode[2]; // 111100101

    // --- CB-type (8-bit: opcode[10:3]) ---
    wire d_cbz, d_cbnz, d_bcond;
    assign d_cbz   = opcode[10]&no9&opcode[8]&opcode[7]&no6&opcode[5]&no4&no3; // 10110100
    assign d_cbnz  = opcode[10]&no9&opcode[8]&opcode[7]&no6&opcode[5]&no4&opcode[3]; // 10110101
    assign d_bcond = no10&opcode[9]&no8&opcode[7]&no6&opcode[5]&no4&no3; // 01010100

    // --- B-type (6-bit: opcode[10:5]) ---
    wire d_b, d_bl;
    assign d_b  = no10&no9&no8&opcode[7]&no6&opcode[5]; // 000101
    assign d_bl = opcode[10]&no9&no8&opcode[7]&no6&opcode[5]; // 100101


    // ===== Instruction groups =====
    wire is_rtype_alu, is_itype_alu;
    wire is_dfmt, is_pfmt, is_load, is_store, is_signed_load;

    assign is_rtype_alu = d_add | d_sub | d_adds | d_subs
                        | d_and | d_orr | d_eor | d_ands
                        | d_lsl | d_lsr | d_asr | d_ror
                        | d_bic | d_orn | d_eon
                        | d_mac | d_smulh | d_umulh | d_sdiv | d_udiv;

    assign is_itype_alu = d_addi | d_subi | d_addis | d_subis
                        | d_andi | d_orri | d_eori;

    // D-type format = the 12 single LDUR/STUR family ops (NOT the pair ops)
    assign is_dfmt = d_ldur | d_stur | d_ldursw | d_sturw | d_ldurh | d_sturh
                   | d_ldurb | d_sturb | d_ldursh | d_ldursb | d_ldxr | d_stxr;
    assign is_pfmt = d_ldp | d_stp;

    assign is_load  = d_ldur | d_ldursw | d_ldurh | d_ldurb | d_ldursh | d_ldursb
                    | d_ldxr | d_ldp;
    assign is_store = d_stur | d_sturw | d_sturh | d_sturb | d_stxr | d_stp;

    assign is_signed_load = d_ldursw | d_ldursh | d_ldursb;


    // ===== Output assembly =====
    
    // reg_write: any op that produces an architectural register result
    assign reg_write = is_rtype_alu | is_itype_alu | is_load
                     | d_movz | d_movk | d_bl | d_blr;

    // alu_src: immediate operand (I-type, D-type and P-type address offset)
    assign alu_src = is_itype_alu | is_load | is_store;

    // mem_to_reg: 00=ALU 01=Mem 10=PC+4 11=MUL-hi
    assign mem_to_reg[0] = is_load | d_smulh | d_umulh;     // 01 and 11
    assign mem_to_reg[1] = d_bl | d_blr | d_smulh | d_umulh; // 10 and 11

    assign mem_read  = is_load;
    assign mem_write = is_store;

    // mem_width: 000=64 001=32 010=16 011=8
    assign mem_width[0] = d_ldursw | d_sturw | d_ldurb | d_sturb | d_ldursb;
    assign mem_width[1] = d_ldurh  | d_sturh | d_ldursh | d_ldurb | d_sturb | d_ldursb;
    assign mem_width[2] = 1'b0;

    assign mem_sign_ext = is_signed_load;

    // flag_write: only the *S forms
    assign flag_write = d_adds | d_subs | d_ands | d_addis | d_subis;

    // branch_type: 001=B 010=BL 011=BR 100=BLR 101=CBZ 110=CBNZ 111=B.cond
    assign branch_type[0] = d_b  | d_br | d_cbz  | d_bcond;
    assign branch_type[1] = d_bl | d_br | d_cbnz | d_bcond;
    assign branch_type[2] = d_blr| d_cbz| d_cbnz | d_bcond;

    // alu_op_main: 00=ADD 01=SUB 10=R-type 11=I-type
    //   ADD (00) is the default -> used by loads/stores for address calculation.
    assign alu_op_main[0] = d_cbz | d_cbnz | is_itype_alu;     // SUB and I-type
    assign alu_op_main[1] = is_rtype_alu | is_itype_alu;       // R-type and I-type

    // mov_type: 01=MOVZ 10=MOVK
    assign mov_type[0] = d_movz;
    assign mov_type[1] = d_movk;

    assign pair_op = is_pfmt;

    // reg2_loc: 1 = take 2nd register from Rt[4:0] (stores, CBZ/CBNZ); else Rm[20:16]
    assign reg2_loc = is_store | d_cbz | d_cbnz;

    // imm_sel: 000=I 001=D 010=B 011=CB 100=IW 101=P
    assign imm_sel[0] = is_dfmt | d_cbz | d_cbnz | d_bcond | is_pfmt; // D, CB, P
    assign imm_sel[1] = d_b | d_bl | d_cbz | d_cbnz | d_bcond;        // B, CB
    assign imm_sel[2] = d_movz | d_movk | is_pfmt;                    // IW, P

endmodule
