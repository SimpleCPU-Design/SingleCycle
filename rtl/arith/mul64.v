`timescale 1ns/1ps

// 64x64 -> 128 bit Multiplier - Radix-4 Booth Encoding + Wallace Tree

// Booth Encoder 
// Input: 3-bit group {b_h, b_m, b_l}
// Output: neg, x1, x2 (zero, when x1=x2=0 -> implicit)
module booth_enc (
    output neg,
    output x1,
    output x2,
    input b_h,
    input b_m,
    input b_l
);
    // x1 = b_m ^ b_l
    xor x_x1(x1, b_m, b_l);

    // x2 = ~(b_m ^ b_l) & (b_h ^ b_m)
    wire w_xnor_ml, w_xor_hm;
    xnor xn_ml(w_xnor_ml, b_m, b_l);
    xor x_hm(w_xor_hm, b_h, b_m);
    and a_x2(x2, w_xnor_ml, w_xor_hm);

    // neg = b_h & ~(b_m & b_l)
    wire w_nand_ml;
    nand na_ml(w_nand_ml, b_m, b_l);
    and a_neg(neg, w_nand_ml, b_h);
endmodule

// Booth Partial-Product 1 bit
// Generates single PP bit. For position j:
//      pp_bit = neg XOR ((x1 & a[j]) | (x2 & a[j-1]))
//
//  a_j     : a_ext[j]      (j=0..64; for j=65+, sign extension)
//  a_jm1   : a_ext[j-1]    (j=0 -> 0)
module booth_pp_bit (
    output pp_bit,
    input a_j,
    input a_jm1,
    input neg,
    input x1,
    input x2
);
    wire w_a1, w_a2, w_or;
    and a_a1(w_a1, x1, a_j);
    and a_a2(w_a2, x2, a_jm1);
    or o_12(w_or, w_a1, w_a2);
    xor x_pp(pp_bit, neg, w_or);
endmodule

// Booth PP 65 bit
module booth_pp_65 (
    output [64:0] pp,
    input [64:0] a_ext,
    input neg,
    input x1,
    input x2
);
    booth_pp_bit u_b0(
        .pp_bit(pp[0]),
        .a_j(a_ext[0]),
        .a_jm1(1'b0),
        .neg(neg),
        .x1(x1),
        .x2(x2)
    );
    booth_pp_bit u_brest_0(.pp_bit(pp[1]), .a_j(a_ext[1]), .a_jm1(a_ext[0]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_1(.pp_bit(pp[2]), .a_j(a_ext[2]), .a_jm1(a_ext[1]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_2(.pp_bit(pp[3]), .a_j(a_ext[3]), .a_jm1(a_ext[2]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_3(.pp_bit(pp[4]), .a_j(a_ext[4]), .a_jm1(a_ext[3]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_4(.pp_bit(pp[5]), .a_j(a_ext[5]), .a_jm1(a_ext[4]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_5(.pp_bit(pp[6]), .a_j(a_ext[6]), .a_jm1(a_ext[5]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_6(.pp_bit(pp[7]), .a_j(a_ext[7]), .a_jm1(a_ext[6]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_7(.pp_bit(pp[8]), .a_j(a_ext[8]), .a_jm1(a_ext[7]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_8(.pp_bit(pp[9]), .a_j(a_ext[9]), .a_jm1(a_ext[8]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_9(.pp_bit(pp[10]), .a_j(a_ext[10]), .a_jm1(a_ext[9]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_10(.pp_bit(pp[11]), .a_j(a_ext[11]), .a_jm1(a_ext[10]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_11(.pp_bit(pp[12]), .a_j(a_ext[12]), .a_jm1(a_ext[11]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_12(.pp_bit(pp[13]), .a_j(a_ext[13]), .a_jm1(a_ext[12]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_13(.pp_bit(pp[14]), .a_j(a_ext[14]), .a_jm1(a_ext[13]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_14(.pp_bit(pp[15]), .a_j(a_ext[15]), .a_jm1(a_ext[14]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_15(.pp_bit(pp[16]), .a_j(a_ext[16]), .a_jm1(a_ext[15]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_16(.pp_bit(pp[17]), .a_j(a_ext[17]), .a_jm1(a_ext[16]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_17(.pp_bit(pp[18]), .a_j(a_ext[18]), .a_jm1(a_ext[17]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_18(.pp_bit(pp[19]), .a_j(a_ext[19]), .a_jm1(a_ext[18]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_19(.pp_bit(pp[20]), .a_j(a_ext[20]), .a_jm1(a_ext[19]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_20(.pp_bit(pp[21]), .a_j(a_ext[21]), .a_jm1(a_ext[20]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_21(.pp_bit(pp[22]), .a_j(a_ext[22]), .a_jm1(a_ext[21]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_22(.pp_bit(pp[23]), .a_j(a_ext[23]), .a_jm1(a_ext[22]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_23(.pp_bit(pp[24]), .a_j(a_ext[24]), .a_jm1(a_ext[23]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_24(.pp_bit(pp[25]), .a_j(a_ext[25]), .a_jm1(a_ext[24]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_25(.pp_bit(pp[26]), .a_j(a_ext[26]), .a_jm1(a_ext[25]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_26(.pp_bit(pp[27]), .a_j(a_ext[27]), .a_jm1(a_ext[26]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_27(.pp_bit(pp[28]), .a_j(a_ext[28]), .a_jm1(a_ext[27]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_28(.pp_bit(pp[29]), .a_j(a_ext[29]), .a_jm1(a_ext[28]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_29(.pp_bit(pp[30]), .a_j(a_ext[30]), .a_jm1(a_ext[29]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_30(.pp_bit(pp[31]), .a_j(a_ext[31]), .a_jm1(a_ext[30]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_31(.pp_bit(pp[32]), .a_j(a_ext[32]), .a_jm1(a_ext[31]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_32(.pp_bit(pp[33]), .a_j(a_ext[33]), .a_jm1(a_ext[32]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_33(.pp_bit(pp[34]), .a_j(a_ext[34]), .a_jm1(a_ext[33]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_34(.pp_bit(pp[35]), .a_j(a_ext[35]), .a_jm1(a_ext[34]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_35(.pp_bit(pp[36]), .a_j(a_ext[36]), .a_jm1(a_ext[35]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_36(.pp_bit(pp[37]), .a_j(a_ext[37]), .a_jm1(a_ext[36]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_37(.pp_bit(pp[38]), .a_j(a_ext[38]), .a_jm1(a_ext[37]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_38(.pp_bit(pp[39]), .a_j(a_ext[39]), .a_jm1(a_ext[38]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_39(.pp_bit(pp[40]), .a_j(a_ext[40]), .a_jm1(a_ext[39]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_40(.pp_bit(pp[41]), .a_j(a_ext[41]), .a_jm1(a_ext[40]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_41(.pp_bit(pp[42]), .a_j(a_ext[42]), .a_jm1(a_ext[41]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_42(.pp_bit(pp[43]), .a_j(a_ext[43]), .a_jm1(a_ext[42]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_43(.pp_bit(pp[44]), .a_j(a_ext[44]), .a_jm1(a_ext[43]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_44(.pp_bit(pp[45]), .a_j(a_ext[45]), .a_jm1(a_ext[44]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_45(.pp_bit(pp[46]), .a_j(a_ext[46]), .a_jm1(a_ext[45]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_46(.pp_bit(pp[47]), .a_j(a_ext[47]), .a_jm1(a_ext[46]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_47(.pp_bit(pp[48]), .a_j(a_ext[48]), .a_jm1(a_ext[47]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_48(.pp_bit(pp[49]), .a_j(a_ext[49]), .a_jm1(a_ext[48]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_49(.pp_bit(pp[50]), .a_j(a_ext[50]), .a_jm1(a_ext[49]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_50(.pp_bit(pp[51]), .a_j(a_ext[51]), .a_jm1(a_ext[50]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_51(.pp_bit(pp[52]), .a_j(a_ext[52]), .a_jm1(a_ext[51]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_52(.pp_bit(pp[53]), .a_j(a_ext[53]), .a_jm1(a_ext[52]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_53(.pp_bit(pp[54]), .a_j(a_ext[54]), .a_jm1(a_ext[53]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_54(.pp_bit(pp[55]), .a_j(a_ext[55]), .a_jm1(a_ext[54]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_55(.pp_bit(pp[56]), .a_j(a_ext[56]), .a_jm1(a_ext[55]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_56(.pp_bit(pp[57]), .a_j(a_ext[57]), .a_jm1(a_ext[56]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_57(.pp_bit(pp[58]), .a_j(a_ext[58]), .a_jm1(a_ext[57]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_58(.pp_bit(pp[59]), .a_j(a_ext[59]), .a_jm1(a_ext[58]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_59(.pp_bit(pp[60]), .a_j(a_ext[60]), .a_jm1(a_ext[59]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_60(.pp_bit(pp[61]), .a_j(a_ext[61]), .a_jm1(a_ext[60]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_61(.pp_bit(pp[62]), .a_j(a_ext[62]), .a_jm1(a_ext[61]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_62(.pp_bit(pp[63]), .a_j(a_ext[63]), .a_jm1(a_ext[62]), .neg(neg), .x1(x1), .x2(x2));
    booth_pp_bit u_brest_63(.pp_bit(pp[64]), .a_j(a_ext[64]), .a_jm1(a_ext[63]), .neg(neg), .x1(x1), .x2(x2));
endmodule


// Carry-Save Adder (3:2 compressor) - 64 bit
module csa_128 (
    output [127:0] s,
    output [127:0] c,
    input [127:0] a,
    input [127:0] b,
    input [127:0] cin
);
    full_adder fa_0(.sum(s[0]), .cout(c[0]), .a(a[0]), .b(b[0]), .cin(cin[0]));
    full_adder fa_1(.sum(s[1]), .cout(c[1]), .a(a[1]), .b(b[1]), .cin(cin[1]));
    full_adder fa_2(.sum(s[2]), .cout(c[2]), .a(a[2]), .b(b[2]), .cin(cin[2]));
    full_adder fa_3(.sum(s[3]), .cout(c[3]), .a(a[3]), .b(b[3]), .cin(cin[3]));
    full_adder fa_4(.sum(s[4]), .cout(c[4]), .a(a[4]), .b(b[4]), .cin(cin[4]));
    full_adder fa_5(.sum(s[5]), .cout(c[5]), .a(a[5]), .b(b[5]), .cin(cin[5]));
    full_adder fa_6(.sum(s[6]), .cout(c[6]), .a(a[6]), .b(b[6]), .cin(cin[6]));
    full_adder fa_7(.sum(s[7]), .cout(c[7]), .a(a[7]), .b(b[7]), .cin(cin[7]));
    full_adder fa_8(.sum(s[8]), .cout(c[8]), .a(a[8]), .b(b[8]), .cin(cin[8]));
    full_adder fa_9(.sum(s[9]), .cout(c[9]), .a(a[9]), .b(b[9]), .cin(cin[9]));
    full_adder fa_10(.sum(s[10]), .cout(c[10]), .a(a[10]), .b(b[10]), .cin(cin[10]));
    full_adder fa_11(.sum(s[11]), .cout(c[11]), .a(a[11]), .b(b[11]), .cin(cin[11]));
    full_adder fa_12(.sum(s[12]), .cout(c[12]), .a(a[12]), .b(b[12]), .cin(cin[12]));
    full_adder fa_13(.sum(s[13]), .cout(c[13]), .a(a[13]), .b(b[13]), .cin(cin[13]));
    full_adder fa_14(.sum(s[14]), .cout(c[14]), .a(a[14]), .b(b[14]), .cin(cin[14]));
    full_adder fa_15(.sum(s[15]), .cout(c[15]), .a(a[15]), .b(b[15]), .cin(cin[15]));
    full_adder fa_16(.sum(s[16]), .cout(c[16]), .a(a[16]), .b(b[16]), .cin(cin[16]));
    full_adder fa_17(.sum(s[17]), .cout(c[17]), .a(a[17]), .b(b[17]), .cin(cin[17]));
    full_adder fa_18(.sum(s[18]), .cout(c[18]), .a(a[18]), .b(b[18]), .cin(cin[18]));
    full_adder fa_19(.sum(s[19]), .cout(c[19]), .a(a[19]), .b(b[19]), .cin(cin[19]));
    full_adder fa_20(.sum(s[20]), .cout(c[20]), .a(a[20]), .b(b[20]), .cin(cin[20]));
    full_adder fa_21(.sum(s[21]), .cout(c[21]), .a(a[21]), .b(b[21]), .cin(cin[21]));
    full_adder fa_22(.sum(s[22]), .cout(c[22]), .a(a[22]), .b(b[22]), .cin(cin[22]));
    full_adder fa_23(.sum(s[23]), .cout(c[23]), .a(a[23]), .b(b[23]), .cin(cin[23]));
    full_adder fa_24(.sum(s[24]), .cout(c[24]), .a(a[24]), .b(b[24]), .cin(cin[24]));
    full_adder fa_25(.sum(s[25]), .cout(c[25]), .a(a[25]), .b(b[25]), .cin(cin[25]));
    full_adder fa_26(.sum(s[26]), .cout(c[26]), .a(a[26]), .b(b[26]), .cin(cin[26]));
    full_adder fa_27(.sum(s[27]), .cout(c[27]), .a(a[27]), .b(b[27]), .cin(cin[27]));
    full_adder fa_28(.sum(s[28]), .cout(c[28]), .a(a[28]), .b(b[28]), .cin(cin[28]));
    full_adder fa_29(.sum(s[29]), .cout(c[29]), .a(a[29]), .b(b[29]), .cin(cin[29]));
    full_adder fa_30(.sum(s[30]), .cout(c[30]), .a(a[30]), .b(b[30]), .cin(cin[30]));
    full_adder fa_31(.sum(s[31]), .cout(c[31]), .a(a[31]), .b(b[31]), .cin(cin[31]));
    full_adder fa_32(.sum(s[32]), .cout(c[32]), .a(a[32]), .b(b[32]), .cin(cin[32]));
    full_adder fa_33(.sum(s[33]), .cout(c[33]), .a(a[33]), .b(b[33]), .cin(cin[33]));
    full_adder fa_34(.sum(s[34]), .cout(c[34]), .a(a[34]), .b(b[34]), .cin(cin[34]));
    full_adder fa_35(.sum(s[35]), .cout(c[35]), .a(a[35]), .b(b[35]), .cin(cin[35]));
    full_adder fa_36(.sum(s[36]), .cout(c[36]), .a(a[36]), .b(b[36]), .cin(cin[36]));
    full_adder fa_37(.sum(s[37]), .cout(c[37]), .a(a[37]), .b(b[37]), .cin(cin[37]));
    full_adder fa_38(.sum(s[38]), .cout(c[38]), .a(a[38]), .b(b[38]), .cin(cin[38]));
    full_adder fa_39(.sum(s[39]), .cout(c[39]), .a(a[39]), .b(b[39]), .cin(cin[39]));
    full_adder fa_40(.sum(s[40]), .cout(c[40]), .a(a[40]), .b(b[40]), .cin(cin[40]));
    full_adder fa_41(.sum(s[41]), .cout(c[41]), .a(a[41]), .b(b[41]), .cin(cin[41]));
    full_adder fa_42(.sum(s[42]), .cout(c[42]), .a(a[42]), .b(b[42]), .cin(cin[42]));
    full_adder fa_43(.sum(s[43]), .cout(c[43]), .a(a[43]), .b(b[43]), .cin(cin[43]));
    full_adder fa_44(.sum(s[44]), .cout(c[44]), .a(a[44]), .b(b[44]), .cin(cin[44]));
    full_adder fa_45(.sum(s[45]), .cout(c[45]), .a(a[45]), .b(b[45]), .cin(cin[45]));
    full_adder fa_46(.sum(s[46]), .cout(c[46]), .a(a[46]), .b(b[46]), .cin(cin[46]));
    full_adder fa_47(.sum(s[47]), .cout(c[47]), .a(a[47]), .b(b[47]), .cin(cin[47]));
    full_adder fa_48(.sum(s[48]), .cout(c[48]), .a(a[48]), .b(b[48]), .cin(cin[48]));
    full_adder fa_49(.sum(s[49]), .cout(c[49]), .a(a[49]), .b(b[49]), .cin(cin[49]));
    full_adder fa_50(.sum(s[50]), .cout(c[50]), .a(a[50]), .b(b[50]), .cin(cin[50]));
    full_adder fa_51(.sum(s[51]), .cout(c[51]), .a(a[51]), .b(b[51]), .cin(cin[51]));
    full_adder fa_52(.sum(s[52]), .cout(c[52]), .a(a[52]), .b(b[52]), .cin(cin[52]));
    full_adder fa_53(.sum(s[53]), .cout(c[53]), .a(a[53]), .b(b[53]), .cin(cin[53]));
    full_adder fa_54(.sum(s[54]), .cout(c[54]), .a(a[54]), .b(b[54]), .cin(cin[54]));
    full_adder fa_55(.sum(s[55]), .cout(c[55]), .a(a[55]), .b(b[55]), .cin(cin[55]));
    full_adder fa_56(.sum(s[56]), .cout(c[56]), .a(a[56]), .b(b[56]), .cin(cin[56]));
    full_adder fa_57(.sum(s[57]), .cout(c[57]), .a(a[57]), .b(b[57]), .cin(cin[57]));
    full_adder fa_58(.sum(s[58]), .cout(c[58]), .a(a[58]), .b(b[58]), .cin(cin[58]));
    full_adder fa_59(.sum(s[59]), .cout(c[59]), .a(a[59]), .b(b[59]), .cin(cin[59]));
    full_adder fa_60(.sum(s[60]), .cout(c[60]), .a(a[60]), .b(b[60]), .cin(cin[60]));
    full_adder fa_61(.sum(s[61]), .cout(c[61]), .a(a[61]), .b(b[61]), .cin(cin[61]));
    full_adder fa_62(.sum(s[62]), .cout(c[62]), .a(a[62]), .b(b[62]), .cin(cin[62]));
    full_adder fa_63(.sum(s[63]), .cout(c[63]), .a(a[63]), .b(b[63]), .cin(cin[63]));
    full_adder fa_64(.sum(s[64]), .cout(c[64]), .a(a[64]), .b(b[64]), .cin(cin[64]));
    full_adder fa_65(.sum(s[65]), .cout(c[65]), .a(a[65]), .b(b[65]), .cin(cin[65]));
    full_adder fa_66(.sum(s[66]), .cout(c[66]), .a(a[66]), .b(b[66]), .cin(cin[66]));
    full_adder fa_67(.sum(s[67]), .cout(c[67]), .a(a[67]), .b(b[67]), .cin(cin[67]));
    full_adder fa_68(.sum(s[68]), .cout(c[68]), .a(a[68]), .b(b[68]), .cin(cin[68]));
    full_adder fa_69(.sum(s[69]), .cout(c[69]), .a(a[69]), .b(b[69]), .cin(cin[69]));
    full_adder fa_70(.sum(s[70]), .cout(c[70]), .a(a[70]), .b(b[70]), .cin(cin[70]));
    full_adder fa_71(.sum(s[71]), .cout(c[71]), .a(a[71]), .b(b[71]), .cin(cin[71]));
    full_adder fa_72(.sum(s[72]), .cout(c[72]), .a(a[72]), .b(b[72]), .cin(cin[72]));
    full_adder fa_73(.sum(s[73]), .cout(c[73]), .a(a[73]), .b(b[73]), .cin(cin[73]));
    full_adder fa_74(.sum(s[74]), .cout(c[74]), .a(a[74]), .b(b[74]), .cin(cin[74]));
    full_adder fa_75(.sum(s[75]), .cout(c[75]), .a(a[75]), .b(b[75]), .cin(cin[75]));
    full_adder fa_76(.sum(s[76]), .cout(c[76]), .a(a[76]), .b(b[76]), .cin(cin[76]));
    full_adder fa_77(.sum(s[77]), .cout(c[77]), .a(a[77]), .b(b[77]), .cin(cin[77]));
    full_adder fa_78(.sum(s[78]), .cout(c[78]), .a(a[78]), .b(b[78]), .cin(cin[78]));
    full_adder fa_79(.sum(s[79]), .cout(c[79]), .a(a[79]), .b(b[79]), .cin(cin[79]));
    full_adder fa_80(.sum(s[80]), .cout(c[80]), .a(a[80]), .b(b[80]), .cin(cin[80]));
    full_adder fa_81(.sum(s[81]), .cout(c[81]), .a(a[81]), .b(b[81]), .cin(cin[81]));
    full_adder fa_82(.sum(s[82]), .cout(c[82]), .a(a[82]), .b(b[82]), .cin(cin[82]));
    full_adder fa_83(.sum(s[83]), .cout(c[83]), .a(a[83]), .b(b[83]), .cin(cin[83]));
    full_adder fa_84(.sum(s[84]), .cout(c[84]), .a(a[84]), .b(b[84]), .cin(cin[84]));
    full_adder fa_85(.sum(s[85]), .cout(c[85]), .a(a[85]), .b(b[85]), .cin(cin[85]));
    full_adder fa_86(.sum(s[86]), .cout(c[86]), .a(a[86]), .b(b[86]), .cin(cin[86]));
    full_adder fa_87(.sum(s[87]), .cout(c[87]), .a(a[87]), .b(b[87]), .cin(cin[87]));
    full_adder fa_88(.sum(s[88]), .cout(c[88]), .a(a[88]), .b(b[88]), .cin(cin[88]));
    full_adder fa_89(.sum(s[89]), .cout(c[89]), .a(a[89]), .b(b[89]), .cin(cin[89]));
    full_adder fa_90(.sum(s[90]), .cout(c[90]), .a(a[90]), .b(b[90]), .cin(cin[90]));
    full_adder fa_91(.sum(s[91]), .cout(c[91]), .a(a[91]), .b(b[91]), .cin(cin[91]));
    full_adder fa_92(.sum(s[92]), .cout(c[92]), .a(a[92]), .b(b[92]), .cin(cin[92]));
    full_adder fa_93(.sum(s[93]), .cout(c[93]), .a(a[93]), .b(b[93]), .cin(cin[93]));
    full_adder fa_94(.sum(s[94]), .cout(c[94]), .a(a[94]), .b(b[94]), .cin(cin[94]));
    full_adder fa_95(.sum(s[95]), .cout(c[95]), .a(a[95]), .b(b[95]), .cin(cin[95]));
    full_adder fa_96(.sum(s[96]), .cout(c[96]), .a(a[96]), .b(b[96]), .cin(cin[96]));
    full_adder fa_97(.sum(s[97]), .cout(c[97]), .a(a[97]), .b(b[97]), .cin(cin[97]));
    full_adder fa_98(.sum(s[98]), .cout(c[98]), .a(a[98]), .b(b[98]), .cin(cin[98]));
    full_adder fa_99(.sum(s[99]), .cout(c[99]), .a(a[99]), .b(b[99]), .cin(cin[99]));
    full_adder fa_100(.sum(s[100]), .cout(c[100]), .a(a[100]), .b(b[100]), .cin(cin[100]));
    full_adder fa_101(.sum(s[101]), .cout(c[101]), .a(a[101]), .b(b[101]), .cin(cin[101]));
    full_adder fa_102(.sum(s[102]), .cout(c[102]), .a(a[102]), .b(b[102]), .cin(cin[102]));
    full_adder fa_103(.sum(s[103]), .cout(c[103]), .a(a[103]), .b(b[103]), .cin(cin[103]));
    full_adder fa_104(.sum(s[104]), .cout(c[104]), .a(a[104]), .b(b[104]), .cin(cin[104]));
    full_adder fa_105(.sum(s[105]), .cout(c[105]), .a(a[105]), .b(b[105]), .cin(cin[105]));
    full_adder fa_106(.sum(s[106]), .cout(c[106]), .a(a[106]), .b(b[106]), .cin(cin[106]));
    full_adder fa_107(.sum(s[107]), .cout(c[107]), .a(a[107]), .b(b[107]), .cin(cin[107]));
    full_adder fa_108(.sum(s[108]), .cout(c[108]), .a(a[108]), .b(b[108]), .cin(cin[108]));
    full_adder fa_109(.sum(s[109]), .cout(c[109]), .a(a[109]), .b(b[109]), .cin(cin[109]));
    full_adder fa_110(.sum(s[110]), .cout(c[110]), .a(a[110]), .b(b[110]), .cin(cin[110]));
    full_adder fa_111(.sum(s[111]), .cout(c[111]), .a(a[111]), .b(b[111]), .cin(cin[111]));
    full_adder fa_112(.sum(s[112]), .cout(c[112]), .a(a[112]), .b(b[112]), .cin(cin[112]));
    full_adder fa_113(.sum(s[113]), .cout(c[113]), .a(a[113]), .b(b[113]), .cin(cin[113]));
    full_adder fa_114(.sum(s[114]), .cout(c[114]), .a(a[114]), .b(b[114]), .cin(cin[114]));
    full_adder fa_115(.sum(s[115]), .cout(c[115]), .a(a[115]), .b(b[115]), .cin(cin[115]));
    full_adder fa_116(.sum(s[116]), .cout(c[116]), .a(a[116]), .b(b[116]), .cin(cin[116]));
    full_adder fa_117(.sum(s[117]), .cout(c[117]), .a(a[117]), .b(b[117]), .cin(cin[117]));
    full_adder fa_118(.sum(s[118]), .cout(c[118]), .a(a[118]), .b(b[118]), .cin(cin[118]));
    full_adder fa_119(.sum(s[119]), .cout(c[119]), .a(a[119]), .b(b[119]), .cin(cin[119]));
    full_adder fa_120(.sum(s[120]), .cout(c[120]), .a(a[120]), .b(b[120]), .cin(cin[120]));
    full_adder fa_121(.sum(s[121]), .cout(c[121]), .a(a[121]), .b(b[121]), .cin(cin[121]));
    full_adder fa_122(.sum(s[122]), .cout(c[122]), .a(a[122]), .b(b[122]), .cin(cin[122]));
    full_adder fa_123(.sum(s[123]), .cout(c[123]), .a(a[123]), .b(b[123]), .cin(cin[123]));
    full_adder fa_124(.sum(s[124]), .cout(c[124]), .a(a[124]), .b(b[124]), .cin(cin[124]));
    full_adder fa_125(.sum(s[125]), .cout(c[125]), .a(a[125]), .b(b[125]), .cin(cin[125]));
    full_adder fa_126(.sum(s[126]), .cout(c[126]), .a(a[126]), .b(b[126]), .cin(cin[126]));
    full_adder fa_127(.sum(s[127]), .cout(c[127]), .a(a[127]), .b(b[127]), .cin(cin[127]));
endmodule

// Top Module: mul64
module mul64 (
    output [127:0] product,
    input [63:0] a,
    input [63:0] b,
    input is_signed         // 1: SMULH/MUL signed, 0: UMULH unsigned 
);
    // Operand extention
    // a -> a_ext[64:0] (64 bit + 1 sign/zero extension)
    // b -> b_ext[66:0] (64 bit + 2-bit ext + 1-bit bottom "0" -> b '[-1])
    //
    //   is_signed=1 → extra bit = a[63]/b[63]
    //   is_signed=0 → extra bit = 0
    wire a_ext_top, b_ext_top;
    and a_aet(a_ext_top, a[63], is_signed);
    and a_bet(b_ext_top, b[63], is_signed);

    wire [64:0] a_ext;
    wire [66:0] b_ext; 
    assign a_ext = {a_ext_top, a};
    assign b_ext = {b_ext_top, b_ext_top, b, 1'b0};


    // 33 Booth Encoder
    wire [32:0] bh_vec, bm_vec, bl_vec;
    
    // bh_vec[i] = b_ext[2i + 1 + 1]
    assign bh_vec = {
        b_ext[66], b_ext[64], b_ext[62], b_ext[60], b_ext[58], b_ext[56], b_ext[54], b_ext[52],
        b_ext[50], b_ext[48], b_ext[46], b_ext[44], b_ext[42], b_ext[40], b_ext[38], b_ext[36],
        b_ext[34], b_ext[32], b_ext[30], b_ext[28], b_ext[26], b_ext[24], b_ext[22], b_ext[20],
        b_ext[18], b_ext[16], b_ext[14], b_ext[12], b_ext[10], b_ext[8], b_ext[6], b_ext[4],
        b_ext[2]
    };

    // bm_vec[i] = b_ext[2i + 1]
    assign bm_vec = {
        b_ext[65], b_ext[63], b_ext[61], b_ext[59], b_ext[57], b_ext[55], b_ext[53], b_ext[51],
        b_ext[49], b_ext[47], b_ext[45], b_ext[43], b_ext[41], b_ext[39], b_ext[37], b_ext[35],
        b_ext[33], b_ext[31], b_ext[29], b_ext[27], b_ext[25], b_ext[23], b_ext[21], b_ext[19],
        b_ext[17], b_ext[15], b_ext[13], b_ext[11], b_ext[9], b_ext[7], b_ext[5], b_ext[3],
        b_ext[1]
    };

    // bl_vec[i] = b_ext[2i - 1 + 1]
    assign bl_vec = {
        b_ext[64], b_ext[62], b_ext[60], b_ext[58], b_ext[56], b_ext[54], b_ext[52], b_ext[50], 
        b_ext[48], b_ext[46], b_ext[44], b_ext[42], b_ext[40], b_ext[38], b_ext[36], b_ext[34], 
        b_ext[32], b_ext[30], b_ext[28], b_ext[26], b_ext[24], b_ext[22], b_ext[20], b_ext[18], 
        b_ext[16], b_ext[14], b_ext[12], b_ext[10], b_ext[8], b_ext[6], b_ext[4], b_ext[2],
        b_ext[0]
    };

    wire [32:0] neg_vec, x1_vec, x2_vec;
    booth_enc u_be_0(.neg(neg_vec[0]), .x1(x1_vec[0]), .x2(x2_vec[0]), .b_h(bh_vec[0]), .b_l(bl_vec[0]),.b_m(bm_vec[0]));
    booth_enc u_be_1(.neg(neg_vec[1]), .x1(x1_vec[1]), .x2(x2_vec[1]), .b_h(bh_vec[1]), .b_l(bl_vec[1]),.b_m(bm_vec[1]));
    booth_enc u_be_2(.neg(neg_vec[2]), .x1(x1_vec[2]), .x2(x2_vec[2]), .b_h(bh_vec[2]), .b_l(bl_vec[2]),.b_m(bm_vec[2]));
    booth_enc u_be_3(.neg(neg_vec[3]), .x1(x1_vec[3]), .x2(x2_vec[3]), .b_h(bh_vec[3]), .b_l(bl_vec[3]),.b_m(bm_vec[3]));
    booth_enc u_be_4(.neg(neg_vec[4]), .x1(x1_vec[4]), .x2(x2_vec[4]), .b_h(bh_vec[4]), .b_l(bl_vec[4]),.b_m(bm_vec[4]));
    booth_enc u_be_5(.neg(neg_vec[5]), .x1(x1_vec[5]), .x2(x2_vec[5]), .b_h(bh_vec[5]), .b_l(bl_vec[5]),.b_m(bm_vec[5]));
    booth_enc u_be_6(.neg(neg_vec[6]), .x1(x1_vec[6]), .x2(x2_vec[6]), .b_h(bh_vec[6]), .b_l(bl_vec[6]),.b_m(bm_vec[6]));
    booth_enc u_be_7(.neg(neg_vec[7]), .x1(x1_vec[7]), .x2(x2_vec[7]), .b_h(bh_vec[7]), .b_l(bl_vec[7]),.b_m(bm_vec[7]));
    booth_enc u_be_8(.neg(neg_vec[8]), .x1(x1_vec[8]), .x2(x2_vec[8]), .b_h(bh_vec[8]), .b_l(bl_vec[8]),.b_m(bm_vec[8]));
    booth_enc u_be_9(.neg(neg_vec[9]), .x1(x1_vec[9]), .x2(x2_vec[9]), .b_h(bh_vec[9]), .b_l(bl_vec[9]),.b_m(bm_vec[9]));
    booth_enc u_be_10(.neg(neg_vec[10]), .x1(x1_vec[10]), .x2(x2_vec[10]), .b_h(bh_vec[10]), .b_l(bl_vec[10]),.b_m(bm_vec[10]));
    booth_enc u_be_11(.neg(neg_vec[11]), .x1(x1_vec[11]), .x2(x2_vec[11]), .b_h(bh_vec[11]), .b_l(bl_vec[11]),.b_m(bm_vec[11]));
    booth_enc u_be_12(.neg(neg_vec[12]), .x1(x1_vec[12]), .x2(x2_vec[12]), .b_h(bh_vec[12]), .b_l(bl_vec[12]),.b_m(bm_vec[12]));
    booth_enc u_be_13(.neg(neg_vec[13]), .x1(x1_vec[13]), .x2(x2_vec[13]), .b_h(bh_vec[13]), .b_l(bl_vec[13]),.b_m(bm_vec[13]));
    booth_enc u_be_14(.neg(neg_vec[14]), .x1(x1_vec[14]), .x2(x2_vec[14]), .b_h(bh_vec[14]), .b_l(bl_vec[14]),.b_m(bm_vec[14]));
    booth_enc u_be_15(.neg(neg_vec[15]), .x1(x1_vec[15]), .x2(x2_vec[15]), .b_h(bh_vec[15]), .b_l(bl_vec[15]),.b_m(bm_vec[15]));
    booth_enc u_be_16(.neg(neg_vec[16]), .x1(x1_vec[16]), .x2(x2_vec[16]), .b_h(bh_vec[16]), .b_l(bl_vec[16]),.b_m(bm_vec[16]));
    booth_enc u_be_17(.neg(neg_vec[17]), .x1(x1_vec[17]), .x2(x2_vec[17]), .b_h(bh_vec[17]), .b_l(bl_vec[17]),.b_m(bm_vec[17]));
    booth_enc u_be_18(.neg(neg_vec[18]), .x1(x1_vec[18]), .x2(x2_vec[18]), .b_h(bh_vec[18]), .b_l(bl_vec[18]),.b_m(bm_vec[18]));
    booth_enc u_be_19(.neg(neg_vec[19]), .x1(x1_vec[19]), .x2(x2_vec[19]), .b_h(bh_vec[19]), .b_l(bl_vec[19]),.b_m(bm_vec[19]));
    booth_enc u_be_20(.neg(neg_vec[20]), .x1(x1_vec[20]), .x2(x2_vec[20]), .b_h(bh_vec[20]), .b_l(bl_vec[20]),.b_m(bm_vec[20]));
    booth_enc u_be_21(.neg(neg_vec[21]), .x1(x1_vec[21]), .x2(x2_vec[21]), .b_h(bh_vec[21]), .b_l(bl_vec[21]),.b_m(bm_vec[21]));
    booth_enc u_be_22(.neg(neg_vec[22]), .x1(x1_vec[22]), .x2(x2_vec[22]), .b_h(bh_vec[22]), .b_l(bl_vec[22]),.b_m(bm_vec[22]));
    booth_enc u_be_23(.neg(neg_vec[23]), .x1(x1_vec[23]), .x2(x2_vec[23]), .b_h(bh_vec[23]), .b_l(bl_vec[23]),.b_m(bm_vec[23]));
    booth_enc u_be_24(.neg(neg_vec[24]), .x1(x1_vec[24]), .x2(x2_vec[24]), .b_h(bh_vec[24]), .b_l(bl_vec[24]),.b_m(bm_vec[24]));
    booth_enc u_be_25(.neg(neg_vec[25]), .x1(x1_vec[25]), .x2(x2_vec[25]), .b_h(bh_vec[25]), .b_l(bl_vec[25]),.b_m(bm_vec[25]));
    booth_enc u_be_26(.neg(neg_vec[26]), .x1(x1_vec[26]), .x2(x2_vec[26]), .b_h(bh_vec[26]), .b_l(bl_vec[26]),.b_m(bm_vec[26]));
    booth_enc u_be_27(.neg(neg_vec[27]), .x1(x1_vec[27]), .x2(x2_vec[27]), .b_h(bh_vec[27]), .b_l(bl_vec[27]),.b_m(bm_vec[27]));
    booth_enc u_be_28(.neg(neg_vec[28]), .x1(x1_vec[28]), .x2(x2_vec[28]), .b_h(bh_vec[28]), .b_l(bl_vec[28]),.b_m(bm_vec[28]));
    booth_enc u_be_29(.neg(neg_vec[29]), .x1(x1_vec[29]), .x2(x2_vec[29]), .b_h(bh_vec[29]), .b_l(bl_vec[29]),.b_m(bm_vec[29]));
    booth_enc u_be_30(.neg(neg_vec[30]), .x1(x1_vec[30]), .x2(x2_vec[30]), .b_h(bh_vec[30]), .b_l(bl_vec[30]),.b_m(bm_vec[30]));
    booth_enc u_be_31(.neg(neg_vec[31]), .x1(x1_vec[31]), .x2(x2_vec[31]), .b_h(bh_vec[31]), .b_l(bl_vec[31]),.b_m(bm_vec[31]));
    booth_enc u_be_32(.neg(neg_vec[32]), .x1(x1_vec[32]), .x2(x2_vec[32]), .b_h(bh_vec[32]), .b_l(bl_vec[32]),.b_m(bm_vec[32]));

    // 33 Partial Product
    // pp_flat: Keep 33 PP in flat 33x65=2145-bit vector
    // pp for instance i pp_flat[(i+1)*65-1 : i*65]
    wire [33*65-1:0] pp_flat;
    booth_pp_65 u_pp_0(.pp(pp_flat[64:0]), .a_ext(a_ext), .neg(neg_vec[0]), .x1(x1_vec[0]), .x2(x2_vec[0]));
    booth_pp_65 u_pp_1(.pp(pp_flat[129:65]), .a_ext(a_ext), .neg(neg_vec[1]), .x1(x1_vec[1]), .x2(x2_vec[1]));
    booth_pp_65 u_pp_2(.pp(pp_flat[194:130]), .a_ext(a_ext), .neg(neg_vec[2]), .x1(x1_vec[2]), .x2(x2_vec[2]));
    booth_pp_65 u_pp_3(.pp(pp_flat[259:195]), .a_ext(a_ext), .neg(neg_vec[3]), .x1(x1_vec[3]), .x2(x2_vec[3]));
    booth_pp_65 u_pp_4(.pp(pp_flat[324:260]), .a_ext(a_ext), .neg(neg_vec[4]), .x1(x1_vec[4]), .x2(x2_vec[4]));
    booth_pp_65 u_pp_5(.pp(pp_flat[389:325]), .a_ext(a_ext), .neg(neg_vec[5]), .x1(x1_vec[5]), .x2(x2_vec[5]));
    booth_pp_65 u_pp_6(.pp(pp_flat[454:390]), .a_ext(a_ext), .neg(neg_vec[6]), .x1(x1_vec[6]), .x2(x2_vec[6]));
    booth_pp_65 u_pp_7(.pp(pp_flat[519:455]), .a_ext(a_ext), .neg(neg_vec[7]), .x1(x1_vec[7]), .x2(x2_vec[7]));
    booth_pp_65 u_pp_8(.pp(pp_flat[584:520]), .a_ext(a_ext), .neg(neg_vec[8]), .x1(x1_vec[8]), .x2(x2_vec[8]));
    booth_pp_65 u_pp_9(.pp(pp_flat[649:585]), .a_ext(a_ext), .neg(neg_vec[9]), .x1(x1_vec[9]), .x2(x2_vec[9]));
    booth_pp_65 u_pp_10(.pp(pp_flat[714:650]), .a_ext(a_ext), .neg(neg_vec[10]), .x1(x1_vec[10]), .x2(x2_vec[10]));
    booth_pp_65 u_pp_11(.pp(pp_flat[779:715]), .a_ext(a_ext), .neg(neg_vec[11]), .x1(x1_vec[11]), .x2(x2_vec[11]));
    booth_pp_65 u_pp_12(.pp(pp_flat[844:780]), .a_ext(a_ext), .neg(neg_vec[12]), .x1(x1_vec[12]), .x2(x2_vec[12]));
    booth_pp_65 u_pp_13(.pp(pp_flat[909:845]), .a_ext(a_ext), .neg(neg_vec[13]), .x1(x1_vec[13]), .x2(x2_vec[13]));
    booth_pp_65 u_pp_14(.pp(pp_flat[974:910]), .a_ext(a_ext), .neg(neg_vec[14]), .x1(x1_vec[14]), .x2(x2_vec[14]));
    booth_pp_65 u_pp_15(.pp(pp_flat[1039:975]), .a_ext(a_ext), .neg(neg_vec[15]), .x1(x1_vec[15]), .x2(x2_vec[15]));
    booth_pp_65 u_pp_16(.pp(pp_flat[1104:1040]), .a_ext(a_ext), .neg(neg_vec[16]), .x1(x1_vec[16]), .x2(x2_vec[16]));
    booth_pp_65 u_pp_17(.pp(pp_flat[1169:1105]), .a_ext(a_ext), .neg(neg_vec[17]), .x1(x1_vec[17]), .x2(x2_vec[17]));
    booth_pp_65 u_pp_18(.pp(pp_flat[1234:1170]), .a_ext(a_ext), .neg(neg_vec[18]), .x1(x1_vec[18]), .x2(x2_vec[18]));
    booth_pp_65 u_pp_19(.pp(pp_flat[1299:1235]), .a_ext(a_ext), .neg(neg_vec[19]), .x1(x1_vec[19]), .x2(x2_vec[19]));
    booth_pp_65 u_pp_20(.pp(pp_flat[1364:1300]), .a_ext(a_ext), .neg(neg_vec[20]), .x1(x1_vec[20]), .x2(x2_vec[20]));
    booth_pp_65 u_pp_21(.pp(pp_flat[1429:1365]), .a_ext(a_ext), .neg(neg_vec[21]), .x1(x1_vec[21]), .x2(x2_vec[21]));
    booth_pp_65 u_pp_22(.pp(pp_flat[1494:1430]), .a_ext(a_ext), .neg(neg_vec[22]), .x1(x1_vec[22]), .x2(x2_vec[22]));
    booth_pp_65 u_pp_23(.pp(pp_flat[1559:1495]), .a_ext(a_ext), .neg(neg_vec[23]), .x1(x1_vec[23]), .x2(x2_vec[23]));
    booth_pp_65 u_pp_24(.pp(pp_flat[1624:1560]), .a_ext(a_ext), .neg(neg_vec[24]), .x1(x1_vec[24]), .x2(x2_vec[24]));
    booth_pp_65 u_pp_25(.pp(pp_flat[1689:1625]), .a_ext(a_ext), .neg(neg_vec[25]), .x1(x1_vec[25]), .x2(x2_vec[25]));
    booth_pp_65 u_pp_26(.pp(pp_flat[1754:1690]), .a_ext(a_ext), .neg(neg_vec[26]), .x1(x1_vec[26]), .x2(x2_vec[26]));
    booth_pp_65 u_pp_27(.pp(pp_flat[1819:1755]), .a_ext(a_ext), .neg(neg_vec[27]), .x1(x1_vec[27]), .x2(x2_vec[27]));
    booth_pp_65 u_pp_28(.pp(pp_flat[1884:1820]), .a_ext(a_ext), .neg(neg_vec[28]), .x1(x1_vec[28]), .x2(x2_vec[28]));
    booth_pp_65 u_pp_29(.pp(pp_flat[1949:1885]), .a_ext(a_ext), .neg(neg_vec[29]), .x1(x1_vec[29]), .x2(x2_vec[29]));
    booth_pp_65 u_pp_30(.pp(pp_flat[2014:1950]), .a_ext(a_ext), .neg(neg_vec[30]), .x1(x1_vec[30]), .x2(x2_vec[30]));
    booth_pp_65 u_pp_31(.pp(pp_flat[2079:2015]), .a_ext(a_ext), .neg(neg_vec[31]), .x1(x1_vec[31]), .x2(x2_vec[31]));
    booth_pp_65 u_pp_32(.pp(pp_flat[2144:2080]), .a_ext(a_ext), .neg(neg_vec[32]), .x1(x1_vec[32]), .x2(x2_vec[32]));

    // 65-bit aliases to access PPs
    wire [64:0] pp00, pp01, pp02, pp03, pp04, pp05, pp06, pp07;
    wire [64:0] pp08, pp09, pp10, pp11, pp12, pp13, pp14, pp15;
    wire [64:0] pp16, pp17, pp18, pp19, pp20, pp21, pp22, pp23;
    wire [64:0] pp24, pp25, pp26, pp27, pp28, pp29, pp30, pp31;
    wire [64:0] pp32;

    assign pp00 = pp_flat[64:0];
    assign pp01 = pp_flat[129:65];
    assign pp02 = pp_flat[194:130];
    assign pp03 = pp_flat[259:195];
    assign pp04 = pp_flat[324:260];
    assign pp05 = pp_flat[389:325];
    assign pp06 = pp_flat[454:390];
    assign pp07 = pp_flat[519:455];
    assign pp08 = pp_flat[584:520];
    assign pp09 = pp_flat[649:585];
    assign pp10 = pp_flat[714:650];
    assign pp11 = pp_flat[779:715];
    assign pp12 = pp_flat[844:780];
    assign pp13 = pp_flat[909:845];
    assign pp14 = pp_flat[974:910];
    assign pp15 = pp_flat[1039:975];
    assign pp16 = pp_flat[1104:1040];
    assign pp17 = pp_flat[1169:1105];
    assign pp18 = pp_flat[1234:1170];
    assign pp19 = pp_flat[1299:1235];
    assign pp20 = pp_flat[1364:1300];
    assign pp21 = pp_flat[1429:1365];
    assign pp22 = pp_flat[1494:1430];
    assign pp23 = pp_flat[1559:1495];
    assign pp24 = pp_flat[1624:1560];
    assign pp25 = pp_flat[1689:1625];
    assign pp26 = pp_flat[1754:1690];
    assign pp27 = pp_flat[1819:1755];
    assign pp28 = pp_flat[1884:1820];
    assign pp29 = pp_flat[1949:1885];
    assign pp30 = pp_flat[2014:1950];
    assign pp31 = pp_flat[2079:2015];
    assign pp32 = pp_flat[2144:2080];

    // PP alignment
    //  pp_a_i (i=0..31) = { {(63-2i){sgn_vec[i]}}, pp_i, {(2i){1'b0}} }
    //  pp_a_32          = { pp_32[63:0], 64'b0 }
    //
    // sgn_vec[i] is the true sign of PP_i in 65+ bit view: when the Booth
    // recoded value is +/-2 and `a` is unsigned with a[63]=1, the 65-bit
    // PP overflows so pp_i[64] no longer reflects PP's actual sign. The
    // correct sign is (neg_i ^ a_ext_top), masked by (x1_i | x2_i) so that
    // a zero PP keeps a zero extension.
    wire [32:0] sgn_vec;
    assign sgn_vec = (x1_vec | x2_vec) & (neg_vec ^ {33{a_ext_top}});

    wire [127:0] pp_a00, pp_a01, pp_a02, pp_a03, pp_a04, pp_a05, pp_a06, pp_a07;
    wire [127:0] pp_a08, pp_a09, pp_a10, pp_a11, pp_a12, pp_a13, pp_a14, pp_a15;
    wire [127:0] pp_a16, pp_a17, pp_a18, pp_a19, pp_a20, pp_a21, pp_a22, pp_a23;
    wire [127:0] pp_a24, pp_a25, pp_a26, pp_a27, pp_a28, pp_a29, pp_a30, pp_a31;
    wire [127:0] pp_a32;

    assign pp_a00 = {{63{sgn_vec[ 0]}}, pp00};
    assign pp_a01 = {{61{sgn_vec[ 1]}}, pp01,  2'b0};
    assign pp_a02 = {{59{sgn_vec[ 2]}}, pp02,  4'b0};
    assign pp_a03 = {{57{sgn_vec[ 3]}}, pp03,  6'b0};
    assign pp_a04 = {{55{sgn_vec[ 4]}}, pp04,  8'b0};
    assign pp_a05 = {{53{sgn_vec[ 5]}}, pp05, 10'b0};
    assign pp_a06 = {{51{sgn_vec[ 6]}}, pp06, 12'b0};
    assign pp_a07 = {{49{sgn_vec[ 7]}}, pp07, 14'b0};
    assign pp_a08 = {{47{sgn_vec[ 8]}}, pp08, 16'b0};
    assign pp_a09 = {{45{sgn_vec[ 9]}}, pp09, 18'b0};
    assign pp_a10 = {{43{sgn_vec[10]}}, pp10, 20'b0};
    assign pp_a11 = {{41{sgn_vec[11]}}, pp11, 22'b0};
    assign pp_a12 = {{39{sgn_vec[12]}}, pp12, 24'b0};
    assign pp_a13 = {{37{sgn_vec[13]}}, pp13, 26'b0};
    assign pp_a14 = {{35{sgn_vec[14]}}, pp14, 28'b0};
    assign pp_a15 = {{33{sgn_vec[15]}}, pp15, 30'b0};
    assign pp_a16 = {{31{sgn_vec[16]}}, pp16, 32'b0};
    assign pp_a17 = {{29{sgn_vec[17]}}, pp17, 34'b0};
    assign pp_a18 = {{27{sgn_vec[18]}}, pp18, 36'b0};
    assign pp_a19 = {{25{sgn_vec[19]}}, pp19, 38'b0};
    assign pp_a20 = {{23{sgn_vec[20]}}, pp20, 40'b0};
    assign pp_a21 = {{21{sgn_vec[21]}}, pp21, 42'b0};
    assign pp_a22 = {{19{sgn_vec[22]}}, pp22, 44'b0};
    assign pp_a23 = {{17{sgn_vec[23]}}, pp23, 46'b0};
    assign pp_a24 = {{15{sgn_vec[24]}}, pp24, 48'b0};
    assign pp_a25 = {{13{sgn_vec[25]}}, pp25, 50'b0};
    assign pp_a26 = {{11{sgn_vec[26]}}, pp26, 52'b0};
    assign pp_a27 = {{ 9{sgn_vec[27]}}, pp27, 54'b0};
    assign pp_a28 = {{ 7{sgn_vec[28]}}, pp28, 56'b0};
    assign pp_a29 = {{ 5{sgn_vec[29]}}, pp29, 58'b0};
    assign pp_a30 = {{ 3{sgn_vec[30]}}, pp30, 60'b0};
    assign pp_a31 = {    sgn_vec[31],   pp31, 62'b0};
    assign pp_a32 = {pp32[63:0], 64'b0};

    // Negative number fix operand
    // Adds 1 to get 2's Complement
    wire [127:0] neg_corr;
    assign neg_corr[127:65] = 63'b0;
    assign neg_corr[64:0] = {
        neg_vec[32], 1'b0,
        neg_vec[31], 1'b0, neg_vec[30], 1'b0, neg_vec[29], 1'b0, neg_vec[28], 1'b0,
        neg_vec[27], 1'b0, neg_vec[26], 1'b0, neg_vec[25], 1'b0, neg_vec[24], 1'b0,
        neg_vec[23], 1'b0, neg_vec[22], 1'b0, neg_vec[21], 1'b0, neg_vec[20], 1'b0,
        neg_vec[19], 1'b0, neg_vec[18], 1'b0, neg_vec[17], 1'b0, neg_vec[16], 1'b0,
        neg_vec[15], 1'b0, neg_vec[14], 1'b0, neg_vec[13], 1'b0, neg_vec[12], 1'b0,
        neg_vec[11], 1'b0, neg_vec[10], 1'b0, neg_vec[9], 1'b0, neg_vec[8], 1'b0,
        neg_vec[7], 1'b0, neg_vec[6], 1'b0, neg_vec[5], 1'b0, neg_vec[4], 1'b0,
        neg_vec[3], 1'b0, neg_vec[2], 1'b0, neg_vec[1], 1'b0, neg_vec[0]
    };

    wire [127:0] wallace_sum;
    wire [127:0] wallace_carry;

    // ─── Wallace Level 1: 34 → 23 (11 CSA, 1 passthrough) ──────
    wire [127:0] l1s00, l1c00, l1c00_sh;
    csa_128 u_l1s00(.s(l1s00), .c(l1c00), .a(pp_a00), .b(pp_a01), .cin(pp_a02));
    assign l1c00_sh = {l1c00[126:0], 1'b0};
    wire [127:0] l1s01, l1c01, l1c01_sh;
    csa_128 u_l1s01(.s(l1s01), .c(l1c01), .a(pp_a03), .b(pp_a04), .cin(pp_a05));
    assign l1c01_sh = {l1c01[126:0], 1'b0};
    wire [127:0] l1s02, l1c02, l1c02_sh;
    csa_128 u_l1s02(.s(l1s02), .c(l1c02), .a(pp_a06), .b(pp_a07), .cin(pp_a08));
    assign l1c02_sh = {l1c02[126:0], 1'b0};
    wire [127:0] l1s03, l1c03, l1c03_sh;
    csa_128 u_l1s03(.s(l1s03), .c(l1c03), .a(pp_a09), .b(pp_a10), .cin(pp_a11));
    assign l1c03_sh = {l1c03[126:0], 1'b0};
    wire [127:0] l1s04, l1c04, l1c04_sh;
    csa_128 u_l1s04(.s(l1s04), .c(l1c04), .a(pp_a12), .b(pp_a13), .cin(pp_a14));
    assign l1c04_sh = {l1c04[126:0], 1'b0};
    wire [127:0] l1s05, l1c05, l1c05_sh;
    csa_128 u_l1s05(.s(l1s05), .c(l1c05), .a(pp_a15), .b(pp_a16), .cin(pp_a17));
    assign l1c05_sh = {l1c05[126:0], 1'b0};
    wire [127:0] l1s06, l1c06, l1c06_sh;
    csa_128 u_l1s06(.s(l1s06), .c(l1c06), .a(pp_a18), .b(pp_a19), .cin(pp_a20));
    assign l1c06_sh = {l1c06[126:0], 1'b0};
    wire [127:0] l1s07, l1c07, l1c07_sh;
    csa_128 u_l1s07(.s(l1s07), .c(l1c07), .a(pp_a21), .b(pp_a22), .cin(pp_a23));
    assign l1c07_sh = {l1c07[126:0], 1'b0};
    wire [127:0] l1s08, l1c08, l1c08_sh;
    csa_128 u_l1s08(.s(l1s08), .c(l1c08), .a(pp_a24), .b(pp_a25), .cin(pp_a26));
    assign l1c08_sh = {l1c08[126:0], 1'b0};
    wire [127:0] l1s09, l1c09, l1c09_sh;
    csa_128 u_l1s09(.s(l1s09), .c(l1c09), .a(pp_a27), .b(pp_a28), .cin(pp_a29));
    assign l1c09_sh = {l1c09[126:0], 1'b0};
    wire [127:0] l1s10, l1c10, l1c10_sh;
    csa_128 u_l1s10(.s(l1s10), .c(l1c10), .a(pp_a30), .b(pp_a31), .cin(pp_a32));
    assign l1c10_sh = {l1c10[126:0], 1'b0};
    // passthrough: neg_corr

    // ─── Wallace Level 2: 23 → 16 (7 CSA, 2 passthrough) ──────
    wire [127:0] l2s00, l2c00, l2c00_sh;
    csa_128 u_l2s00(.s(l2s00), .c(l2c00), .a(l1s00), .b(l1c00_sh), .cin(l1s01));
    assign l2c00_sh = {l2c00[126:0], 1'b0};
    wire [127:0] l2s01, l2c01, l2c01_sh;
    csa_128 u_l2s01(.s(l2s01), .c(l2c01), .a(l1c01_sh), .b(l1s02), .cin(l1c02_sh));
    assign l2c01_sh = {l2c01[126:0], 1'b0};
    wire [127:0] l2s02, l2c02, l2c02_sh;
    csa_128 u_l2s02(.s(l2s02), .c(l2c02), .a(l1s03), .b(l1c03_sh), .cin(l1s04));
    assign l2c02_sh = {l2c02[126:0], 1'b0};
    wire [127:0] l2s03, l2c03, l2c03_sh;
    csa_128 u_l2s03(.s(l2s03), .c(l2c03), .a(l1c04_sh), .b(l1s05), .cin(l1c05_sh));
    assign l2c03_sh = {l2c03[126:0], 1'b0};
    wire [127:0] l2s04, l2c04, l2c04_sh;
    csa_128 u_l2s04(.s(l2s04), .c(l2c04), .a(l1s06), .b(l1c06_sh), .cin(l1s07));
    assign l2c04_sh = {l2c04[126:0], 1'b0};
    wire [127:0] l2s05, l2c05, l2c05_sh;
    csa_128 u_l2s05(.s(l2s05), .c(l2c05), .a(l1c07_sh), .b(l1s08), .cin(l1c08_sh));
    assign l2c05_sh = {l2c05[126:0], 1'b0};
    wire [127:0] l2s06, l2c06, l2c06_sh;
    csa_128 u_l2s06(.s(l2s06), .c(l2c06), .a(l1s09), .b(l1c09_sh), .cin(l1s10));
    assign l2c06_sh = {l2c06[126:0], 1'b0};
    // passthrough: l1c10_sh, neg_corr

    // ─── Wallace Level 3: 16 → 11 (5 CSA, 1 passthrough) ──────
    wire [127:0] l3s00, l3c00, l3c00_sh;
    csa_128 u_l3s00(.s(l3s00), .c(l3c00), .a(l2s00), .b(l2c00_sh), .cin(l2s01));
    assign l3c00_sh = {l3c00[126:0], 1'b0};
    wire [127:0] l3s01, l3c01, l3c01_sh;
    csa_128 u_l3s01(.s(l3s01), .c(l3c01), .a(l2c01_sh), .b(l2s02), .cin(l2c02_sh));
    assign l3c01_sh = {l3c01[126:0], 1'b0};
    wire [127:0] l3s02, l3c02, l3c02_sh;
    csa_128 u_l3s02(.s(l3s02), .c(l3c02), .a(l2s03), .b(l2c03_sh), .cin(l2s04));
    assign l3c02_sh = {l3c02[126:0], 1'b0};
    wire [127:0] l3s03, l3c03, l3c03_sh;
    csa_128 u_l3s03(.s(l3s03), .c(l3c03), .a(l2c04_sh), .b(l2s05), .cin(l2c05_sh));
    assign l3c03_sh = {l3c03[126:0], 1'b0};
    wire [127:0] l3s04, l3c04, l3c04_sh;
    csa_128 u_l3s04(.s(l3s04), .c(l3c04), .a(l2s06), .b(l2c06_sh), .cin(l1c10_sh));
    assign l3c04_sh = {l3c04[126:0], 1'b0};
    // passthrough: neg_corr

    // ─── Wallace Level 4: 11 → 8 (3 CSA, 2 passthrough) ──────
    wire [127:0] l4s00, l4c00, l4c00_sh;
    csa_128 u_l4s00(.s(l4s00), .c(l4c00), .a(l3s00), .b(l3c00_sh), .cin(l3s01));
    assign l4c00_sh = {l4c00[126:0], 1'b0};
    wire [127:0] l4s01, l4c01, l4c01_sh;
    csa_128 u_l4s01(.s(l4s01), .c(l4c01), .a(l3c01_sh), .b(l3s02), .cin(l3c02_sh));
    assign l4c01_sh = {l4c01[126:0], 1'b0};
    wire [127:0] l4s02, l4c02, l4c02_sh;
    csa_128 u_l4s02(.s(l4s02), .c(l4c02), .a(l3s03), .b(l3c03_sh), .cin(l3s04));
    assign l4c02_sh = {l4c02[126:0], 1'b0};
    // passthrough: l3c04_sh, neg_corr

    // ─── Wallace Level 5: 8 → 6 (2 CSA, 2 passthrough) ──────
    wire [127:0] l5s00, l5c00, l5c00_sh;
    csa_128 u_l5s00(.s(l5s00), .c(l5c00), .a(l4s00), .b(l4c00_sh), .cin(l4s01));
    assign l5c00_sh = {l5c00[126:0], 1'b0};
    wire [127:0] l5s01, l5c01, l5c01_sh;
    csa_128 u_l5s01(.s(l5s01), .c(l5c01), .a(l4c01_sh), .b(l4s02), .cin(l4c02_sh));
    assign l5c01_sh = {l5c01[126:0], 1'b0};
    // passthrough: l3c04_sh, neg_corr

    // ─── Wallace Level 6: 6 → 4 (2 CSA, 0 passthrough) ──────
    wire [127:0] l6s00, l6c00, l6c00_sh;
    csa_128 u_l6s00(.s(l6s00), .c(l6c00), .a(l5s00), .b(l5c00_sh), .cin(l5s01));
    assign l6c00_sh = {l6c00[126:0], 1'b0};
    wire [127:0] l6s01, l6c01, l6c01_sh;
    csa_128 u_l6s01(.s(l6s01), .c(l6c01), .a(l5c01_sh), .b(l3c04_sh), .cin(neg_corr));
    assign l6c01_sh = {l6c01[126:0], 1'b0};

    // ─── Wallace Level 7: 4 → 3 (1 CSA, 1 passthrough) ──────
    wire [127:0] l7s00, l7c00, l7c00_sh;
    csa_128 u_l7s00(.s(l7s00), .c(l7c00), .a(l6s00), .b(l6c00_sh), .cin(l6s01));
    assign l7c00_sh = {l7c00[126:0], 1'b0};
    // passthrough: l6c01_sh

    // ─── Wallace Level 8: 3 → 2 (1 CSA, 0 passthrough) ──────
    wire [127:0] l8s00, l8c00, l8c00_sh;
    csa_128 u_l8s00(.s(l8s00), .c(l8c00), .a(l7s00), .b(l7c00_sh), .cin(l6c01_sh));
    assign l8c00_sh = {l8c00[126:0], 1'b0};

    assign wallace_sum   = l8s00;
    assign wallace_carry = l8c00_sh;

    // Final 128-bit addition
    wire        c_mid;
    wire [63:0] prod_lo, prod_hi;

    adder64 u_add_lo(
        .sum (prod_lo),
        .cout(c_mid),
        .a(wallace_sum[63:0]),
        .b(wallace_carry [63:0]),
        .cin (1'b0)
    );

    adder64 u_add_hi(
        .sum (prod_hi),
        .cout(),
        .a   (wallace_sum   [127:64]),
        .b   (wallace_carry [127:64]),
        .cin (c_mid)
    );

    assign product = {prod_hi, prod_lo};

endmodule