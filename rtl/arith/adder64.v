`timescale 1ns/1ps

// 64-bit Kogge-Stone Adder (KSA)

module adder64 (
    output [63:0] sum,
    output cout,
    input [63:0] a,
    input [63:0] b,
    input cin
);
    // Level 0 Preprocessing
    wire [63:0] g0, p0;
    and a_g0_0(g0[0], a[0], b[0]);
    and a_g0_1(g0[1], a[1], b[1]);
    and a_g0_2(g0[2], a[2], b[2]);
    and a_g0_3(g0[3], a[3], b[3]);
    and a_g0_4(g0[4], a[4], b[4]);
    and a_g0_5(g0[5], a[5], b[5]);
    and a_g0_6(g0[6], a[6], b[6]);
    and a_g0_7(g0[7], a[7], b[7]);
    and a_g0_8(g0[8], a[8], b[8]);
    and a_g0_9(g0[9], a[9], b[9]);
    and a_g0_10(g0[10], a[10], b[10]);
    and a_g0_11(g0[11], a[11], b[11]);
    and a_g0_12(g0[12], a[12], b[12]);
    and a_g0_13(g0[13], a[13], b[13]);
    and a_g0_14(g0[14], a[14], b[14]);
    and a_g0_15(g0[15], a[15], b[15]);
    and a_g0_16(g0[16], a[16], b[16]);
    and a_g0_17(g0[17], a[17], b[17]);
    and a_g0_18(g0[18], a[18], b[18]);
    and a_g0_19(g0[19], a[19], b[19]);
    and a_g0_20(g0[20], a[20], b[20]);
    and a_g0_21(g0[21], a[21], b[21]);
    and a_g0_22(g0[22], a[22], b[22]);
    and a_g0_23(g0[23], a[23], b[23]);
    and a_g0_24(g0[24], a[24], b[24]);
    and a_g0_25(g0[25], a[25], b[25]);
    and a_g0_26(g0[26], a[26], b[26]);
    and a_g0_27(g0[27], a[27], b[27]);
    and a_g0_28(g0[28], a[28], b[28]);
    and a_g0_29(g0[29], a[29], b[29]);
    and a_g0_30(g0[30], a[30], b[30]);
    and a_g0_31(g0[31], a[31], b[31]);
    and a_g0_32(g0[32], a[32], b[32]);
    and a_g0_33(g0[33], a[33], b[33]);
    and a_g0_34(g0[34], a[34], b[34]);
    and a_g0_35(g0[35], a[35], b[35]);
    and a_g0_36(g0[36], a[36], b[36]);
    and a_g0_37(g0[37], a[37], b[37]);
    and a_g0_38(g0[38], a[38], b[38]);
    and a_g0_39(g0[39], a[39], b[39]);
    and a_g0_40(g0[40], a[40], b[40]);
    and a_g0_41(g0[41], a[41], b[41]);
    and a_g0_42(g0[42], a[42], b[42]);
    and a_g0_43(g0[43], a[43], b[43]);
    and a_g0_44(g0[44], a[44], b[44]);
    and a_g0_45(g0[45], a[45], b[45]);
    and a_g0_46(g0[46], a[46], b[46]);
    and a_g0_47(g0[47], a[47], b[47]);
    and a_g0_48(g0[48], a[48], b[48]);
    and a_g0_49(g0[49], a[49], b[49]);
    and a_g0_50(g0[50], a[50], b[50]);
    and a_g0_51(g0[51], a[51], b[51]);
    and a_g0_52(g0[52], a[52], b[52]);
    and a_g0_53(g0[53], a[53], b[53]);
    and a_g0_54(g0[54], a[54], b[54]);
    and a_g0_55(g0[55], a[55], b[55]);
    and a_g0_56(g0[56], a[56], b[56]);
    and a_g0_57(g0[57], a[57], b[57]);
    and a_g0_58(g0[58], a[58], b[58]);
    and a_g0_59(g0[59], a[59], b[59]);
    and a_g0_60(g0[60], a[60], b[60]);
    and a_g0_61(g0[61], a[61], b[61]);
    and a_g0_62(g0[62], a[62], b[62]);
    and a_g0_63(g0[63], a[63], b[63]);

    xor x_p0_0(p0[0], a[0], b[0]);
    xor x_p0_1(p0[1], a[1], b[1]);
    xor x_p0_2(p0[2], a[2], b[2]);
    xor x_p0_3(p0[3], a[3], b[3]);
    xor x_p0_4(p0[4], a[4], b[4]);
    xor x_p0_5(p0[5], a[5], b[5]);
    xor x_p0_6(p0[6], a[6], b[6]);
    xor x_p0_7(p0[7], a[7], b[7]);
    xor x_p0_8(p0[8], a[8], b[8]);
    xor x_p0_9(p0[9], a[9], b[9]);
    xor x_p0_10(p0[10], a[10], b[10]);
    xor x_p0_11(p0[11], a[11], b[11]);
    xor x_p0_12(p0[12], a[12], b[12]);
    xor x_p0_13(p0[13], a[13], b[13]);
    xor x_p0_14(p0[14], a[14], b[14]);
    xor x_p0_15(p0[15], a[15], b[15]);
    xor x_p0_16(p0[16], a[16], b[16]);
    xor x_p0_17(p0[17], a[17], b[17]);
    xor x_p0_18(p0[18], a[18], b[18]);
    xor x_p0_19(p0[19], a[19], b[19]);
    xor x_p0_20(p0[20], a[20], b[20]);
    xor x_p0_21(p0[21], a[21], b[21]);
    xor x_p0_22(p0[22], a[22], b[22]);
    xor x_p0_23(p0[23], a[23], b[23]);
    xor x_p0_24(p0[24], a[24], b[24]);
    xor x_p0_25(p0[25], a[25], b[25]);
    xor x_p0_26(p0[26], a[26], b[26]);
    xor x_p0_27(p0[27], a[27], b[27]);
    xor x_p0_28(p0[28], a[28], b[28]);
    xor x_p0_29(p0[29], a[29], b[29]);
    xor x_p0_30(p0[30], a[30], b[30]);
    xor x_p0_31(p0[31], a[31], b[31]);
    xor x_p0_32(p0[32], a[32], b[32]);
    xor x_p0_33(p0[33], a[33], b[33]);
    xor x_p0_34(p0[34], a[34], b[34]);
    xor x_p0_35(p0[35], a[35], b[35]);
    xor x_p0_36(p0[36], a[36], b[36]);
    xor x_p0_37(p0[37], a[37], b[37]);
    xor x_p0_38(p0[38], a[38], b[38]);
    xor x_p0_39(p0[39], a[39], b[39]);
    xor x_p0_40(p0[40], a[40], b[40]);
    xor x_p0_41(p0[41], a[41], b[41]);
    xor x_p0_42(p0[42], a[42], b[42]);
    xor x_p0_43(p0[43], a[43], b[43]);
    xor x_p0_44(p0[44], a[44], b[44]);
    xor x_p0_45(p0[45], a[45], b[45]);
    xor x_p0_46(p0[46], a[46], b[46]);
    xor x_p0_47(p0[47], a[47], b[47]);
    xor x_p0_48(p0[48], a[48], b[48]);
    xor x_p0_49(p0[49], a[49], b[49]);
    xor x_p0_50(p0[50], a[50], b[50]);
    xor x_p0_51(p0[51], a[51], b[51]);
    xor x_p0_52(p0[52], a[52], b[52]);
    xor x_p0_53(p0[53], a[53], b[53]);
    xor x_p0_54(p0[54], a[54], b[54]);
    xor x_p0_55(p0[55], a[55], b[55]);
    xor x_p0_56(p0[56], a[56], b[56]);
    xor x_p0_57(p0[57], a[57], b[57]);
    xor x_p0_58(p0[58], a[58], b[58]);
    xor x_p0_59(p0[59], a[59], b[59]);
    xor x_p0_60(p0[60], a[60], b[60]);
    xor x_p0_61(p0[61], a[61], b[61]);
    xor x_p0_62(p0[62], a[62], b[62]);
    xor x_p0_63(p0[63], a[63], b[63]);

    // Level 1 -> distance = 2^(1-1)
    // Bit i (i >= 1): hi = i, lo = i - 1
    // g1[i] = g0[i] | (p0[i] & g0[i-1])
    // p1[i] = p0[i] & p0[i-1]
    wire [63:0] g1, p1;
    assign g1[0] = g0[0];
    assign p1[0] = p0[0];

    assign g1[1] = g0[1] | (p0[1] & g0[0]);
    assign p1[1] = p0[1] & p0[0];

    assign g1[2] = g0[2] | (p0[2] & g0[1]);
    assign p1[2] = p0[2] & p0[1];

    assign g1[3] = g0[3] | (p0[3] & g0[2]);
    assign p1[3] = p0[3] & p0[2];

    assign g1[4] = g0[4] | (p0[4] & g0[3]);
    assign p1[4] = p0[4] & p0[3];

    assign g1[5] = g0[5] | (p0[5] & g0[4]);
    assign p1[5] = p0[5] & p0[4];

    assign g1[6] = g0[6] | (p0[6] & g0[5]);
    assign p1[6] = p0[6] & p0[5];

    assign g1[7] = g0[7] | (p0[7] & g0[6]);
    assign p1[7] = p0[7] & p0[6];

    assign g1[8] = g0[8] | (p0[8] & g0[7]);
    assign p1[8] = p0[8] & p0[7];

    assign g1[9] = g0[9] | (p0[9] & g0[8]);
    assign p1[9] = p0[9] & p0[8];

    assign g1[10] = g0[10] | (p0[10] & g0[9]);
    assign p1[10] = p0[10] & p0[9];

    assign g1[11] = g0[11] | (p0[11] & g0[10]);
    assign p1[11] = p0[11] & p0[10];

    assign g1[12] = g0[12] | (p0[12] & g0[11]);
    assign p1[12] = p0[12] & p0[11];

    assign g1[13] = g0[13] | (p0[13] & g0[12]);
    assign p1[13] = p0[13] & p0[12];

    assign g1[14] = g0[14] | (p0[14] & g0[13]);
    assign p1[14] = p0[14] & p0[13];

    assign g1[15] = g0[15] | (p0[15] & g0[14]);
    assign p1[15] = p0[15] & p0[14];

    assign g1[16] = g0[16] | (p0[16] & g0[15]);
    assign p1[16] = p0[16] & p0[15];

    assign g1[17] = g0[17] | (p0[17] & g0[16]);
    assign p1[17] = p0[17] & p0[16];

    assign g1[18] = g0[18] | (p0[18] & g0[17]);
    assign p1[18] = p0[18] & p0[17];

    assign g1[19] = g0[19] | (p0[19] & g0[18]);
    assign p1[19] = p0[19] & p0[18];

    assign g1[20] = g0[20] | (p0[20] & g0[19]);
    assign p1[20] = p0[20] & p0[19];

    assign g1[21] = g0[21] | (p0[21] & g0[20]);
    assign p1[21] = p0[21] & p0[20];

    assign g1[22] = g0[22] | (p0[22] & g0[21]);
    assign p1[22] = p0[22] & p0[21];

    assign g1[23] = g0[23] | (p0[23] & g0[22]);
    assign p1[23] = p0[23] & p0[22];

    assign g1[24] = g0[24] | (p0[24] & g0[23]);
    assign p1[24] = p0[24] & p0[23];

    assign g1[25] = g0[25] | (p0[25] & g0[24]);
    assign p1[25] = p0[25] & p0[24];

    assign g1[26] = g0[26] | (p0[26] & g0[25]);
    assign p1[26] = p0[26] & p0[25];

    assign g1[27] = g0[27] | (p0[27] & g0[26]);
    assign p1[27] = p0[27] & p0[26];

    assign g1[28] = g0[28] | (p0[28] & g0[27]);
    assign p1[28] = p0[28] & p0[27];

    assign g1[29] = g0[29] | (p0[29] & g0[28]);
    assign p1[29] = p0[29] & p0[28];

    assign g1[30] = g0[30] | (p0[30] & g0[29]);
    assign p1[30] = p0[30] & p0[29];

    assign g1[31] = g0[31] | (p0[31] & g0[30]);
    assign p1[31] = p0[31] & p0[30];

    assign g1[32] = g0[32] | (p0[32] & g0[31]);
    assign p1[32] = p0[32] & p0[31];

    assign g1[33] = g0[33] | (p0[33] & g0[32]);
    assign p1[33] = p0[33] & p0[32];

    assign g1[34] = g0[34] | (p0[34] & g0[33]);
    assign p1[34] = p0[34] & p0[33];

    assign g1[35] = g0[35] | (p0[35] & g0[34]);
    assign p1[35] = p0[35] & p0[34];

    assign g1[36] = g0[36] | (p0[36] & g0[35]);
    assign p1[36] = p0[36] & p0[35];

    assign g1[37] = g0[37] | (p0[37] & g0[36]);
    assign p1[37] = p0[37] & p0[36];

    assign g1[38] = g0[38] | (p0[38] & g0[37]);
    assign p1[38] = p0[38] & p0[37];

    assign g1[39] = g0[39] | (p0[39] & g0[38]);
    assign p1[39] = p0[39] & p0[38];

    assign g1[40] = g0[40] | (p0[40] & g0[39]);
    assign p1[40] = p0[40] & p0[39];

    assign g1[41] = g0[41] | (p0[41] & g0[40]);
    assign p1[41] = p0[41] & p0[40];

    assign g1[42] = g0[42] | (p0[42] & g0[41]);
    assign p1[42] = p0[42] & p0[41];

    assign g1[43] = g0[43] | (p0[43] & g0[42]);
    assign p1[43] = p0[43] & p0[42];

    assign g1[44] = g0[44] | (p0[44] & g0[43]);
    assign p1[44] = p0[44] & p0[43];

    assign g1[45] = g0[45] | (p0[45] & g0[44]);
    assign p1[45] = p0[45] & p0[44];

    assign g1[46] = g0[46] | (p0[46] & g0[45]);
    assign p1[46] = p0[46] & p0[45];

    assign g1[47] = g0[47] | (p0[47] & g0[46]);
    assign p1[47] = p0[47] & p0[46];

    assign g1[48] = g0[48] | (p0[48] & g0[47]);
    assign p1[48] = p0[48] & p0[47];

    assign g1[49] = g0[49] | (p0[49] & g0[48]);
    assign p1[49] = p0[49] & p0[48];

    assign g1[50] = g0[50] | (p0[50] & g0[49]);
    assign p1[50] = p0[50] & p0[49];

    assign g1[51] = g0[51] | (p0[51] & g0[50]);
    assign p1[51] = p0[51] & p0[50];

    assign g1[52] = g0[52] | (p0[52] & g0[51]);
    assign p1[52] = p0[52] & p0[51];

    assign g1[53] = g0[53] | (p0[53] & g0[52]);
    assign p1[53] = p0[53] & p0[52];

    assign g1[54] = g0[54] | (p0[54] & g0[53]);
    assign p1[54] = p0[54] & p0[53];

    assign g1[55] = g0[55] | (p0[55] & g0[54]);
    assign p1[55] = p0[55] & p0[54];

    assign g1[56] = g0[56] | (p0[56] & g0[55]);
    assign p1[56] = p0[56] & p0[55];

    assign g1[57] = g0[57] | (p0[57] & g0[56]);
    assign p1[57] = p0[57] & p0[56];

    assign g1[58] = g0[58] | (p0[58] & g0[57]);
    assign p1[58] = p0[58] & p0[57];

    assign g1[59] = g0[59] | (p0[59] & g0[58]);
    assign p1[59] = p0[59] & p0[58];

    assign g1[60] = g0[60] | (p0[60] & g0[59]);
    assign p1[60] = p0[60] & p0[59];

    assign g1[61] = g0[61] | (p0[61] & g0[60]);
    assign p1[61] = p0[61] & p0[60];

    assign g1[62] = g0[62] | (p0[62] & g0[61]);
    assign p1[62] = p0[62] & p0[61];

    assign g1[63] = g0[63] | (p0[63] & g0[62]);
    assign p1[63] = p0[63] & p0[62];

    // Level 2 -> distance = 2^(2-1)
    // Bit i (i >= 2): hi = i, lo = i - 2
    // g2[i] = g1[i] | (p1[i] & g1[i-2])
    // p2[i] = p1[i] & p1[i-2]
    wire [63:0] g2, p2;
    assign g2[1] = g1[1];
    assign g2[0] = g1[0];
    assign p2[1] = p1[1];
    assign p2[0] = p1[0];

    assign g2[2] = g1[2] | (p1[2] & g1[0]);
    assign p2[2] = p1[2] & p1[0];

    assign g2[3] = g1[3] | (p1[3] & g1[1]);
    assign p2[3] = p1[3] & p1[1];

    assign g2[4] = g1[4] | (p1[4] & g1[2]);
    assign p2[4] = p1[4] & p1[2];

    assign g2[5] = g1[5] | (p1[5] & g1[3]);
    assign p2[5] = p1[5] & p1[3];

    assign g2[6] = g1[6] | (p1[6] & g1[4]);
    assign p2[6] = p1[6] & p1[4];

    assign g2[7] = g1[7] | (p1[7] & g1[5]);
    assign p2[7] = p1[7] & p1[5];

    assign g2[8] = g1[8] | (p1[8] & g1[6]);
    assign p2[8] = p1[8] & p1[6];

    assign g2[9] = g1[9] | (p1[9] & g1[7]);
    assign p2[9] = p1[9] & p1[7];

    assign g2[10] = g1[10] | (p1[10] & g1[8]);
    assign p2[10] = p1[10] & p1[8];

    assign g2[11] = g1[11] | (p1[11] & g1[9]);
    assign p2[11] = p1[11] & p1[9];

    assign g2[12] = g1[12] | (p1[12] & g1[10]);
    assign p2[12] = p1[12] & p1[10];

    assign g2[13] = g1[13] | (p1[13] & g1[11]);
    assign p2[13] = p1[13] & p1[11];

    assign g2[14] = g1[14] | (p1[14] & g1[12]);
    assign p2[14] = p1[14] & p1[12];

    assign g2[15] = g1[15] | (p1[15] & g1[13]);
    assign p2[15] = p1[15] & p1[13];

    assign g2[16] = g1[16] | (p1[16] & g1[14]);
    assign p2[16] = p1[16] & p1[14];

    assign g2[17] = g1[17] | (p1[17] & g1[15]);
    assign p2[17] = p1[17] & p1[15];

    assign g2[18] = g1[18] | (p1[18] & g1[16]);
    assign p2[18] = p1[18] & p1[16];

    assign g2[19] = g1[19] | (p1[19] & g1[17]);
    assign p2[19] = p1[19] & p1[17];

    assign g2[20] = g1[20] | (p1[20] & g1[18]);
    assign p2[20] = p1[20] & p1[18];
    
    assign g2[21] = g1[21] | (p1[21] & g1[19]);
    assign p2[21] = p1[21] & p1[19];
    
    assign g2[22] = g1[22] | (p1[22] & g1[20]);
    assign p2[22] = p1[22] & p1[20];
    
    assign g2[23] = g1[23] | (p1[23] & g1[21]);
    assign p2[23] = p1[23] & p1[21];

    assign g2[24] = g1[24] | (p1[24] & g1[22]);
    assign p2[24] = p1[24] & p1[22];
    
    assign g2[25] = g1[25] | (p1[25] & g1[23]);
    assign p2[25] = p1[25] & p1[23];

    assign g2[26] = g1[26] | (p1[26] & g1[24]);
    assign p2[26] = p1[26] & p1[24];
    
    assign g2[27] = g1[27] | (p1[27] & g1[25]);
    assign p2[27] = p1[27] & p1[25];

    assign g2[28] = g1[28] | (p1[28] & g1[26]);
    assign p2[28] = p1[28] & p1[26];
    
    assign g2[29] = g1[29] | (p1[29] & g1[27]);
    assign p2[29] = p1[29] & p1[27];

    assign g2[30] = g1[30] | (p1[30] & g1[28]);
    assign p2[30] = p1[30] & p1[28];
    
    assign g2[31] = g1[31] | (p1[31] & g1[29]);
    assign p2[31] = p1[31] & p1[29];

    assign g2[32] = g1[32] | (p1[32] & g1[30]);
    assign p2[32] = p1[32] & p1[30];
    
    assign g2[33] = g1[33] | (p1[33] & g1[31]);
    assign p2[33] = p1[33] & p1[31];
    
    assign g2[34] = g1[34] | (p1[34] & g1[32]);
    assign p2[34] = p1[34] & p1[32];
    
    assign g2[35] = g1[35] | (p1[35] & g1[33]);
    assign p2[35] = p1[35] & p1[33];

    assign g2[36] = g1[36] | (p1[36] & g1[34]);
    assign p2[36] = p1[36] & p1[34];
    
    assign g2[37] = g1[37] | (p1[37] & g1[35]);
    assign p2[37] = p1[37] & p1[35];

    assign g2[38] = g1[38] | (p1[38] & g1[36]);
    assign p2[38] = p1[38] & p1[36];
    
    assign g2[39] = g1[39] | (p1[39] & g1[37]);
    assign p2[39] = p1[39] & p1[37];
    
    assign g2[40] = g1[40] | (p1[40] & g1[38]);
    assign p2[40] = p1[40] & p1[38];

    assign g2[41] = g1[41] | (p1[41] & g1[39]);
    assign p2[41] = p1[41] & p1[39];

    assign g2[42] = g1[42] | (p1[42] & g1[40]);
    assign p2[42] = p1[42] & p1[40];

    assign g2[43] = g1[43] | (p1[43] & g1[41]);
    assign p2[43] = p1[43] & p1[41];

    assign g2[44] = g1[44] | (p1[44] & g1[42]);
    assign p2[44] = p1[44] & p1[42];
    
    assign g2[45] = g1[45] | (p1[45] & g1[43]);
    assign p2[45] = p1[45] & p1[43];

    assign g2[46] = g1[46] | (p1[46] & g1[44]);
    assign p2[46] = p1[46] & p1[44];

    assign g2[47] = g1[47] | (p1[47] & g1[45]);
    assign p2[47] = p1[47] & p1[45];
    
    assign g2[48] = g1[48] | (p1[48] & g1[46]);
    assign p2[48] = p1[48] & p1[46];

    assign g2[49] = g1[49] | (p1[49] & g1[47]);
    assign p2[49] = p1[49] & p1[47];

    assign g2[50] = g1[50] | (p1[50] & g1[48]);
    assign p2[50] = p1[50] & p1[48];

    assign g2[51] = g1[51] | (p1[51] & g1[49]);
    assign p2[51] = p1[51] & p1[49];

    assign g2[52] = g1[52] | (p1[52] & g1[50]);
    assign p2[52] = p1[52] & p1[50];

    assign g2[53] = g1[53] | (p1[53] & g1[51]);
    assign p2[53] = p1[53] & p1[51];

    assign g2[54] = g1[54] | (p1[54] & g1[52]);
    assign p2[54] = p1[54] & p1[52];

    assign g2[55] = g1[55] | (p1[55] & g1[53]);
    assign p2[55] = p1[55] & p1[53];
    
    assign g2[56] = g1[56] | (p1[56] & g1[54]);
    assign p2[56] = p1[56] & p1[54];

    assign g2[57] = g1[57] | (p1[57] & g1[55]);
    assign p2[57] = p1[57] & p1[55];
    
    assign g2[58] = g1[58] | (p1[58] & g1[56]);
    assign p2[58] = p1[58] & p1[56];

    assign g2[59] = g1[59] | (p1[59] & g1[57]);
    assign p2[59] = p1[59] & p1[57];

    assign g2[60] = g1[60] | (p1[60] & g1[58]);
    assign p2[60] = p1[60] & p1[58];

    assign g2[61] = g1[61] | (p1[61] & g1[59]);
    assign p2[61] = p1[61] & p1[59];

    assign g2[62] = g1[62] | (p1[62] & g1[60]);
    assign p2[62] = p1[62] & p1[60];

    assign g2[63] = g1[63] | (p1[63] & g1[61]);
    assign p2[63] = p1[63] & p1[61];

    // Level 3 -> distance = 2^(3-1)
    // Bit i (i >= 4): hi = i, lo = i - 4
    // g3[i] = g2[i] | (p2[i] & g2[i-4])
    // p3[i] = p2[i] & p2[i-4]
    wire [63:0] g3, p3;
    assign g3[0] = g2[0];
    assign g3[1] = g2[1];
    assign g3[2] = g2[2];
    assign g3[3] = g2[3];
    assign p3[0] = p2[0];
    assign p3[1] = p2[1];
    assign p3[2] = p2[2];
    assign p3[3] = p2[3];

    assign g3[4] = g2[4] | (p2[4] & g2[0]);
    assign p3[4] = p2[4] & p2[0];

    assign g3[5] = g2[5] | (p2[5] & g2[1]);
    assign p3[5] = p2[5] & p2[1];

    assign g3[6] = g2[6] | (p2[6] & g2[2]);
    assign p3[6] = p2[6] & p2[2];

    assign g3[7] = g2[7] | (p2[7] & g2[3]);
    assign p3[7] = p2[7] & p2[3];

    assign g3[8] = g2[8] | (p2[8] & g2[4]);
    assign p3[8] = p2[8] & p2[4];

    assign g3[9] = g2[9] | (p2[9] & g2[5]);
    assign p3[9] = p2[9] & p2[5];

    assign g3[10] = g2[10] | (p2[10] & g2[6]);
    assign p3[10] = p2[10] & p2[6];

    assign g3[11] = g2[11] | (p2[11] & g2[7]);
    assign p3[11] = p2[11] & p2[7];

    assign g3[12] = g2[12] | (p2[12] & g2[8]);
    assign p3[12] = p2[12] & p2[8];

    assign g3[13] = g2[13] | (p2[13] & g2[9]);
    assign p3[13] = p2[13] & p2[9];

    assign g3[14] = g2[14] | (p2[14] & g2[10]);
    assign p3[14] = p2[14] & p2[10];

    assign g3[15] = g2[15] | (p2[15] & g2[11]);
    assign p3[15] = p2[15] & p2[11];

    assign g3[16] = g2[16] | (p2[16] & g2[12]);
    assign p3[16] = p2[16] & p2[12];

    assign g3[17] = g2[17] | (p2[17] & g2[13]);
    assign p3[17] = p2[17] & p2[13];

    assign g3[18] = g2[18] | (p2[18] & g2[14]);
    assign p3[18] = p2[18] & p2[14];

    assign g3[19] = g2[19] | (p2[19] & g2[15]);
    assign p3[19] = p2[19] & p2[15];

    assign g3[20] = g2[20] | (p2[20] & g2[16]);
    assign p3[20] = p2[20] & p2[16];

    assign g3[21] = g2[21] | (p2[21] & g2[17]);
    assign p3[21] = p2[21] & p2[17];

    assign g3[22] = g2[22] | (p2[22] & g2[18]);
    assign p3[22] = p2[22] & p2[18];

    assign g3[23] = g2[23] | (p2[23] & g2[19]);
    assign p3[23] = p2[23] & p2[19];

    assign g3[24] = g2[24] | (p2[24] & g2[20]);
    assign p3[24] = p2[24] & p2[20];

    assign g3[25] = g2[25] | (p2[25] & g2[21]);
    assign p3[25] = p2[25] & p2[21];

    assign g3[26] = g2[26] | (p2[26] & g2[22]);
    assign p3[26] = p2[26] & p2[22];

    assign g3[27] = g2[27] | (p2[27] & g2[23]);
    assign p3[27] = p2[27] & p2[23];
    
    assign g3[28] = g2[28] | (p2[28] & g2[24]);
    assign p3[28] = p2[28] & p2[24];
    
    assign g3[29] = g2[29] | (p2[29] & g2[25]);
    assign p3[29] = p2[29] & p2[25];

    assign g3[30] = g2[30] | (p2[30] & g2[26]);
    assign p3[30] = p2[30] & p2[26];

    assign g3[31] = g2[31] | (p2[31] & g2[27]);
    assign p3[31] = p2[31] & p2[27];
    
    assign g3[32] = g2[32] | (p2[32] & g2[28]);
    assign p3[32] = p2[32] & p2[28];

    assign g3[33] = g2[33] | (p2[33] & g2[29]);
    assign p3[33] = p2[33] & p2[29];

    assign g3[34] = g2[34] | (p2[34] & g2[30]);
    assign p3[34] = p2[34] & p2[30];

    assign g3[35] = g2[35] | (p2[35] & g2[31]);
    assign p3[35] = p2[35] & p2[31];

    assign g3[36] = g2[36] | (p2[36] & g2[32]);
    assign p3[36] = p2[36] & p2[32];

    assign g3[37] = g2[37] | (p2[37] & g2[33]);
    assign p3[37] = p2[37] & p2[33];

    assign g3[38] = g2[38] | (p2[38] & g2[34]);
    assign p3[38] = p2[38] & p2[34];

    assign g3[39] = g2[39] | (p2[39] & g2[35]);
    assign p3[39] = p2[39] & p2[35];

    assign g3[40] = g2[40] | (p2[40] & g2[36]);
    assign p3[40] = p2[40] & p2[36];

    assign g3[41] = g2[41] | (p2[41] & g2[37]);
    assign p3[41] = p2[41] & p2[37];

    assign g3[42] = g2[42] | (p2[42] & g2[38]);
    assign p3[42] = p2[42] & p2[38];
    
    assign g3[43] = g2[43] | (p2[43] & g2[39]);
    assign p3[43] = p2[43] & p2[39];

    assign g3[44] = g2[44] | (p2[44] & g2[40]);
    assign p3[44] = p2[44] & p2[40];

    assign g3[45] = g2[45] | (p2[45] & g2[41]);
    assign p3[45] = p2[45] & p2[41];
    
    assign g3[46] = g2[46] | (p2[46] & g2[42]);
    assign p3[46] = p2[46] & p2[42];

    assign g3[47] = g2[47] | (p2[47] & g2[43]);
    assign p3[47] = p2[47] & p2[43];

    assign g3[48] = g2[48] | (p2[48] & g2[44]);
    assign p3[48] = p2[48] & p2[44];

    assign g3[49] = g2[49] | (p2[49] & g2[45]);
    assign p3[49] = p2[49] & p2[45];

    assign g3[50] = g2[50] | (p2[50] & g2[46]);
    assign p3[50] = p2[50] & p2[46];

    assign g3[51] = g2[51] | (p2[51] & g2[47]);
    assign p3[51] = p2[51] & p2[47];

    assign g3[52] = g2[52] | (p2[52] & g2[48]);
    assign p3[52] = p2[52] & p2[48];

    assign g3[53] = g2[53] | (p2[53] & g2[49]);
    assign p3[53] = p2[53] & p2[49];

    assign g3[54] = g2[54] | (p2[54] & g2[50]);
    assign p3[54] = p2[54] & p2[50];

    assign g3[55] = g2[55] | (p2[55] & g2[51]);
    assign p3[55] = p2[55] & p2[51];

    assign g3[56] = g2[56] | (p2[56] & g2[52]);
    assign p3[56] = p2[56] & p2[52];

    assign g3[57] = g2[57] | (p2[57] & g2[53]);
    assign p3[57] = p2[57] & p2[53];
    
    assign g3[58] = g2[58] | (p2[58] & g2[54]);
    assign p3[58] = p2[58] & p2[54];

    assign g3[59] = g2[59] | (p2[59] & g2[55]);
    assign p3[59] = p2[59] & p2[55];
    
    assign g3[60] = g2[60] | (p2[60] & g2[56]);
    assign p3[60] = p2[60] & p2[56];

    assign g3[61] = g2[61] | (p2[61] & g2[57]);
    assign p3[61] = p2[61] & p2[57];

    assign g3[62] = g2[62] | (p2[62] & g2[58]);
    assign p3[62] = p2[62] & p2[58];

    assign g3[63] = g2[63] | (p2[63] & g2[59]);
    assign p3[63] = p2[63] & p2[59];

    // Level 4 -> distance = 2^(4-1)
    // Bit i (i >= 8): hi = i, lo = i - 8
    // g4[i] = g3[i] | (p3[i] & g3[i-8])
    // p4[i] = p3[i] & p3[i-8]
    wire [63:0] g4, p4;
    assign g4[0] = g3[0];
    assign g4[1] = g3[1];
    assign g4[2] = g3[2];
    assign g4[3] = g3[3];
    assign g4[4] = g3[4];
    assign g4[5] = g3[5];
    assign g4[6] = g3[6];
    assign g4[7] = g3[7];
    assign p4[0] = p3[0];
    assign p4[1] = p3[1];
    assign p4[2] = p3[2];
    assign p4[3] = p3[3];
    assign p4[4] = p3[4];
    assign p4[5] = p3[5];
    assign p4[6] = p3[6];
    assign p4[7] = p3[7];

    assign g4[8] = g3[8] | (p3[8] & g3[0]);
    assign p4[8] = p3[8] & p3[0];

    assign g4[9] = g3[9] | (p3[9] & g3[1]);
    assign p4[9] = p3[9] & p3[1];

    assign g4[10] = g3[10] | (p3[10] & g3[2]);
    assign p4[10] = p3[10] & p3[2];

    assign g4[11] = g3[11] | (p3[11] & g3[3]);
    assign p4[11] = p3[11] & p3[3];

    assign g4[12] = g3[12] | (p3[12] & g3[4]);
    assign p4[12] = p3[12] & p3[4];

    assign g4[13] = g3[13] | (p3[13] & g3[5]);
    assign p4[13] = p3[13] & p3[5];

    assign g4[14] = g3[14] | (p3[14] & g3[6]);
    assign p4[14] = p3[14] & p3[6];
    
    assign g4[15] = g3[15] | (p3[15] & g3[7]);
    assign p4[15] = p3[15] & p3[7];
    
    assign g4[16] = g3[16] | (p3[16] & g3[8]);
    assign p4[16] = p3[16] & p3[8];

    assign g4[17] = g3[17] | (p3[17] & g3[9]);
    assign p4[17] = p3[17] & p3[9];

    assign g4[18] = g3[18] | (p3[18] & g3[10]);
    assign p4[18] = p3[18] & p3[10];

    assign g4[19] = g3[19] | (p3[19] & g3[11]);
    assign p4[19] = p3[19] & p3[11];

    assign g4[20] = g3[20] | (p3[20] & g3[12]);
    assign p4[20] = p3[20] & p3[12];

    assign g4[21] = g3[21] | (p3[21] & g3[13]);
    assign p4[21] = p3[21] & p3[13];

    assign g4[22] = g3[22] | (p3[22] & g3[14]);
    assign p4[22] = p3[22] & p3[14];

    assign g4[23] = g3[23] | (p3[23] & g3[15]);
    assign p4[23] = p3[23] & p3[15];

    assign g4[24] = g3[24] | (p3[24] & g3[16]);
    assign p4[24] = p3[24] & p3[16];

    assign g4[25] = g3[25] | (p3[25] & g3[17]);
    assign p4[25] = p3[25] & p3[17];

    assign g4[26] = g3[26] | (p3[26] & g3[18]);
    assign p4[26] = p3[26] & p3[18];

    assign g4[27] = g3[27] | (p3[27] & g3[19]);
    assign p4[27] = p3[27] & p3[19];

    assign g4[28] = g3[28] | (p3[28] & g3[20]);
    assign p4[28] = p3[28] & p3[20];

    assign g4[29] = g3[29] | (p3[29] & g3[21]);
    assign p4[29] = p3[29] & p3[21];

    assign g4[30] = g3[30] | (p3[30] & g3[22]);
    assign p4[30] = p3[30] & p3[22];

    assign g4[31] = g3[31] | (p3[31] & g3[23]);
    assign p4[31] = p3[31] & p3[23];

    assign g4[32] = g3[32] | (p3[32] & g3[24]);
    assign p4[32] = p3[32] & p3[24];

    assign g4[33] = g3[33] | (p3[33] & g3[25]);
    assign p4[33] = p3[33] & p3[25];

    assign g4[34] = g3[34] | (p3[34] & g3[26]);
    assign p4[34] = p3[34] & p3[26];

    assign g4[35] = g3[35] | (p3[35] & g3[27]);
    assign p4[35] = p3[35] & p3[27];

    assign g4[36] = g3[36] | (p3[36] & g3[28]);
    assign p4[36] = p3[36] & p3[28];

    assign g4[37] = g3[37] | (p3[37] & g3[29]);
    assign p4[37] = p3[37] & p3[29];

    assign g4[38] = g3[38] | (p3[38] & g3[30]);
    assign p4[38] = p3[38] & p3[30];

    assign g4[39] = g3[39] | (p3[39] & g3[31]);
    assign p4[39] = p3[39] & p3[31];

    assign g4[40] = g3[40] | (p3[40] & g3[32]);
    assign p4[40] = p3[40] & p3[32];

    assign g4[41] = g3[41] | (p3[41] & g3[33]);
    assign p4[41] = p3[41] & p3[33];

    assign g4[42] = g3[42] | (p3[42] & g3[34]);
    assign p4[42] = p3[42] & p3[34];

    assign g4[43] = g3[43] | (p3[43] & g3[35]);
    assign p4[43] = p3[43] & p3[35];

    assign g4[44] = g3[44] | (p3[44] & g3[36]);
    assign p4[44] = p3[44] & p3[36];

    assign g4[45] = g3[45] | (p3[45] & g3[37]);
    assign p4[45] = p3[45] & p3[37];

    assign g4[46] = g3[46] | (p3[46] & g3[38]);
    assign p4[46] = p3[46] & p3[38];

    assign g4[47] = g3[47] | (p3[47] & g3[39]);
    assign p4[47] = p3[47] & p3[39];

    assign g4[48] = g3[48] | (p3[48] & g3[40]);
    assign p4[48] = p3[48] & p3[40];

    assign g4[49] = g3[49] | (p3[49] & g3[41]);
    assign p4[49] = p3[49] & p3[41];

    assign g4[50] = g3[50] | (p3[50] & g3[42]);
    assign p4[50] = p3[50] & p3[42];

    assign g4[51] = g3[51] | (p3[51] & g3[43]);
    assign p4[51] = p3[51] & p3[43];

    assign g4[52] = g3[52] | (p3[52] & g3[44]);
    assign p4[52] = p3[52] & p3[44];

    assign g4[53] = g3[53] | (p3[53] & g3[45]);
    assign p4[53] = p3[53] & p3[45];

    assign g4[54] = g3[54] | (p3[54] & g3[46]);
    assign p4[54] = p3[54] & p3[46];

    assign g4[55] = g3[55] | (p3[55] & g3[47]);
    assign p4[55] = p3[55] & p3[47];

    assign g4[56] = g3[56] | (p3[56] & g3[48]);
    assign p4[56] = p3[56] & p3[48];

    assign g4[57] = g3[57] | (p3[57] & g3[49]);
    assign p4[57] = p3[57] & p3[49];

    assign g4[58] = g3[58] | (p3[58] & g3[50]);
    assign p4[58] = p3[58] & p3[50];

    assign g4[59] = g3[59] | (p3[59] & g3[51]);
    assign p4[59] = p3[59] & p3[51];

    assign g4[60] = g3[60] | (p3[60] & g3[52]);
    assign p4[60] = p3[60] & p3[52];

    assign g4[61] = g3[61] | (p3[61] & g3[53]);
    assign p4[61] = p3[61] & p3[53];

    assign g4[62] = g3[62] | (p3[62] & g3[54]);
    assign p4[62] = p3[62] & p3[54];

    assign g4[63] = g3[63] | (p3[63] & g3[55]);
    assign p4[63] = p3[63] & p3[55];

    // Level 5 -> distance = 2^(5-1)
    // Bit i (i >= 16): hi = i, lo = i - 16
    // g5[i] = g4[i] | (p4[i] & g4[i-16])
    // p5[i] = p4[i] & p4[i-16]
    wire [63:0] g5, p5;
    assign g5[0] = g4[0];
    assign g5[1] = g4[1];
    assign g5[2] = g4[2];
    assign g5[3] = g4[3];
    assign g5[4] = g4[4];
    assign g5[5] = g4[5];
    assign g5[6] = g4[6];
    assign g5[7] = g4[7];
    assign g5[8] = g4[8];
    assign g5[9] = g4[9];
    assign g5[10] = g4[10];
    assign g5[11] = g4[11];
    assign g5[12] = g4[12];
    assign g5[13] = g4[13];
    assign g5[14] = g4[14];
    assign g5[15] = g4[15];

    assign p5[0] = p4[0];
    assign p5[1] = p4[1];
    assign p5[2] = p4[2];
    assign p5[3] = p4[3];
    assign p5[4] = p4[4];
    assign p5[5] = p4[5];
    assign p5[6] = p4[6];
    assign p5[7] = p4[7];
    assign p5[8] = p4[8];
    assign p5[9] = p4[9];
    assign p5[10] = p4[10];
    assign p5[11] = p4[11];
    assign p5[12] = p4[12];
    assign p5[13] = p4[13];
    assign p5[14] = p4[14];
    assign p5[15] = p4[15];

    assign g5[16] = g4[16] | (p4[16] & g4[0]);
    assign p5[16] = p4[16] & p4[0];

    assign g5[17] = g4[17] | (p4[17] & g4[1]);
    assign p5[17] = p4[17] & p4[1];

    assign g5[18] = g4[18] | (p4[18] & g4[2]);
    assign p5[18] = p4[18] & p4[2];

    assign g5[19] = g4[19] | (p4[19] & g4[3]);
    assign p5[19] = p4[19] & p4[3];

    assign g5[20] = g4[20] | (p4[20] & g4[4]);
    assign p5[20] = p4[20] & p4[4];

    assign g5[21] = g4[21] | (p4[21] & g4[5]);
    assign p5[21] = p4[21] & p4[5];

    assign g5[22] = g4[22] | (p4[22] & g4[6]);
    assign p5[22] = p4[22] & p4[6];

    assign g5[23] = g4[23] | (p4[23] & g4[7]);
    assign p5[23] = p4[23] & p4[7];

    assign g5[24] = g4[24] | (p4[24] & g4[8]);
    assign p5[24] = p4[24] & p4[8];

    assign g5[25] = g4[25] | (p4[25] & g4[9]);
    assign p5[25] = p4[25] & p4[9];

    assign g5[26] = g4[26] | (p4[26] & g4[10]);
    assign p5[26] = p4[26] & p4[10];

    assign g5[27] = g4[27] | (p4[27] & g4[11]);
    assign p5[27] = p4[27] & p4[11];

    assign g5[28] = g4[28] | (p4[28] & g4[12]);
    assign p5[28] = p4[28] & p4[12];

    assign g5[29] = g4[29] | (p4[29] & g4[13]);
    assign p5[29] = p4[29] & p4[13];

    assign g5[30] = g4[30] | (p4[30] & g4[14]);
    assign p5[30] = p4[30] & p4[14];

    assign g5[31] = g4[31] | (p4[31] & g4[15]);
    assign p5[31] = p4[31] & p4[15];

    assign g5[32] = g4[32] | (p4[32] & g4[16]);
    assign p5[32] = p4[32] & p4[16];

    assign g5[33] = g4[33] | (p4[33] & g4[17]);
    assign p5[33] = p4[33] & p4[17];

    assign g5[34] = g4[34] | (p4[34] & g4[18]);
    assign p5[34] = p4[34] & p4[18];

    assign g5[35] = g4[35] | (p4[35] & g4[19]);
    assign p5[35] = p4[35] & p4[19];

    assign g5[36] = g4[36] | (p4[36] & g4[20]);
    assign p5[36] = p4[36] & p4[20];

    assign g5[37] = g4[37] | (p4[37] & g4[21]);
    assign p5[37] = p4[37] & p4[21];

    assign g5[38] = g4[38] | (p4[38] & g4[22]);
    assign p5[38] = p4[38] & p4[22];

    assign g5[39] = g4[39] | (p4[39] & g4[23]);
    assign p5[39] = p4[39] & p4[23];

    assign g5[40] = g4[40] | (p4[40] & g4[24]);
    assign p5[40] = p4[40] & p4[24];

    assign g5[41] = g4[41] | (p4[41] & g4[25]);
    assign p5[41] = p4[41] & p4[25];

    assign g5[42] = g4[42] | (p4[42] & g4[26]);
    assign p5[42] = p4[42] & p4[26];

    assign g5[43] = g4[43] | (p4[43] & g4[27]);
    assign p5[43] = p4[43] & p4[27];

    assign g5[44] = g4[44] | (p4[44] & g4[28]);
    assign p5[44] = p4[44] & p4[28];

    assign g5[45] = g4[45] | (p4[45] & g4[29]);
    assign p5[45] = p4[45] & p4[29];

    assign g5[46] = g4[46] | (p4[46] & g4[30]);
    assign p5[46] = p4[46] & p4[30];

    assign g5[47] = g4[47] | (p4[47] & g4[31]);
    assign p5[47] = p4[47] & p4[31];

    assign g5[48] = g4[48] | (p4[48] & g4[32]);
    assign p5[48] = p4[48] & p4[32];

    assign g5[49] = g4[49] | (p4[49] & g4[33]);
    assign p5[49] = p4[49] & p4[33];

    assign g5[50] = g4[50] | (p4[50] & g4[34]);
    assign p5[50] = p4[50] & p4[34];

    assign g5[51] = g4[51] | (p4[51] & g4[35]);
    assign p5[51] = p4[51] & p4[35];

    assign g5[52] = g4[52] | (p4[52] & g4[36]);
    assign p5[52] = p4[52] & p4[36];

    assign g5[53] = g4[53] | (p4[53] & g4[37]);
    assign p5[53] = p4[53] & p4[37];

    assign g5[54] = g4[54] | (p4[54] & g4[38]);
    assign p5[54] = p4[54] & p4[38];

    assign g5[55] = g4[55] | (p4[55] & g4[39]);
    assign p5[55] = p4[55] & p4[39];

    assign g5[56] = g4[56] | (p4[56] & g4[40]);
    assign p5[56] = p4[56] & p4[40];

    assign g5[57] = g4[57] | (p4[57] & g4[41]);
    assign p5[57] = p4[57] & p4[41];

    assign g5[58] = g4[58] | (p4[58] & g4[42]);
    assign p5[58] = p4[58] & p4[42];

    assign g5[59] = g4[59] | (p4[59] & g4[43]);
    assign p5[59] = p4[59] & p4[43];

    assign g5[60] = g4[60] | (p4[60] & g4[44]);
    assign p5[60] = p4[60] & p4[44];

    assign g5[61] = g4[61] | (p4[61] & g4[45]);
    assign p5[61] = p4[61] & p4[45];

    assign g5[62] = g4[62] | (p4[62] & g4[46]);
    assign p5[62] = p4[62] & p4[46];

    assign g5[63] = g4[63] | (p4[63] & g4[47]);
    assign p5[63] = p4[63] & p4[47];

    // Level 6 -> distance = 2^(6-1)
    // Bit i (i >= 32): hi = i, lo = i - 32
    // g6[i] = g5[i] | (p5[i] & g5[i-32])
    // p6[i] = p5[i] & p5[i-32]
    wire [63:0] g6, p6;
    assign g6[0] =  g5[0];
    assign g6[1] =  g5[1];
    assign g6[2] =  g5[2];
    assign g6[3] =  g5[3];
    assign g6[4] =  g5[4];
    assign g6[5] =  g5[5];
    assign g6[6] =  g5[6];
    assign g6[7] =  g5[7];
    assign g6[8] =  g5[8];
    assign g6[9] =  g5[9];
    assign g6[10] = g5[10];
    assign g6[11] = g5[11];
    assign g6[12] = g5[12];
    assign g6[13] = g5[13];
    assign g6[14] = g5[14];
    assign g6[15] = g5[15];
    assign g6[16] = g5[16];
    assign g6[17] = g5[17];
    assign g6[18] = g5[18];
    assign g6[19] = g5[19];
    assign g6[20] = g5[20];
    assign g6[21] = g5[21];
    assign g6[22] = g5[22];
    assign g6[23] = g5[23];
    assign g6[24] = g5[24];
    assign g6[25] = g5[25];
    assign g6[26] = g5[26];
    assign g6[27] = g5[27];
    assign g6[28] = g5[28];
    assign g6[29] = g5[29];
    assign g6[30] = g5[30];
    assign g6[31] = g5[31];

    assign p6[0] =  p5[0];
    assign p6[1] =  p5[1];
    assign p6[2] =  p5[2];
    assign p6[3] =  p5[3];
    assign p6[4] =  p5[4];
    assign p6[5] =  p5[5];
    assign p6[6] =  p5[6];
    assign p6[7] =  p5[7];
    assign p6[8] =  p5[8];
    assign p6[9] =  p5[9];
    assign p6[10] = p5[10];
    assign p6[11] = p5[11];
    assign p6[12] = p5[12];
    assign p6[13] = p5[13];
    assign p6[14] = p5[14];
    assign p6[15] = p5[15];
    assign p6[16] = p5[16];
    assign p6[17] = p5[17];
    assign p6[18] = p5[18];
    assign p6[19] = p5[19];
    assign p6[20] = p5[20];
    assign p6[21] = p5[21];
    assign p6[22] = p5[22];
    assign p6[23] = p5[23];
    assign p6[24] = p5[24];
    assign p6[25] = p5[25];
    assign p6[26] = p5[26];
    assign p6[27] = p5[27];
    assign p6[28] = p5[28];
    assign p6[29] = p5[29];
    assign p6[30] = p5[30];
    assign p6[31] = p5[31];

    assign g6[32] = g5[32] | (p5[32] & g5[0]);
    assign p6[32] = p5[32] & p5[0];

    assign g6[33] = g5[33] | (p5[33] & g5[1]);
    assign p6[33] = p5[33] & p5[1];

    assign g6[34] = g5[34] | (p5[34] & g5[2]);
    assign p6[34] = p5[34] & p5[2];

    assign g6[35] = g5[35] | (p5[35] & g5[3]);
    assign p6[35] = p5[35] & p5[3];

    assign g6[36] = g5[36] | (p5[36] & g5[4]);
    assign p6[36] = p5[36] & p5[4];

    assign g6[37] = g5[37] | (p5[37] & g5[5]);
    assign p6[37] = p5[37] & p5[5];

    assign g6[38] = g5[38] | (p5[38] & g5[6]);
    assign p6[38] = p5[38] & p5[6];

    assign g6[39] = g5[39] | (p5[39] & g5[7]);
    assign p6[39] = p5[39] & p5[7];

    assign g6[40] = g5[40] | (p5[40] & g5[8]);
    assign p6[40] = p5[40] & p5[8];

    assign g6[41] = g5[41] | (p5[41] & g5[9]);
    assign p6[41] = p5[41] & p5[9];

    assign g6[42] = g5[42] | (p5[42] & g5[10]);
    assign p6[42] = p5[42] & p5[10];

    assign g6[43] = g5[43] | (p5[43] & g5[11]);
    assign p6[43] = p5[43] & p5[11];

    assign g6[44] = g5[44] | (p5[44] & g5[12]);
    assign p6[44] = p5[44] & p5[12];

    assign g6[45] = g5[45] | (p5[45] & g5[13]);
    assign p6[45] = p5[45] & p5[13];

    assign g6[46] = g5[46] | (p5[46] & g5[14]);
    assign p6[46] = p5[46] & p5[14];

    assign g6[47] = g5[47] | (p5[47] & g5[15]);
    assign p6[47] = p5[47] & p5[15];

    assign g6[48] = g5[48] | (p5[48] & g5[16]);
    assign p6[48] = p5[48] & p5[16];

    assign g6[49] = g5[49] | (p5[49] & g5[17]);
    assign p6[49] = p5[49] & p5[17];

    assign g6[50] = g5[50] | (p5[50] & g5[18]);
    assign p6[50] = p5[50] & p5[18];

    assign g6[51] = g5[51] | (p5[51] & g5[19]);
    assign p6[51] = p5[51] & p5[19];

    assign g6[52] = g5[52] | (p5[52] & g5[20]);
    assign p6[52] = p5[52] & p5[20];

    assign g6[53] = g5[53] | (p5[53] & g5[21]);
    assign p6[53] = p5[53] & p5[21];

    assign g6[54] = g5[54] | (p5[54] & g5[22]);
    assign p6[54] = p5[54] & p5[22];

    assign g6[55] = g5[55] | (p5[55] & g5[23]);
    assign p6[55] = p5[55] & p5[23];

    assign g6[56] = g5[56] | (p5[56] & g5[24]);
    assign p6[56] = p5[56] & p5[24];

    assign g6[57] = g5[57] | (p5[57] & g5[25]);
    assign p6[57] = p5[57] & p5[25];

    assign g6[58] = g5[58] | (p5[58] & g5[26]);
    assign p6[58] = p5[58] & p5[26];

    assign g6[59] = g5[59] | (p5[59] & g5[27]);
    assign p6[59] = p5[59] & p5[27];

    assign g6[60] = g5[60] | (p5[60] & g5[28]);
    assign p6[60] = p5[60] & p5[28];

    assign g6[61] = g5[61] | (p5[61] & g5[29]);
    assign p6[61] = p5[61] & p5[29];

    assign g6[62] = g5[62] | (p5[62] & g5[30]);
    assign p6[62] = p5[62] & p5[30];

    assign g6[63] = g5[63] | (p5[63] & g5[31]);
    assign p6[63] = p5[63] & p5[31];

    // Postprocessing
    wire [63:0] carry;
    assign carry[0] = cin;

    assign carry[1] = g6[0] | (p6[0] & cin);
    assign carry[2] = g6[1] | (p6[1] & cin);
    assign carry[3] = g6[2] | (p6[2] & cin);
    assign carry[4] = g6[3] | (p6[3] & cin);
    assign carry[5] = g6[4] | (p6[4] & cin);
    assign carry[6] = g6[5] | (p6[5] & cin);
    assign carry[7] = g6[6] | (p6[6] & cin);
    assign carry[8] = g6[7] | (p6[7] & cin);
    assign carry[9] = g6[8] | (p6[8] & cin);
    assign carry[10] = g6[9] | (p6[9] & cin);
    assign carry[11] = g6[10] | (p6[10] & cin);
    assign carry[12] = g6[11] | (p6[11] & cin);
    assign carry[13] = g6[12] | (p6[12] & cin);
    assign carry[14] = g6[13] | (p6[13] & cin);
    assign carry[15] = g6[14] | (p6[14] & cin);
    assign carry[16] = g6[15] | (p6[15] & cin);
    assign carry[17] = g6[16] | (p6[16] & cin);
    assign carry[18] = g6[17] | (p6[17] & cin);
    assign carry[19] = g6[18] | (p6[18] & cin);
    assign carry[20] = g6[19] | (p6[19] & cin);
    assign carry[21] = g6[20] | (p6[20] & cin);
    assign carry[22] = g6[21] | (p6[21] & cin);
    assign carry[23] = g6[22] | (p6[22] & cin);
    assign carry[24] = g6[23] | (p6[23] & cin);
    assign carry[25] = g6[24] | (p6[24] & cin);
    assign carry[26] = g6[25] | (p6[25] & cin);
    assign carry[27] = g6[26] | (p6[26] & cin);
    assign carry[28] = g6[27] | (p6[27] & cin);
    assign carry[29] = g6[28] | (p6[28] & cin);
    assign carry[30] = g6[29] | (p6[29] & cin);
    assign carry[31] = g6[30] | (p6[30] & cin);
    assign carry[32] = g6[31] | (p6[31] & cin);
    assign carry[33] = g6[32] | (p6[32] & cin);
    assign carry[34] = g6[33] | (p6[33] & cin);
    assign carry[35] = g6[34] | (p6[34] & cin);
    assign carry[36] = g6[35] | (p6[35] & cin);
    assign carry[37] = g6[36] | (p6[36] & cin);
    assign carry[38] = g6[37] | (p6[37] & cin);
    assign carry[39] = g6[38] | (p6[38] & cin);
    assign carry[40] = g6[39] | (p6[39] & cin);
    assign carry[41] = g6[40] | (p6[40] & cin);
    assign carry[42] = g6[41] | (p6[41] & cin);
    assign carry[43] = g6[42] | (p6[42] & cin);
    assign carry[44] = g6[43] | (p6[43] & cin);
    assign carry[45] = g6[44] | (p6[44] & cin);
    assign carry[46] = g6[45] | (p6[45] & cin);
    assign carry[47] = g6[46] | (p6[46] & cin);
    assign carry[48] = g6[47] | (p6[47] & cin);
    assign carry[49] = g6[48] | (p6[48] & cin);
    assign carry[50] = g6[49] | (p6[49] & cin);
    assign carry[51] = g6[50] | (p6[50] & cin);
    assign carry[52] = g6[51] | (p6[51] & cin);
    assign carry[53] = g6[52] | (p6[52] & cin);
    assign carry[54] = g6[53] | (p6[53] & cin);
    assign carry[55] = g6[54] | (p6[54] & cin);
    assign carry[56] = g6[55] | (p6[55] & cin);
    assign carry[57] = g6[56] | (p6[56] & cin);
    assign carry[58] = g6[57] | (p6[57] & cin);
    assign carry[59] = g6[58] | (p6[58] & cin);
    assign carry[60] = g6[59] | (p6[59] & cin);
    assign carry[61] = g6[60] | (p6[60] & cin);
    assign carry[62] = g6[61] | (p6[61] & cin);
    assign carry[63] = g6[62] | (p6[62] & cin);

    xor x_sum_0(sum[0], p0[0], carry[0]);
    xor x_sum_1(sum[1], p0[1], carry[1]);
    xor x_sum_2(sum[2], p0[2], carry[2]);
    xor x_sum_3(sum[3], p0[3], carry[3]);
    xor x_sum_4(sum[4], p0[4], carry[4]);
    xor x_sum_5(sum[5], p0[5], carry[5]);
    xor x_sum_6(sum[6], p0[6], carry[6]);
    xor x_sum_7(sum[7], p0[7], carry[7]);
    xor x_sum_8(sum[8], p0[8], carry[8]);
    xor x_sum_9(sum[9], p0[9], carry[9]);
    xor x_sum_10(sum[10], p0[10], carry[10]);
    xor x_sum_11(sum[11], p0[11], carry[11]);
    xor x_sum_12(sum[12], p0[12], carry[12]);
    xor x_sum_13(sum[13], p0[13], carry[13]);
    xor x_sum_14(sum[14], p0[14], carry[14]);
    xor x_sum_15(sum[15], p0[15], carry[15]);
    xor x_sum_16(sum[16], p0[16], carry[16]);
    xor x_sum_17(sum[17], p0[17], carry[17]);
    xor x_sum_18(sum[18], p0[18], carry[18]);
    xor x_sum_19(sum[19], p0[19], carry[19]);
    xor x_sum_20(sum[20], p0[20], carry[20]);
    xor x_sum_21(sum[21], p0[21], carry[21]);
    xor x_sum_22(sum[22], p0[22], carry[22]);
    xor x_sum_23(sum[23], p0[23], carry[23]);
    xor x_sum_24(sum[24], p0[24], carry[24]);
    xor x_sum_25(sum[25], p0[25], carry[25]);
    xor x_sum_26(sum[26], p0[26], carry[26]);
    xor x_sum_27(sum[27], p0[27], carry[27]);
    xor x_sum_28(sum[28], p0[28], carry[28]);
    xor x_sum_29(sum[29], p0[29], carry[29]);
    xor x_sum_30(sum[30], p0[30], carry[30]);
    xor x_sum_31(sum[31], p0[31], carry[31]);
    xor x_sum_32(sum[32], p0[32], carry[32]);
    xor x_sum_33(sum[33], p0[33], carry[33]);
    xor x_sum_34(sum[34], p0[34], carry[34]);
    xor x_sum_35(sum[35], p0[35], carry[35]);
    xor x_sum_36(sum[36], p0[36], carry[36]);
    xor x_sum_37(sum[37], p0[37], carry[37]);
    xor x_sum_38(sum[38], p0[38], carry[38]);
    xor x_sum_39(sum[39], p0[39], carry[39]);
    xor x_sum_40(sum[40], p0[40], carry[40]);
    xor x_sum_41(sum[41], p0[41], carry[41]);
    xor x_sum_42(sum[42], p0[42], carry[42]);
    xor x_sum_43(sum[43], p0[43], carry[43]);
    xor x_sum_44(sum[44], p0[44], carry[44]);
    xor x_sum_45(sum[45], p0[45], carry[45]);
    xor x_sum_46(sum[46], p0[46], carry[46]);
    xor x_sum_47(sum[47], p0[47], carry[47]);
    xor x_sum_48(sum[48], p0[48], carry[48]);
    xor x_sum_49(sum[49], p0[49], carry[49]);
    xor x_sum_50(sum[50], p0[50], carry[50]);
    xor x_sum_51(sum[51], p0[51], carry[51]);
    xor x_sum_52(sum[52], p0[52], carry[52]);
    xor x_sum_53(sum[53], p0[53], carry[53]);
    xor x_sum_54(sum[54], p0[54], carry[54]);
    xor x_sum_55(sum[55], p0[55], carry[55]);
    xor x_sum_56(sum[56], p0[56], carry[56]);
    xor x_sum_57(sum[57], p0[57], carry[57]);
    xor x_sum_58(sum[58], p0[58], carry[58]);
    xor x_sum_59(sum[59], p0[59], carry[59]);
    xor x_sum_60(sum[60], p0[60], carry[60]);
    xor x_sum_61(sum[61], p0[61], carry[61]);
    xor x_sum_62(sum[62], p0[62], carry[62]);
    xor x_sum_63(sum[63], p0[63], carry[63]);

    wire w_cout_and;
    and a_cout(w_cout_and, p6[63], cin);
    or o_cout(cout, g6[63], w_cout_and);

endmodule