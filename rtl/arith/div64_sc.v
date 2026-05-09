`timescale 1ns/1ps

// ========================================
//  64 bit Single-Cycle Restoring Divider
// ========================================
// 
//  Single cycle variant of the multi-cycle FSM divider.
// 
//  The pipelined design will use the multi-cycle version because
//  this module's propagation delay is the full 64-stage cascade.
// 
//  is_signed = 0 : unsigned division
//  is_signed = 1 : signed, truncate-toward-zero (matches ARM SDIV; 
//                  remainder takes the dividend's sign)
// 
//  divisor = 0 : quotient = 0, remainder = dividend
// 
//  INT_MIN / -1 : saturates to INT_MIN (falls out of the algorithm - the 
//                 unsigned magnitude 2^63 fits in the 64-bit datapath, and
//                 the q_sign correction never fires because both operand sign
//                 bits are 1)
// 
//  Algorithm - 64-stage cascaded restoring division:
//      Each stage k holds the running partial remainder R_k (64-bits)
//      Stage k:
//          R_pre = {R_k[62:0], dividend_abs[63-k]}      // shift-left, bring next dividend bit
//          T, c  = R_pre - divisor_abs                  // trial subtract via adder64
//          q_k   = c                                    // c=1 <=> R_pre >= divisor_abs
//          R_{k+1} = q_k ? T : R_pre                    // restore on negative
//      After 64 stages, q_0..q_63 form the quotient (MSB-first -> bit 63-k),
//      and R_64 is the remainder.
//  Sign handling:
//      dividend_abs = is_signed & dividend[63] ? -dividend : dividend
//      divisor_abs  = is_signed & divisor[63]  ? -divisor  : divisor
//      q_sign = is_signed & (dividend[63] ^ divisor[63])
//      r_sign = is_signed & dividend[63]    (remainder takes dividend's sign)
//      Output = sign-corrected magnitude, then overridden if divisor == 0.

module div64_sc(
    output [63:0] quotient,
    output [63:0] remainder,
    input [63:0] dividend,
    input [63:0] divisor,
    input is_signed
);
    // --- Operand Abs Values ---
    // -x = ~x + 1, computed via adder64 with cin=1

    wire [63:0] divd_inv, divd_neg;
    wire c_dd_nu; // Carry out

    not n_divd_00(divd_inv[0], dividend[0]);
    not n_divd_01(divd_inv[1], dividend[1]);
    not n_divd_02(divd_inv[2], dividend[2]);
    not n_divd_03(divd_inv[3], dividend[3]);
    not n_divd_04(divd_inv[4], dividend[4]);
    not n_divd_05(divd_inv[5], dividend[5]);
    not n_divd_06(divd_inv[6], dividend[6]);
    not n_divd_07(divd_inv[7], dividend[7]);
    not n_divd_08(divd_inv[8], dividend[8]);
    not n_divd_09(divd_inv[9], dividend[9]);
    not n_divd_10(divd_inv[10], dividend[10]);
    not n_divd_11(divd_inv[11], dividend[11]);
    not n_divd_12(divd_inv[12], dividend[12]);
    not n_divd_13(divd_inv[13], dividend[13]);
    not n_divd_14(divd_inv[14], dividend[14]);
    not n_divd_15(divd_inv[15], dividend[15]);
    not n_divd_16(divd_inv[16], dividend[16]);
    not n_divd_17(divd_inv[17], dividend[17]);
    not n_divd_18(divd_inv[18], dividend[18]);
    not n_divd_19(divd_inv[19], dividend[19]);
    not n_divd_20(divd_inv[20], dividend[20]);
    not n_divd_21(divd_inv[21], dividend[21]);
    not n_divd_22(divd_inv[22], dividend[22]);
    not n_divd_23(divd_inv[23], dividend[23]);
    not n_divd_24(divd_inv[24], dividend[24]);
    not n_divd_25(divd_inv[25], dividend[25]);
    not n_divd_26(divd_inv[26], dividend[26]);
    not n_divd_27(divd_inv[27], dividend[27]);
    not n_divd_28(divd_inv[28], dividend[28]);
    not n_divd_29(divd_inv[29], dividend[29]);
    not n_divd_30(divd_inv[30], dividend[30]);
    not n_divd_31(divd_inv[31], dividend[31]);
    not n_divd_32(divd_inv[32], dividend[32]);
    not n_divd_33(divd_inv[33], dividend[33]);
    not n_divd_34(divd_inv[34], dividend[34]);
    not n_divd_35(divd_inv[35], dividend[35]);
    not n_divd_36(divd_inv[36], dividend[36]);
    not n_divd_37(divd_inv[37], dividend[37]);
    not n_divd_38(divd_inv[38], dividend[38]);
    not n_divd_39(divd_inv[39], dividend[39]);
    not n_divd_40(divd_inv[40], dividend[40]);
    not n_divd_41(divd_inv[41], dividend[41]);
    not n_divd_42(divd_inv[42], dividend[42]);
    not n_divd_43(divd_inv[43], dividend[43]);
    not n_divd_44(divd_inv[44], dividend[44]);
    not n_divd_45(divd_inv[45], dividend[45]);
    not n_divd_46(divd_inv[46], dividend[46]);
    not n_divd_47(divd_inv[47], dividend[47]);
    not n_divd_48(divd_inv[48], dividend[48]);
    not n_divd_49(divd_inv[49], dividend[49]);
    not n_divd_50(divd_inv[50], dividend[50]);
    not n_divd_51(divd_inv[51], dividend[51]);
    not n_divd_52(divd_inv[52], dividend[52]);
    not n_divd_53(divd_inv[53], dividend[53]);
    not n_divd_54(divd_inv[54], dividend[54]);
    not n_divd_55(divd_inv[55], dividend[55]);
    not n_divd_56(divd_inv[56], dividend[56]);
    not n_divd_57(divd_inv[57], dividend[57]);
    not n_divd_58(divd_inv[58], dividend[58]);
    not n_divd_59(divd_inv[59], dividend[59]);
    not n_divd_60(divd_inv[60], dividend[60]);
    not n_divd_61(divd_inv[61], dividend[61]);
    not n_divd_62(divd_inv[62], dividend[62]);
    not n_divd_63(divd_inv[63], dividend[63]);

    adder64 u_neg_dividend(.sum(divd_neg), .cout(c_dd_nu), .a(divd_inv), .b(64'd0), .cin(1'b1));

    wire [63:0] divs_inv, divs_neg;
    wire c_dv_nu;
    
    not n_divs_00(divs_inv[0], divisor[0]);
    not n_divs_01(divs_inv[1], divisor[1]);
    not n_divs_02(divs_inv[2], divisor[2]);
    not n_divs_03(divs_inv[3], divisor[3]);
    not n_divs_04(divs_inv[4], divisor[4]);
    not n_divs_05(divs_inv[5], divisor[5]);
    not n_divs_06(divs_inv[6], divisor[6]);
    not n_divs_07(divs_inv[7], divisor[7]);
    not n_divs_08(divs_inv[8], divisor[8]);
    not n_divs_09(divs_inv[9], divisor[9]);
    not n_divs_10(divs_inv[10], divisor[10]);
    not n_divs_11(divs_inv[11], divisor[11]);
    not n_divs_12(divs_inv[12], divisor[12]);
    not n_divs_13(divs_inv[13], divisor[13]);
    not n_divs_14(divs_inv[14], divisor[14]);
    not n_divs_15(divs_inv[15], divisor[15]);
    not n_divs_16(divs_inv[16], divisor[16]);
    not n_divs_17(divs_inv[17], divisor[17]);
    not n_divs_18(divs_inv[18], divisor[18]);
    not n_divs_19(divs_inv[19], divisor[19]);
    not n_divs_20(divs_inv[20], divisor[20]);
    not n_divs_21(divs_inv[21], divisor[21]);
    not n_divs_22(divs_inv[22], divisor[22]);
    not n_divs_23(divs_inv[23], divisor[23]);
    not n_divs_24(divs_inv[24], divisor[24]);
    not n_divs_25(divs_inv[25], divisor[25]);
    not n_divs_26(divs_inv[26], divisor[26]);
    not n_divs_27(divs_inv[27], divisor[27]);
    not n_divs_28(divs_inv[28], divisor[28]);
    not n_divs_29(divs_inv[29], divisor[29]);
    not n_divs_30(divs_inv[30], divisor[30]);
    not n_divs_31(divs_inv[31], divisor[31]);
    not n_divs_32(divs_inv[32], divisor[32]);
    not n_divs_33(divs_inv[33], divisor[33]);
    not n_divs_34(divs_inv[34], divisor[34]);
    not n_divs_35(divs_inv[35], divisor[35]);
    not n_divs_36(divs_inv[36], divisor[36]);
    not n_divs_37(divs_inv[37], divisor[37]);
    not n_divs_38(divs_inv[38], divisor[38]);
    not n_divs_39(divs_inv[39], divisor[39]);
    not n_divs_40(divs_inv[40], divisor[40]);
    not n_divs_41(divs_inv[41], divisor[41]);
    not n_divs_42(divs_inv[42], divisor[42]);
    not n_divs_43(divs_inv[43], divisor[43]);
    not n_divs_44(divs_inv[44], divisor[44]);
    not n_divs_45(divs_inv[45], divisor[45]);
    not n_divs_46(divs_inv[46], divisor[46]);
    not n_divs_47(divs_inv[47], divisor[47]);
    not n_divs_48(divs_inv[48], divisor[48]);
    not n_divs_49(divs_inv[49], divisor[49]);
    not n_divs_50(divs_inv[50], divisor[50]);
    not n_divs_51(divs_inv[51], divisor[51]);
    not n_divs_52(divs_inv[52], divisor[52]);
    not n_divs_53(divs_inv[53], divisor[53]);
    not n_divs_54(divs_inv[54], divisor[54]);
    not n_divs_55(divs_inv[55], divisor[55]);
    not n_divs_56(divs_inv[56], divisor[56]);
    not n_divs_57(divs_inv[57], divisor[57]);
    not n_divs_58(divs_inv[58], divisor[58]);
    not n_divs_59(divs_inv[59], divisor[59]);
    not n_divs_60(divs_inv[60], divisor[60]);
    not n_divs_61(divs_inv[61], divisor[61]);
    not n_divs_62(divs_inv[62], divisor[62]);
    not n_divs_63(divs_inv[63], divisor[63]);
    
    adder64 u_neg_divisor(.sum(divs_neg), .cout(c_dv_nu), .a(divs_inv), .b(64'd0), .cin(1'b1));

    wire sel_neg_dd, sel_neg_dv;
    and a_dd(sel_neg_dd, is_signed, dividend[63]);
    and a_dv(sel_neg_dv, is_signed, divisor[63]);

    wire [63:0] dividend_abs, divisor_abs;
    mux2_1_64 u_dd_abs(
        .y(dividend_abs),
        .a(dividend),
        .b(divd_neg),
        .sel(sel_neg_dd)
    );
    mux2_1_64 u_dv_abs(
        .y(divisor_abs),
        .a(divisor),
        .b(divs_neg),
        .sel(sel_neg_dv)
    );

    // Pre-compute ~divisor_abs once; reused as the "b" port of every
    // subtract adder in the cascade (R - D = R + ~D + 1)
    wire [63:0] divisor_inv;
    
    not n_divs_abs_00(divisor_inv[0], divisor_abs[0]);
    not n_divs_abs_01(divisor_inv[1], divisor_abs[1]);
    not n_divs_abs_02(divisor_inv[2], divisor_abs[2]);
    not n_divs_abs_03(divisor_inv[3], divisor_abs[3]);
    not n_divs_abs_04(divisor_inv[4], divisor_abs[4]);
    not n_divs_abs_05(divisor_inv[5], divisor_abs[5]);
    not n_divs_abs_06(divisor_inv[6], divisor_abs[6]);
    not n_divs_abs_07(divisor_inv[7], divisor_abs[7]);
    not n_divs_abs_08(divisor_inv[8], divisor_abs[8]);
    not n_divs_abs_09(divisor_inv[9], divisor_abs[9]);
    not n_divs_abs_10(divisor_inv[10], divisor_abs[10]);
    not n_divs_abs_11(divisor_inv[11], divisor_abs[11]);
    not n_divs_abs_12(divisor_inv[12], divisor_abs[12]);
    not n_divs_abs_13(divisor_inv[13], divisor_abs[13]);
    not n_divs_abs_14(divisor_inv[14], divisor_abs[14]);
    not n_divs_abs_15(divisor_inv[15], divisor_abs[15]);
    not n_divs_abs_16(divisor_inv[16], divisor_abs[16]);
    not n_divs_abs_17(divisor_inv[17], divisor_abs[17]);
    not n_divs_abs_18(divisor_inv[18], divisor_abs[18]);
    not n_divs_abs_19(divisor_inv[19], divisor_abs[19]);
    not n_divs_abs_20(divisor_inv[20], divisor_abs[20]);
    not n_divs_abs_21(divisor_inv[21], divisor_abs[21]);
    not n_divs_abs_22(divisor_inv[22], divisor_abs[22]);
    not n_divs_abs_23(divisor_inv[23], divisor_abs[23]);
    not n_divs_abs_24(divisor_inv[24], divisor_abs[24]);
    not n_divs_abs_25(divisor_inv[25], divisor_abs[25]);
    not n_divs_abs_26(divisor_inv[26], divisor_abs[26]);
    not n_divs_abs_27(divisor_inv[27], divisor_abs[27]);
    not n_divs_abs_28(divisor_inv[28], divisor_abs[28]);
    not n_divs_abs_29(divisor_inv[29], divisor_abs[29]);
    not n_divs_abs_30(divisor_inv[30], divisor_abs[30]);
    not n_divs_abs_31(divisor_inv[31], divisor_abs[31]);
    not n_divs_abs_32(divisor_inv[32], divisor_abs[32]);
    not n_divs_abs_33(divisor_inv[33], divisor_abs[33]);
    not n_divs_abs_34(divisor_inv[34], divisor_abs[34]);
    not n_divs_abs_35(divisor_inv[35], divisor_abs[35]);
    not n_divs_abs_36(divisor_inv[36], divisor_abs[36]);
    not n_divs_abs_37(divisor_inv[37], divisor_abs[37]);
    not n_divs_abs_38(divisor_inv[38], divisor_abs[38]);
    not n_divs_abs_39(divisor_inv[39], divisor_abs[39]);
    not n_divs_abs_40(divisor_inv[40], divisor_abs[40]);
    not n_divs_abs_41(divisor_inv[41], divisor_abs[41]);
    not n_divs_abs_42(divisor_inv[42], divisor_abs[42]);
    not n_divs_abs_43(divisor_inv[43], divisor_abs[43]);
    not n_divs_abs_44(divisor_inv[44], divisor_abs[44]);
    not n_divs_abs_45(divisor_inv[45], divisor_abs[45]);
    not n_divs_abs_46(divisor_inv[46], divisor_abs[46]);
    not n_divs_abs_47(divisor_inv[47], divisor_abs[47]);
    not n_divs_abs_48(divisor_inv[48], divisor_abs[48]);
    not n_divs_abs_49(divisor_inv[49], divisor_abs[49]);
    not n_divs_abs_50(divisor_inv[50], divisor_abs[50]);
    not n_divs_abs_51(divisor_inv[51], divisor_abs[51]);
    not n_divs_abs_52(divisor_inv[52], divisor_abs[52]);
    not n_divs_abs_53(divisor_inv[53], divisor_abs[53]);
    not n_divs_abs_54(divisor_inv[54], divisor_abs[54]);
    not n_divs_abs_55(divisor_inv[55], divisor_abs[55]);
    not n_divs_abs_56(divisor_inv[56], divisor_abs[56]);
    not n_divs_abs_57(divisor_inv[57], divisor_abs[57]);
    not n_divs_abs_58(divisor_inv[58], divisor_abs[58]);
    not n_divs_abs_59(divisor_inv[59], divisor_abs[59]);
    not n_divs_abs_60(divisor_inv[60], divisor_abs[60]);
    not n_divs_abs_61(divisor_inv[61], divisor_abs[61]);
    not n_divs_abs_62(divisor_inv[62], divisor_abs[62]);
    not n_divs_abs_63(divisor_inv[63], divisor_abs[63]);

    // --- 64-stage restoring division cascade ---
    // R[k] is the partial remainder fed into stage k.  R[0] = 0, R[64] is the
    // final remainder.  q_b[k] is the quotient bit produced by stage k; stage 0
    // contributes the MSB (bit 63) of the quotient.

    // Could have used 'wire [63:0] R [64:0]', but I enjoy the manual labor  
    wire [63:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15;
    wire [63:0] R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R28, R29, R30, R31;
    wire [63:0] R32, R33, R34, R35, R36, R37, R38, R39, R40, R41, R42, R43, R44, R45, R46, R47;
    wire [63:0] R48, R49, R50, R51, R52, R53, R54, R55, R56, R57, R58, R59, R60, R61, R62, R63;
    wire [63:0] R64;

    wire [63:0] q_b;

    assign R0 = 64'd0;

    div_stage_sc s00(.R_out(R1), .q_bit(q_b[0]), .R_in(R0), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[63]));
    div_stage_sc s01(.R_out(R2), .q_bit(q_b[1]), .R_in(R1), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[62]));
    div_stage_sc s02(.R_out(R3), .q_bit(q_b[2]), .R_in(R2), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[61]));
    div_stage_sc s03(.R_out(R4), .q_bit(q_b[3]), .R_in(R3), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[60]));
    div_stage_sc s04(.R_out(R5), .q_bit(q_b[4]), .R_in(R4), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[59]));
    div_stage_sc s05(.R_out(R6), .q_bit(q_b[5]), .R_in(R5), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[58]));
    div_stage_sc s06(.R_out(R7), .q_bit(q_b[6]), .R_in(R6), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[57]));
    div_stage_sc s07(.R_out(R8), .q_bit(q_b[7]), .R_in(R7), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[56]));
    div_stage_sc s08(.R_out(R9), .q_bit(q_b[8]), .R_in(R8), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[55]));
    div_stage_sc s09(.R_out(R10), .q_bit(q_b[9]), .R_in(R9), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[54]));
    div_stage_sc s10(.R_out(R11), .q_bit(q_b[10]), .R_in(R10), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[53]));
    div_stage_sc s11(.R_out(R12), .q_bit(q_b[11]), .R_in(R11), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[52]));
    div_stage_sc s12(.R_out(R13), .q_bit(q_b[12]), .R_in(R12), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[51]));
    div_stage_sc s13(.R_out(R14), .q_bit(q_b[13]), .R_in(R13), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[50]));
    div_stage_sc s14(.R_out(R15), .q_bit(q_b[14]), .R_in(R14), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[49]));
    div_stage_sc s15(.R_out(R16), .q_bit(q_b[15]), .R_in(R15), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[48]));
    div_stage_sc s16(.R_out(R17), .q_bit(q_b[16]), .R_in(R16), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[47]));
    div_stage_sc s17(.R_out(R18), .q_bit(q_b[17]), .R_in(R17), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[46]));
    div_stage_sc s18(.R_out(R19), .q_bit(q_b[18]), .R_in(R18), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[45]));
    div_stage_sc s19(.R_out(R20), .q_bit(q_b[19]), .R_in(R19), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[44]));
    div_stage_sc s20(.R_out(R21), .q_bit(q_b[20]), .R_in(R20), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[43]));
    div_stage_sc s21(.R_out(R22), .q_bit(q_b[21]), .R_in(R21), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[42]));
    div_stage_sc s22(.R_out(R23), .q_bit(q_b[22]), .R_in(R22), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[41]));
    div_stage_sc s23(.R_out(R24), .q_bit(q_b[23]), .R_in(R23), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[40]));
    div_stage_sc s24(.R_out(R25), .q_bit(q_b[24]), .R_in(R24), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[39]));
    div_stage_sc s25(.R_out(R26), .q_bit(q_b[25]), .R_in(R25), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[38]));
    div_stage_sc s26(.R_out(R27), .q_bit(q_b[26]), .R_in(R26), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[37]));
    div_stage_sc s27(.R_out(R28), .q_bit(q_b[27]), .R_in(R27), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[36]));
    div_stage_sc s28(.R_out(R29), .q_bit(q_b[28]), .R_in(R28), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[35]));
    div_stage_sc s29(.R_out(R30), .q_bit(q_b[29]), .R_in(R29), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[34]));
    div_stage_sc s30(.R_out(R31), .q_bit(q_b[30]), .R_in(R30), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[33]));
    div_stage_sc s31(.R_out(R32), .q_bit(q_b[31]), .R_in(R31), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[32]));
    div_stage_sc s32(.R_out(R33), .q_bit(q_b[32]), .R_in(R32), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[31]));
    div_stage_sc s33(.R_out(R34), .q_bit(q_b[33]), .R_in(R33), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[30]));
    div_stage_sc s34(.R_out(R35), .q_bit(q_b[34]), .R_in(R34), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[29]));
    div_stage_sc s35(.R_out(R36), .q_bit(q_b[35]), .R_in(R35), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[28]));
    div_stage_sc s36(.R_out(R37), .q_bit(q_b[36]), .R_in(R36), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[27]));
    div_stage_sc s37(.R_out(R38), .q_bit(q_b[37]), .R_in(R37), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[26]));
    div_stage_sc s38(.R_out(R39), .q_bit(q_b[38]), .R_in(R38), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[25]));
    div_stage_sc s39(.R_out(R40), .q_bit(q_b[39]), .R_in(R39), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[24]));
    div_stage_sc s40(.R_out(R41), .q_bit(q_b[40]), .R_in(R40), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[23]));
    div_stage_sc s41(.R_out(R42), .q_bit(q_b[41]), .R_in(R41), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[22]));
    div_stage_sc s42(.R_out(R43), .q_bit(q_b[42]), .R_in(R42), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[21]));
    div_stage_sc s43(.R_out(R44), .q_bit(q_b[43]), .R_in(R43), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[20]));
    div_stage_sc s44(.R_out(R45), .q_bit(q_b[44]), .R_in(R44), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[19]));
    div_stage_sc s45(.R_out(R46), .q_bit(q_b[45]), .R_in(R45), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[18]));
    div_stage_sc s46(.R_out(R47), .q_bit(q_b[46]), .R_in(R46), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[17]));
    div_stage_sc s47(.R_out(R48), .q_bit(q_b[47]), .R_in(R47), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[16]));
    div_stage_sc s48(.R_out(R49), .q_bit(q_b[48]), .R_in(R48), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[15]));
    div_stage_sc s49(.R_out(R50), .q_bit(q_b[49]), .R_in(R49), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[14]));
    div_stage_sc s50(.R_out(R51), .q_bit(q_b[50]), .R_in(R50), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[13]));
    div_stage_sc s51(.R_out(R52), .q_bit(q_b[51]), .R_in(R51), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[12]));
    div_stage_sc s52(.R_out(R53), .q_bit(q_b[52]), .R_in(R52), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[11]));
    div_stage_sc s53(.R_out(R54), .q_bit(q_b[53]), .R_in(R53), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[10]));
    div_stage_sc s54(.R_out(R55), .q_bit(q_b[54]), .R_in(R54), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[9]));
    div_stage_sc s55(.R_out(R56), .q_bit(q_b[55]), .R_in(R55), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[8]));
    div_stage_sc s56(.R_out(R57), .q_bit(q_b[56]), .R_in(R56), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[7]));
    div_stage_sc s57(.R_out(R58), .q_bit(q_b[57]), .R_in(R57), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[6]));
    div_stage_sc s58(.R_out(R59), .q_bit(q_b[58]), .R_in(R58), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[5]));
    div_stage_sc s59(.R_out(R60), .q_bit(q_b[59]), .R_in(R59), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[4]));
    div_stage_sc s60(.R_out(R61), .q_bit(q_b[60]), .R_in(R60), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[3]));
    div_stage_sc s61(.R_out(R62), .q_bit(q_b[61]), .R_in(R61), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[2]));
    div_stage_sc s62(.R_out(R63), .q_bit(q_b[62]), .R_in(R62), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[1]));
    div_stage_sc s63(.R_out(R64), .q_bit(q_b[63]), .R_in(R63), .divisor_inv(divisor_inv), .dividend_bit(dividend_abs[0]));


    // --- Quotient Assembly ---
    // Stage 0 produced the MSB; stage 63 produced the LSB

    wire [63:0] quotient_abs;
    assign quotient_abs = {
        q_b[0], q_b[1], q_b[2], q_b[3], q_b[4], q_b[5], q_b[6], q_b[7],
        q_b[8], q_b[9], q_b[10], q_b[11], q_b[12], q_b[13], q_b[14], q_b[15],
        q_b[16], q_b[17], q_b[18], q_b[19], q_b[20], q_b[21], q_b[22], q_b[23],
        q_b[24], q_b[25], q_b[26], q_b[27], q_b[28], q_b[29], q_b[30], q_b[31],
        q_b[32], q_b[33], q_b[34], q_b[35], q_b[36], q_b[37], q_b[38], q_b[39],
        q_b[40], q_b[41], q_b[42], q_b[43], q_b[44], q_b[45], q_b[46], q_b[47],
        q_b[48], q_b[49], q_b[50], q_b[51], q_b[52], q_b[53], q_b[54], q_b[55],
        q_b[56], q_b[57], q_b[58], q_b[59], q_b[60], q_b[61], q_b[62], q_b[63]
    };

    wire [63:0] remainder_abs;
    assign remainder_abs = R64;
    
    // --- Output Sign Correction ---
    // For SDIV the quotient is negated when the sign bits of dividend and
    // divisor differ; the remainder takes the dividend's sign.

    wire q_sign, r_sign;
    wire x_d_s;
    // q_sign = is_signed & (dividend[63] ^ divisor[63])
    xor x_dd_ds(x_d_s, dividend[63], divisor[63]);
    and a_q_sign(q_sign, is_signed, x_d_s);

    // r_sign = is_signed & dividend[63]
    and a_r_sign(r_sign, is_signed, dividend[63]);

    wire [63:0] q_inv, q_neg;
    wire c_q_nu; // Carry out
    
    not n_q_00(q_inv[0], quotient_abs[0]);
    not n_q_01(q_inv[1], quotient_abs[1]);
    not n_q_02(q_inv[2], quotient_abs[2]);
    not n_q_03(q_inv[3], quotient_abs[3]);
    not n_q_04(q_inv[4], quotient_abs[4]);
    not n_q_05(q_inv[5], quotient_abs[5]);
    not n_q_06(q_inv[6], quotient_abs[6]);
    not n_q_07(q_inv[7], quotient_abs[7]);
    not n_q_08(q_inv[8], quotient_abs[8]);
    not n_q_09(q_inv[9], quotient_abs[9]);
    not n_q_10(q_inv[10], quotient_abs[10]);
    not n_q_11(q_inv[11], quotient_abs[11]);
    not n_q_12(q_inv[12], quotient_abs[12]);
    not n_q_13(q_inv[13], quotient_abs[13]);
    not n_q_14(q_inv[14], quotient_abs[14]);
    not n_q_15(q_inv[15], quotient_abs[15]);
    not n_q_16(q_inv[16], quotient_abs[16]);
    not n_q_17(q_inv[17], quotient_abs[17]);
    not n_q_18(q_inv[18], quotient_abs[18]);
    not n_q_19(q_inv[19], quotient_abs[19]);
    not n_q_20(q_inv[20], quotient_abs[20]);
    not n_q_21(q_inv[21], quotient_abs[21]);
    not n_q_22(q_inv[22], quotient_abs[22]);
    not n_q_23(q_inv[23], quotient_abs[23]);
    not n_q_24(q_inv[24], quotient_abs[24]);
    not n_q_25(q_inv[25], quotient_abs[25]);
    not n_q_26(q_inv[26], quotient_abs[26]);
    not n_q_27(q_inv[27], quotient_abs[27]);
    not n_q_28(q_inv[28], quotient_abs[28]);
    not n_q_29(q_inv[29], quotient_abs[29]);
    not n_q_30(q_inv[30], quotient_abs[30]);
    not n_q_31(q_inv[31], quotient_abs[31]);
    not n_q_32(q_inv[32], quotient_abs[32]);
    not n_q_33(q_inv[33], quotient_abs[33]);
    not n_q_34(q_inv[34], quotient_abs[34]);
    not n_q_35(q_inv[35], quotient_abs[35]);
    not n_q_36(q_inv[36], quotient_abs[36]);
    not n_q_37(q_inv[37], quotient_abs[37]);
    not n_q_38(q_inv[38], quotient_abs[38]);
    not n_q_39(q_inv[39], quotient_abs[39]);
    not n_q_40(q_inv[40], quotient_abs[40]);
    not n_q_41(q_inv[41], quotient_abs[41]);
    not n_q_42(q_inv[42], quotient_abs[42]);
    not n_q_43(q_inv[43], quotient_abs[43]);
    not n_q_44(q_inv[44], quotient_abs[44]);
    not n_q_45(q_inv[45], quotient_abs[45]);
    not n_q_46(q_inv[46], quotient_abs[46]);
    not n_q_47(q_inv[47], quotient_abs[47]);
    not n_q_48(q_inv[48], quotient_abs[48]);
    not n_q_49(q_inv[49], quotient_abs[49]);
    not n_q_50(q_inv[50], quotient_abs[50]);
    not n_q_51(q_inv[51], quotient_abs[51]);
    not n_q_52(q_inv[52], quotient_abs[52]);
    not n_q_53(q_inv[53], quotient_abs[53]);
    not n_q_54(q_inv[54], quotient_abs[54]);
    not n_q_55(q_inv[55], quotient_abs[55]);
    not n_q_56(q_inv[56], quotient_abs[56]);
    not n_q_57(q_inv[57], quotient_abs[57]);
    not n_q_58(q_inv[58], quotient_abs[58]);
    not n_q_59(q_inv[59], quotient_abs[59]);
    not n_q_60(q_inv[60], quotient_abs[60]);
    not n_q_61(q_inv[61], quotient_abs[61]);
    not n_q_62(q_inv[62], quotient_abs[62]);
    not n_q_63(q_inv[63], quotient_abs[63]);
    
    adder64 u_neg_q(
        .sum(q_neg),
        .cout(c_q_nu),
        .a(q_inv),
        .b(64'd0),
        .cin(1'b1)
    );
    
    wire [63:0] r_inv, r_neg;
    wire c_r_nu;

    not n_r_00(r_inv[0], remainder_abs[0]);
    not n_r_01(r_inv[1], remainder_abs[1]);
    not n_r_02(r_inv[2], remainder_abs[2]);
    not n_r_03(r_inv[3], remainder_abs[3]);
    not n_r_04(r_inv[4], remainder_abs[4]);
    not n_r_05(r_inv[5], remainder_abs[5]);
    not n_r_06(r_inv[6], remainder_abs[6]);
    not n_r_07(r_inv[7], remainder_abs[7]);
    not n_r_08(r_inv[8], remainder_abs[8]);
    not n_r_09(r_inv[9], remainder_abs[9]);
    not n_r_10(r_inv[10], remainder_abs[10]);
    not n_r_11(r_inv[11], remainder_abs[11]);
    not n_r_12(r_inv[12], remainder_abs[12]);
    not n_r_13(r_inv[13], remainder_abs[13]);
    not n_r_14(r_inv[14], remainder_abs[14]);
    not n_r_15(r_inv[15], remainder_abs[15]);
    not n_r_16(r_inv[16], remainder_abs[16]);
    not n_r_17(r_inv[17], remainder_abs[17]);
    not n_r_18(r_inv[18], remainder_abs[18]);
    not n_r_19(r_inv[19], remainder_abs[19]);
    not n_r_20(r_inv[20], remainder_abs[20]);
    not n_r_21(r_inv[21], remainder_abs[21]);
    not n_r_22(r_inv[22], remainder_abs[22]);
    not n_r_23(r_inv[23], remainder_abs[23]);
    not n_r_24(r_inv[24], remainder_abs[24]);
    not n_r_25(r_inv[25], remainder_abs[25]);
    not n_r_26(r_inv[26], remainder_abs[26]);
    not n_r_27(r_inv[27], remainder_abs[27]);
    not n_r_28(r_inv[28], remainder_abs[28]);
    not n_r_29(r_inv[29], remainder_abs[29]);
    not n_r_30(r_inv[30], remainder_abs[30]);
    not n_r_31(r_inv[31], remainder_abs[31]);
    not n_r_32(r_inv[32], remainder_abs[32]);
    not n_r_33(r_inv[33], remainder_abs[33]);
    not n_r_34(r_inv[34], remainder_abs[34]);
    not n_r_35(r_inv[35], remainder_abs[35]);
    not n_r_36(r_inv[36], remainder_abs[36]);
    not n_r_37(r_inv[37], remainder_abs[37]);
    not n_r_38(r_inv[38], remainder_abs[38]);
    not n_r_39(r_inv[39], remainder_abs[39]);
    not n_r_40(r_inv[40], remainder_abs[40]);
    not n_r_41(r_inv[41], remainder_abs[41]);
    not n_r_42(r_inv[42], remainder_abs[42]);
    not n_r_43(r_inv[43], remainder_abs[43]);
    not n_r_44(r_inv[44], remainder_abs[44]);
    not n_r_45(r_inv[45], remainder_abs[45]);
    not n_r_46(r_inv[46], remainder_abs[46]);
    not n_r_47(r_inv[47], remainder_abs[47]);
    not n_r_48(r_inv[48], remainder_abs[48]);
    not n_r_49(r_inv[49], remainder_abs[49]);
    not n_r_50(r_inv[50], remainder_abs[50]);
    not n_r_51(r_inv[51], remainder_abs[51]);
    not n_r_52(r_inv[52], remainder_abs[52]);
    not n_r_53(r_inv[53], remainder_abs[53]);
    not n_r_54(r_inv[54], remainder_abs[54]);
    not n_r_55(r_inv[55], remainder_abs[55]);
    not n_r_56(r_inv[56], remainder_abs[56]);
    not n_r_57(r_inv[57], remainder_abs[57]);
    not n_r_58(r_inv[58], remainder_abs[58]);
    not n_r_59(r_inv[59], remainder_abs[59]);
    not n_r_60(r_inv[60], remainder_abs[60]);
    not n_r_61(r_inv[61], remainder_abs[61]);
    not n_r_62(r_inv[62], remainder_abs[62]);
    not n_r_63(r_inv[63], remainder_abs[63]);
    
    adder64 u_neg_r(
        .sum(r_neg),
        .cout(c_r_nu),
        .a(r_inv),
        .b(64'd0),
        .cin(1'b1)
    ); 

    wire [63:0] q_signed_corr, r_signed_corr;
    mux2_1_64 u_q_sg(
        .y(q_signed_corr),
        .a(quotient_abs),
        .b(q_neg),
        .sel(q_sign)
    );
    mux2_1_64 u_r_sg(
        .y(r_signed_corr),
        .a(remainder_abs),
        .b(r_neg),
        .sel(r_sign)
    );
    
    // --- Divide by Zero Override ---
    // 64->32->16->8->4->2->1 OR-tree to detect divisor=0

    wire [31:0] dvor1;
    wire [15:0] dvor2;
    wire [7:0] dvor3;
    wire [3:0] dvor4;
    wire [1:0] dvor5;
    wire divisor_nz;
    
    or o_dvor1_00(dvor1[0], divisor[32], divisor[0]);
    or o_dvor1_01(dvor1[1], divisor[33], divisor[1]);
    or o_dvor1_02(dvor1[2], divisor[34], divisor[2]);
    or o_dvor1_03(dvor1[3], divisor[35], divisor[3]);
    or o_dvor1_04(dvor1[4], divisor[36], divisor[4]);
    or o_dvor1_05(dvor1[5], divisor[37], divisor[5]);
    or o_dvor1_06(dvor1[6], divisor[38], divisor[6]);
    or o_dvor1_07(dvor1[7], divisor[39], divisor[7]);
    or o_dvor1_08(dvor1[8], divisor[40], divisor[8]);
    or o_dvor1_09(dvor1[9], divisor[41], divisor[9]);
    or o_dvor1_10(dvor1[10], divisor[42], divisor[10]);
    or o_dvor1_11(dvor1[11], divisor[43], divisor[11]);
    or o_dvor1_12(dvor1[12], divisor[44], divisor[12]);
    or o_dvor1_13(dvor1[13], divisor[45], divisor[13]);
    or o_dvor1_14(dvor1[14], divisor[46], divisor[14]);
    or o_dvor1_15(dvor1[15], divisor[47], divisor[15]);
    or o_dvor1_16(dvor1[16], divisor[48], divisor[16]);
    or o_dvor1_17(dvor1[17], divisor[49], divisor[17]);
    or o_dvor1_18(dvor1[18], divisor[50], divisor[18]);
    or o_dvor1_19(dvor1[19], divisor[51], divisor[19]);
    or o_dvor1_20(dvor1[20], divisor[52], divisor[20]);
    or o_dvor1_21(dvor1[21], divisor[53], divisor[21]);
    or o_dvor1_22(dvor1[22], divisor[54], divisor[22]);
    or o_dvor1_23(dvor1[23], divisor[55], divisor[23]);
    or o_dvor1_24(dvor1[24], divisor[56], divisor[24]);
    or o_dvor1_25(dvor1[25], divisor[57], divisor[25]);
    or o_dvor1_26(dvor1[26], divisor[58], divisor[26]);
    or o_dvor1_27(dvor1[27], divisor[59], divisor[27]);
    or o_dvor1_28(dvor1[28], divisor[60], divisor[28]);
    or o_dvor1_29(dvor1[29], divisor[61], divisor[29]);
    or o_dvor1_30(dvor1[30], divisor[62], divisor[30]);
    or o_dvor1_31(dvor1[31], divisor[63], divisor[31]);

    or o_dvor2_00(dvor2[0], dvor1[16], dvor1[0]);
    or o_dvor2_01(dvor2[1], dvor1[17], dvor1[1]);
    or o_dvor2_02(dvor2[2], dvor1[18], dvor1[2]);
    or o_dvor2_03(dvor2[3], dvor1[19], dvor1[3]);
    or o_dvor2_04(dvor2[4], dvor1[20], dvor1[4]);
    or o_dvor2_05(dvor2[5], dvor1[21], dvor1[5]);
    or o_dvor2_06(dvor2[6], dvor1[22], dvor1[6]);
    or o_dvor2_07(dvor2[7], dvor1[23], dvor1[7]);
    or o_dvor2_08(dvor2[8], dvor1[24], dvor1[8]);
    or o_dvor2_09(dvor2[9], dvor1[25], dvor1[9]);
    or o_dvor2_10(dvor2[10], dvor1[26], dvor1[10]);
    or o_dvor2_11(dvor2[11], dvor1[27], dvor1[11]);
    or o_dvor2_12(dvor2[12], dvor1[28], dvor1[12]);
    or o_dvor2_13(dvor2[13], dvor1[29], dvor1[13]);
    or o_dvor2_14(dvor2[14], dvor1[30], dvor1[14]);
    or o_dvor2_15(dvor2[15], dvor1[31], dvor1[15]);

    or o_dvor3_00(dvor3[0], dvor2[8], dvor2[0]);
    or o_dvor3_01(dvor3[1], dvor2[9], dvor2[1]);
    or o_dvor3_02(dvor3[2], dvor2[10], dvor2[2]);
    or o_dvor3_03(dvor3[3], dvor2[11], dvor2[3]);
    or o_dvor3_04(dvor3[4], dvor2[12], dvor2[4]);
    or o_dvor3_05(dvor3[5], dvor2[13], dvor2[5]);
    or o_dvor3_06(dvor3[6], dvor2[14], dvor2[6]);
    or o_dvor3_07(dvor3[7], dvor2[15], dvor2[7]);

    or o_dvor4_00(dvor4[0], dvor3[4], dvor3[0]);
    or o_dvor4_01(dvor4[1], dvor3[5], dvor3[1]);
    or o_dvor4_02(dvor4[2], dvor3[6], dvor3[2]);
    or o_dvor4_03(dvor4[3], dvor3[7], dvor3[3]);

    or o_dvor5_00(dvor5[0], dvor4[2], dvor4[0]);
    or o_dvor5_01(dvor5[1], dvor4[3], dvor4[1]);

    or o_div_nz(divisor_nz, dvor5[1], dvor5[0]);

    wire is_dz;
    not n_is_dz(is_dz, divisor_nz);

    // is_dz = 0 -> pass the sign-corrected magnitude through
    // is_dz = 1 -> quotient = 0, remainder = dividend (raw, not abs)
    mux2_1_64 u_q_out(
        .y(quotient),
        .a(q_signed_corr),
        .b(64'd0),
        .sel(is_dz)
    );
    mux2_1_64 u_r_out(
        .y(remainder),
        .a(r_signed_corr),
        .b(dividend),
        .sel(is_dz)
    );
    

endmodule


// =================================
// Single restoring-division stage
// =================================
// 
// Shifts R_in left by 1 (concatenating the next dividend bit at the LSB),
// subtracts the divisor (R_pre + ~divisor + 1 -> carry-out = "no borrow"),
// and restores R_pre when the subtraction underflowed.

module div_stage_sc(
    output [63:0] R_out,
    output q_bit,
    input [63:0] R_in,
    input [63:0] divisor_inv,
    input dividend_bit
);
    wire [63:0] R_pre;
    assign R_pre = {R_in[62:0], dividend_bit};

    wire [63:0] T;
    wire c;
    adder64 u_sub(
        .sum(T),
        .cout(c),
        .a(R_pre),
        .b(divisor_inv),
        .cin(1'b1)
    );

    assign q_bit = c;

    mux2_1_64 u_mux(
        .y(R_out),
        .a(R_pre),
        .b(T),
        .sel(q_bit)
    );
endmodule