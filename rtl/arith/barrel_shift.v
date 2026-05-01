`timescale 1ns/1ps

// 64-bit Barrel Shifter - LSL / LSR / ASR / ROR

module barrel_shift (
    output [63:0] y,
    input [63:0] a,
    input [5:0] shamt,
    input [1:0] op
);
    // -- Op decode
    // lsl = ~op[1] & ~op[0]
    // lsr = ~op[1] &  op[0]
    // asr =  op[1] & ~op[0]
    // ror =  op[1] &  op[0]
    wire op_lsl, op_lsr, op_asr, op_ror;
    wire nop1, nop0;
    not n_1(nop1, op[1]);
    not n_0(nop0, op[0]);
    and a_lsl(op_lsl, nop1, nop0);
    and a_lsr(op_lsr, nop1, op[0]);
    and a_asr(op_asr, op[1], nop0);
    and a_ror(op_ror, op[1], op[0]);

    // Sign bit - ASR fill
    wire sign_bit;
    assign sign_bit = a[63];

    // Reverse Input
    wire [63:0] a_rev;
    assign a_rev = {
        a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7],
        a[8], a[9], a[10], a[11], a[12], a[13], a[14], a[15],
        a[16], a[17], a[18], a[19], a[20], a[21], a[22], a[23],
        a[24], a[25], a[26], a[27], a[28], a[29], a[30], a[31],
        a[32], a[33], a[34], a[35], a[36], a[37], a[38], a[39],
        a[40], a[41], a[42], a[43], a[44], a[45], a[46], a[47],
        a[48], a[49], a[50], a[51], a[52], a[53], a[54], a[55],
        a[56], a[57], a[58], a[59], a[60], a[61], a[62], a[63]
    };

    // Barrel input: a_rev if LSL
    wire [63:0] s0_in;
    mux2_1_64 u_in_sel(
        .y(s0_in),
        .a(a),
        .b(a_rev),
        .sel(op_lsl)
    );
    
    // Level k: d = 2^k
    
    
    // Level 0: d = 1
    // [62:0]: shifted0[i] = s0_in[i+1] -> s0_in[63:1]
    // [63]: fill bit
    //      LSR/LSL -> 0
    //      ASR -> sign_bit
    //      ROR -> s0_in[0] 
    // 
    // fill_0 generation: 2 mux2_1
    //      tmp_zs = op_asr ? sign_bit : 1'b0
    //      fill_0 = op_ror ? s0_in[0] : tmp_zs
    wire [63:0] shifted0;
    wire fill0_zs, fill0;
    wire zero_bit;
    assign zero_bit = 1'b0;
    mux2_1 u_fz0_0(
        .y(fill0_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff0_0(
        .y(fill0),
        .a(fill0_zs),
        .b(s0_in[0]),
        .sel(op_ror)
    );

    // assign shifted0[62:0] = s0_in[63:1]
    assign shifted0[0] = s0_in[1];
    assign shifted0[1] = s0_in[2];
    assign shifted0[2] = s0_in[3];
    assign shifted0[3] = s0_in[4];
    assign shifted0[4] = s0_in[5];
    assign shifted0[5] = s0_in[6];
    assign shifted0[6] = s0_in[7];
    assign shifted0[7] = s0_in[8];
    assign shifted0[8] = s0_in[9];
    assign shifted0[9] = s0_in[10];
    assign shifted0[10] = s0_in[11];
    assign shifted0[11] = s0_in[12];
    assign shifted0[12] = s0_in[13];
    assign shifted0[13] = s0_in[14];
    assign shifted0[14] = s0_in[15];
    assign shifted0[15] = s0_in[16];
    assign shifted0[16] = s0_in[17];
    assign shifted0[17] = s0_in[18];
    assign shifted0[18] = s0_in[19];
    assign shifted0[19] = s0_in[20];
    assign shifted0[20] = s0_in[21];
    assign shifted0[21] = s0_in[22];
    assign shifted0[22] = s0_in[23];
    assign shifted0[23] = s0_in[24];
    assign shifted0[24] = s0_in[25];
    assign shifted0[25] = s0_in[26];
    assign shifted0[26] = s0_in[27];
    assign shifted0[27] = s0_in[28];
    assign shifted0[28] = s0_in[29];
    assign shifted0[29] = s0_in[30];
    assign shifted0[30] = s0_in[31];
    assign shifted0[31] = s0_in[32];
    assign shifted0[32] = s0_in[33];
    assign shifted0[33] = s0_in[34];
    assign shifted0[34] = s0_in[35];
    assign shifted0[35] = s0_in[36];
    assign shifted0[36] = s0_in[37];
    assign shifted0[37] = s0_in[38];
    assign shifted0[38] = s0_in[39];
    assign shifted0[39] = s0_in[40];
    assign shifted0[40] = s0_in[41];
    assign shifted0[41] = s0_in[42];
    assign shifted0[42] = s0_in[43];
    assign shifted0[43] = s0_in[44];
    assign shifted0[44] = s0_in[45];
    assign shifted0[45] = s0_in[46];
    assign shifted0[46] = s0_in[47];
    assign shifted0[47] = s0_in[48];
    assign shifted0[48] = s0_in[49];
    assign shifted0[49] = s0_in[50];
    assign shifted0[50] = s0_in[51];
    assign shifted0[51] = s0_in[52];
    assign shifted0[52] = s0_in[53];
    assign shifted0[53] = s0_in[54];
    assign shifted0[54] = s0_in[55];
    assign shifted0[55] = s0_in[56];
    assign shifted0[56] = s0_in[57];
    assign shifted0[57] = s0_in[58];
    assign shifted0[58] = s0_in[59];
    assign shifted0[59] = s0_in[60];
    assign shifted0[60] = s0_in[61];
    assign shifted0[61] = s0_in[62];
    assign shifted0[62] = s0_in[63];
    
    assign shifted0[63] = fill0;

    // shamt[0] = 0 -> s0_in, shamt[0] = 1 -> shifted0
    wire [63:0] s1_in;
    mux2_1_64 u_st0(
        .y(s1_in),
        .a(s0_in),
        .b(shifted0),
        .sel(shamt[0])
    );

    // Level 1: d = 2
    // 
    //  [61:0]: shifted1[i] = s1_in[i+2]  ->  s1_in[63:2]
    //  [63:62]: 2 bit fill
    //      LSR/LSL -> 2'b00
    //      ASR     -> {sign_bit, sign_bit}
    //      ROR     -> {s1_in[1], s1_in[0]}
    wire [63:0] shifted1;
    wire fill1_62_zs, fill1_62;
    wire fill1_63_zs, fill1_63;
    mux2_1 u_fz1_0(
        .y(fill1_62_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff1_0(
        .y(fill1_62),
        .a(fill1_62_zs),
        .b(s1_in[0]),
        .sel(op_ror)
    );
    mux2_1 u_fz1_1(
        .y(fill1_63_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff1_1(
        .y(fill1_63),
        .a(fill1_63_zs),
        .b(s1_in[1]),
        .sel(op_ror)
    );

    // assign shifted1[61:0] = s1_in[63:2]
    assign shifted1[0] =  s1_in[2];
    assign shifted1[1] =  s1_in[3];
    assign shifted1[2] =  s1_in[4];
    assign shifted1[3] =  s1_in[5];
    assign shifted1[4] =  s1_in[6];
    assign shifted1[5] =  s1_in[7];
    assign shifted1[6] =  s1_in[8];
    assign shifted1[7] =  s1_in[9];
    assign shifted1[8] =  s1_in[10];
    assign shifted1[9] =  s1_in[11];
    assign shifted1[10] = s1_in[12];
    assign shifted1[11] = s1_in[13];
    assign shifted1[12] = s1_in[14];
    assign shifted1[13] = s1_in[15];
    assign shifted1[14] = s1_in[16];
    assign shifted1[15] = s1_in[17];
    assign shifted1[16] = s1_in[18];
    assign shifted1[17] = s1_in[19];
    assign shifted1[18] = s1_in[20];
    assign shifted1[19] = s1_in[21];
    assign shifted1[20] = s1_in[22];
    assign shifted1[21] = s1_in[23];
    assign shifted1[22] = s1_in[24];
    assign shifted1[23] = s1_in[25];
    assign shifted1[24] = s1_in[26];
    assign shifted1[25] = s1_in[27];
    assign shifted1[26] = s1_in[28];
    assign shifted1[27] = s1_in[29];
    assign shifted1[28] = s1_in[30];
    assign shifted1[29] = s1_in[31];
    assign shifted1[30] = s1_in[32];
    assign shifted1[31] = s1_in[33];
    assign shifted1[32] = s1_in[34];
    assign shifted1[33] = s1_in[35];
    assign shifted1[34] = s1_in[36];
    assign shifted1[35] = s1_in[37];
    assign shifted1[36] = s1_in[38];
    assign shifted1[37] = s1_in[39];
    assign shifted1[38] = s1_in[40];
    assign shifted1[39] = s1_in[41];
    assign shifted1[40] = s1_in[42];
    assign shifted1[41] = s1_in[43];
    assign shifted1[42] = s1_in[44];
    assign shifted1[43] = s1_in[45];
    assign shifted1[44] = s1_in[46];
    assign shifted1[45] = s1_in[47];
    assign shifted1[46] = s1_in[48];
    assign shifted1[47] = s1_in[49];
    assign shifted1[48] = s1_in[50];
    assign shifted1[49] = s1_in[51];
    assign shifted1[50] = s1_in[52];
    assign shifted1[51] = s1_in[53];
    assign shifted1[52] = s1_in[54];
    assign shifted1[53] = s1_in[55];
    assign shifted1[54] = s1_in[56];
    assign shifted1[55] = s1_in[57];
    assign shifted1[56] = s1_in[58];
    assign shifted1[57] = s1_in[59];
    assign shifted1[58] = s1_in[60];
    assign shifted1[59] = s1_in[61];
    assign shifted1[60] = s1_in[62];
    assign shifted1[61] = s1_in[63];
    
    assign shifted1[62] = fill1_62;
    assign shifted1[63] = fill1_63;
    
    wire [63:0] s2_in;
    mux2_1_64 u_st1(
        .y(s2_in),
        .a(s1_in),
        .b(shifted1),
        .sel(shamt[1])
    );

    // Level 2: d = 4
    // 
    //  [59:0]: shifted2[i] = s2_in[i+4]  ->  s2_in[63:4]
    //  [63:60]: 4 bit fill
    //      LSR/LSL -> 4'b0000
    //      ASR     -> {sign_bit, sign_bit, sign_bit, sign_bit}
    //      ROR     -> {s2_in[3], s2_in[2], s2_in[1], s2_in[0]}
    wire [63:0] shifted2;
    wire fill2_60_zs, fill2_60;
    wire fill2_61_zs, fill2_61;
    wire fill2_62_zs, fill2_62;
    wire fill2_63_zs, fill2_63;
    
    mux2_1 u_fz2_0(
        .y(fill2_60_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff2_0(
        .y(fill2_60),
        .a(fill2_60_zs),
        .b(s2_in[0]),
        .sel(op_ror)
    );
    mux2_1 u_fz2_1(
        .y(fill2_61_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff2_1(
        .y(fill2_61),
        .a(fill2_61_zs),
        .b(s2_in[1]),
        .sel(op_ror)
    );
    mux2_1 u_fz2_2(
        .y(fill2_62_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff2_2(
        .y(fill2_62),
        .a(fill2_62_zs),
        .b(s2_in[2]),
        .sel(op_ror)
    );
    mux2_1 u_fz2_3(
        .y(fill2_63_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff2_3(
        .y(fill2_63),
        .a(fill2_63_zs),
        .b(s2_in[3]),
        .sel(op_ror)
    );

    // assign shifted2[59:0] = s2_in[63:4]
    assign shifted2[0] =  s2_in[4];
    assign shifted2[1] =  s2_in[5];
    assign shifted2[2] =  s2_in[6]; 
    assign shifted2[3] =  s2_in[7];
    assign shifted2[4] =  s2_in[8];
    assign shifted2[5] =  s2_in[9];
    assign shifted2[6] =  s2_in[10];
    assign shifted2[7] =  s2_in[11];
    assign shifted2[8] = s2_in[12];
    assign shifted2[9] = s2_in[13];
    assign shifted2[10] = s2_in[14];
    assign shifted2[11] = s2_in[15];
    assign shifted2[12] = s2_in[16];
    assign shifted2[13] = s2_in[17];
    assign shifted2[14] = s2_in[18];
    assign shifted2[15] = s2_in[19];
    assign shifted2[16] = s2_in[20];
    assign shifted2[17] = s2_in[21];
    assign shifted2[18] = s2_in[22];
    assign shifted2[19] = s2_in[23];
    assign shifted2[20] = s2_in[24];
    assign shifted2[21] = s2_in[25];
    assign shifted2[22] = s2_in[26];
    assign shifted2[23] = s2_in[27];
    assign shifted2[24] = s2_in[28];
    assign shifted2[25] = s2_in[29];
    assign shifted2[26] = s2_in[30];
    assign shifted2[27] = s2_in[31];
    assign shifted2[28] = s2_in[32];
    assign shifted2[29] = s2_in[33];
    assign shifted2[30] = s2_in[34];
    assign shifted2[31] = s2_in[35];
    assign shifted2[32] = s2_in[36];
    assign shifted2[33] = s2_in[37];
    assign shifted2[34] = s2_in[38];
    assign shifted2[35] = s2_in[39];
    assign shifted2[36] = s2_in[40];
    assign shifted2[37] = s2_in[41];
    assign shifted2[38] = s2_in[42];
    assign shifted2[39] = s2_in[43];
    assign shifted2[40] = s2_in[44];
    assign shifted2[41] = s2_in[45];
    assign shifted2[42] = s2_in[46];
    assign shifted2[43] = s2_in[47];
    assign shifted2[44] = s2_in[48];
    assign shifted2[45] = s2_in[49];
    assign shifted2[46] = s2_in[50];
    assign shifted2[47] = s2_in[51];
    assign shifted2[48] = s2_in[52];
    assign shifted2[49] = s2_in[53];
    assign shifted2[50] = s2_in[54];
    assign shifted2[51] = s2_in[55];
    assign shifted2[52] = s2_in[56];
    assign shifted2[53] = s2_in[57];
    assign shifted2[54] = s2_in[58];
    assign shifted2[55] = s2_in[59];
    assign shifted2[56] = s2_in[60];
    assign shifted2[57] = s2_in[61];
    assign shifted2[58] = s2_in[62];
    assign shifted2[59] = s2_in[63];
    
    assign shifted2[60] = fill2_60;
    assign shifted2[61] = fill2_61;
    assign shifted2[62] = fill2_62;
    assign shifted2[63] = fill2_63;

    wire [63:0] s3_in;
    mux2_1_64 u_st2(
        .y(s3_in),
        .a(s2_in),
        .b(shifted2),
        .sel(shamt[2])
    );
    

    // Level 3: d = 8
    // 
    //  [55:0]: shifted3[i] = s3_in[i+8]  ->  s3_in[63:8]
    //  [63:56]: 8 bit fill
    wire [63:0] shifted3;
    wire fill3_56_zs, fill3_56;
    wire fill3_57_zs, fill3_57;
    wire fill3_58_zs, fill3_58;
    wire fill3_59_zs, fill3_59;
    wire fill3_60_zs, fill3_60;
    wire fill3_61_zs, fill3_61;
    wire fill3_62_zs, fill3_62;
    wire fill3_63_zs, fill3_63;

    mux2_1 u_fz3_0(
        .y(fill3_56_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff3_0(
        .y(fill3_56),
        .a(fill3_56_zs),
        .b(s3_in[0]),
        .sel(op_ror)
    );
    mux2_1 u_fz3_1(
        .y(fill3_57_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff3_1(
        .y(fill3_57),
        .a(fill3_57_zs),
        .b(s3_in[1]),
        .sel(op_ror)
    );
    mux2_1 u_fz3_2(
        .y(fill3_58_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff3_2(
        .y(fill3_58),
        .a(fill3_58_zs),
        .b(s3_in[2]),
        .sel(op_ror)
    );
    mux2_1 u_fz3_3(
        .y(fill3_59_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff3_3(
        .y(fill3_59),
        .a(fill3_59_zs),
        .b(s3_in[3]),
        .sel(op_ror)
    );
    mux2_1 u_fz3_4(
        .y(fill3_60_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff3_4(
        .y(fill3_60),
        .a(fill3_60_zs),
        .b(s3_in[4]),
        .sel(op_ror)
    );
    mux2_1 u_fz3_5(
        .y(fill3_61_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff3_5(
        .y(fill3_61),
        .a(fill3_61_zs),
        .b(s3_in[5]),
        .sel(op_ror)
    );
    mux2_1 u_fz3_6(
        .y(fill3_62_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff3_6(
        .y(fill3_62),
        .a(fill3_62_zs),
        .b(s3_in[6]),
        .sel(op_ror)
    );
    mux2_1 u_fz3_7(
        .y(fill3_63_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff3_7(
        .y(fill3_63),
        .a(fill3_63_zs),
        .b(s3_in[7]),
        .sel(op_ror)
    );

    // assign shifted3[55:0] = s3_in[63:8]
    assign shifted3[0] =  s3_in[8];
    assign shifted3[1] =  s3_in[9];
    assign shifted3[2] =  s3_in[10]; 
    assign shifted3[3] =  s3_in[11];
    assign shifted3[4] =  s3_in[12];
    assign shifted3[5] =  s3_in[13];
    assign shifted3[6] =  s3_in[14];
    assign shifted3[7] =  s3_in[15];
    assign shifted3[8] =  s3_in[16];
    assign shifted3[9] =  s3_in[17];
    assign shifted3[10] = s3_in[18];
    assign shifted3[11] = s3_in[19];
    assign shifted3[12] = s3_in[20];
    assign shifted3[13] = s3_in[21];
    assign shifted3[14] = s3_in[22];
    assign shifted3[15] = s3_in[23];
    assign shifted3[16] = s3_in[24];
    assign shifted3[17] = s3_in[25];
    assign shifted3[18] = s3_in[26];
    assign shifted3[19] = s3_in[27];
    assign shifted3[20] = s3_in[28];
    assign shifted3[21] = s3_in[29];
    assign shifted3[22] = s3_in[30];
    assign shifted3[23] = s3_in[31];
    assign shifted3[24] = s3_in[32];
    assign shifted3[25] = s3_in[33];
    assign shifted3[26] = s3_in[34];
    assign shifted3[27] = s3_in[35];
    assign shifted3[28] = s3_in[36];
    assign shifted3[29] = s3_in[37];
    assign shifted3[30] = s3_in[38];
    assign shifted3[31] = s3_in[39];
    assign shifted3[32] = s3_in[40];
    assign shifted3[33] = s3_in[41];
    assign shifted3[34] = s3_in[42];
    assign shifted3[35] = s3_in[43];
    assign shifted3[36] = s3_in[44];
    assign shifted3[37] = s3_in[45];
    assign shifted3[38] = s3_in[46];
    assign shifted3[39] = s3_in[47];
    assign shifted3[40] = s3_in[48];
    assign shifted3[41] = s3_in[49];
    assign shifted3[42] = s3_in[50];
    assign shifted3[43] = s3_in[51];
    assign shifted3[44] = s3_in[52];
    assign shifted3[45] = s3_in[53];
    assign shifted3[46] = s3_in[54];
    assign shifted3[47] = s3_in[55];
    assign shifted3[48] = s3_in[56];
    assign shifted3[49] = s3_in[57];
    assign shifted3[50] = s3_in[58];
    assign shifted3[51] = s3_in[59];
    assign shifted3[52] = s3_in[60];
    assign shifted3[53] = s3_in[61];
    assign shifted3[54] = s3_in[62];
    assign shifted3[55] = s3_in[63];

    assign shifted3[56] = fill3_56;
    assign shifted3[57] = fill3_57;
    assign shifted3[58] = fill3_58;
    assign shifted3[59] = fill3_59;
    assign shifted3[60] = fill3_60;
    assign shifted3[61] = fill3_61;
    assign shifted3[62] = fill3_62;
    assign shifted3[63] = fill3_63;

    wire [63:0] s4_in;
    mux2_1_64 u_st3(
        .y(s4_in),
        .a(s3_in),
        .b(shifted3),
        .sel(shamt[3])
    );

    // Level 4: d = 16
    // 
    //  [47:0]: shifted4[i] = s4_in[i+16]  ->  s4_in[63:16]
    //  [63:48]: 16 bit fill
    wire [63:0] shifted4;
    wire fill4_48_zs, fill4_48;
    wire fill4_49_zs, fill4_49;
    wire fill4_50_zs, fill4_50;
    wire fill4_51_zs, fill4_51;
    wire fill4_52_zs, fill4_52;
    wire fill4_53_zs, fill4_53;
    wire fill4_54_zs, fill4_54;
    wire fill4_55_zs, fill4_55;
    wire fill4_56_zs, fill4_56;
    wire fill4_57_zs, fill4_57;
    wire fill4_58_zs, fill4_58;
    wire fill4_59_zs, fill4_59;
    wire fill4_60_zs, fill4_60;
    wire fill4_61_zs, fill4_61;
    wire fill4_62_zs, fill4_62;
    wire fill4_63_zs, fill4_63;

    mux2_1 u_fz4_0(
        .y(fill4_48_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_0(
        .y(fill4_48),
        .a(fill4_48_zs),
        .b(s4_in[0]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_1(
        .y(fill4_49_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_1(
        .y(fill4_49),
        .a(fill4_49_zs),
        .b(s4_in[1]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_2(
        .y(fill4_50_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_2(
        .y(fill4_50),
        .a(fill4_50_zs),
        .b(s4_in[2]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_3(
        .y(fill4_51_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_3(
        .y(fill4_51),
        .a(fill4_51_zs),
        .b(s4_in[3]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_4(
        .y(fill4_52_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_4(
        .y(fill4_52),
        .a(fill4_52_zs),
        .b(s4_in[4]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_5(
        .y(fill4_53_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_5(
        .y(fill4_53),
        .a(fill4_53_zs),
        .b(s4_in[5]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_6(
        .y(fill4_54_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_6(
        .y(fill4_54),
        .a(fill4_54_zs),
        .b(s4_in[6]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_7(
        .y(fill4_55_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_7(
        .y(fill4_55),
        .a(fill4_55_zs),
        .b(s4_in[7]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_8(
        .y(fill4_56_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_8(
        .y(fill4_56),
        .a(fill4_56_zs),
        .b(s4_in[8]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_9(
        .y(fill4_57_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_9(
        .y(fill4_57),
        .a(fill4_57_zs),
        .b(s4_in[9]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_10(
        .y(fill4_58_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_10(
        .y(fill4_58),
        .a(fill4_58_zs),
        .b(s4_in[10]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_11(
        .y(fill4_59_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_11(
        .y(fill4_59),
        .a(fill4_59_zs),
        .b(s4_in[11]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_12(
        .y(fill4_60_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_12(
        .y(fill4_60),
        .a(fill4_60_zs),
        .b(s4_in[12]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_13(
        .y(fill4_61_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_13(
        .y(fill4_61),
        .a(fill4_61_zs),
        .b(s4_in[13]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_14(
        .y(fill4_62_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_14(
        .y(fill4_62),
        .a(fill4_62_zs),
        .b(s4_in[14]),
        .sel(op_ror)
    );
    mux2_1 u_fz4_15(
        .y(fill4_63_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff4_15(
        .y(fill4_63),
        .a(fill4_63_zs),
        .b(s4_in[15]),
        .sel(op_ror)
    );

    // assign shifted4[47:0] = s4_in[63:16]
    assign shifted4[0] =  s4_in[16];
    assign shifted4[1] =  s4_in[17];
    assign shifted4[2] =  s4_in[18]; 
    assign shifted4[3] =  s4_in[19];
    assign shifted4[4] =  s4_in[20];
    assign shifted4[5] =  s4_in[21];
    assign shifted4[6] =  s4_in[22];
    assign shifted4[7] =  s4_in[23];
    assign shifted4[8] =  s4_in[24];
    assign shifted4[9] =  s4_in[25];
    assign shifted4[10] = s4_in[26];
    assign shifted4[11] = s4_in[27];
    assign shifted4[12] = s4_in[28];
    assign shifted4[13] = s4_in[29];
    assign shifted4[14] = s4_in[30];
    assign shifted4[15] = s4_in[31];
    assign shifted4[16] = s4_in[32];
    assign shifted4[17] = s4_in[33];
    assign shifted4[18] = s4_in[34];
    assign shifted4[19] = s4_in[35];
    assign shifted4[20] = s4_in[36];
    assign shifted4[21] = s4_in[37];
    assign shifted4[22] = s4_in[38];
    assign shifted4[23] = s4_in[39];
    assign shifted4[24] = s4_in[40];
    assign shifted4[25] = s4_in[41];
    assign shifted4[26] = s4_in[42];
    assign shifted4[27] = s4_in[43];
    assign shifted4[28] = s4_in[44];
    assign shifted4[29] = s4_in[45];
    assign shifted4[30] = s4_in[46];
    assign shifted4[31] = s4_in[47];
    assign shifted4[32] = s4_in[48];
    assign shifted4[33] = s4_in[49];
    assign shifted4[34] = s4_in[50];
    assign shifted4[35] = s4_in[51];
    assign shifted4[36] = s4_in[52];
    assign shifted4[37] = s4_in[53];
    assign shifted4[38] = s4_in[54];
    assign shifted4[39] = s4_in[55];
    assign shifted4[40] = s4_in[56];
    assign shifted4[41] = s4_in[57];
    assign shifted4[42] = s4_in[58];
    assign shifted4[43] = s4_in[59];
    assign shifted4[44] = s4_in[60];
    assign shifted4[45] = s4_in[61];
    assign shifted4[46] = s4_in[62];
    assign shifted4[47] = s4_in[63];

    assign shifted4[48] = fill4_48;
    assign shifted4[49] = fill4_49;
    assign shifted4[50] = fill4_50;
    assign shifted4[51] = fill4_51;
    assign shifted4[52] = fill4_52;
    assign shifted4[53] = fill4_53;
    assign shifted4[54] = fill4_54;
    assign shifted4[55] = fill4_55;
    assign shifted4[56] = fill4_56;
    assign shifted4[57] = fill4_57;
    assign shifted4[58] = fill4_58;
    assign shifted4[59] = fill4_59;
    assign shifted4[60] = fill4_60;
    assign shifted4[61] = fill4_61;
    assign shifted4[62] = fill4_62;
    assign shifted4[63] = fill4_63;

    wire [63:0] s5_in;
    mux2_1_64 u_st4(
        .y(s5_in),
        .a(s4_in),
        .b(shifted4),
        .sel(shamt[4])
    );

    // Level 5: d = 32
    // 
    //  [31:0]: shifted5[i] = s5_in[i+32]  ->  s5_in[63:32]
    //  [63:32]: 32 bit fill
    wire [63:0] shifted5;
    wire fill5_32_zs, fill5_32;
    wire fill5_33_zs, fill5_33;
    wire fill5_34_zs, fill5_34;
    wire fill5_35_zs, fill5_35;
    wire fill5_36_zs, fill5_36;
    wire fill5_37_zs, fill5_37;
    wire fill5_38_zs, fill5_38;
    wire fill5_39_zs, fill5_39;
    wire fill5_40_zs, fill5_40;
    wire fill5_41_zs, fill5_41;
    wire fill5_42_zs, fill5_42;
    wire fill5_43_zs, fill5_43;
    wire fill5_44_zs, fill5_44;
    wire fill5_45_zs, fill5_45;
    wire fill5_46_zs, fill5_46;
    wire fill5_47_zs, fill5_47;
    wire fill5_48_zs, fill5_48;
    wire fill5_49_zs, fill5_49;
    wire fill5_50_zs, fill5_50;
    wire fill5_51_zs, fill5_51;
    wire fill5_52_zs, fill5_52;
    wire fill5_53_zs, fill5_53;
    wire fill5_54_zs, fill5_54;
    wire fill5_55_zs, fill5_55;
    wire fill5_56_zs, fill5_56;
    wire fill5_57_zs, fill5_57;
    wire fill5_58_zs, fill5_58;
    wire fill5_59_zs, fill5_59;
    wire fill5_60_zs, fill5_60;
    wire fill5_61_zs, fill5_61;
    wire fill5_62_zs, fill5_62;
    wire fill5_63_zs, fill5_63;

    mux2_1 u_fz5_0(
        .y(fill5_32_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_0(
        .y(fill5_32),
        .a(fill5_32_zs),
        .b(s5_in[0]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_1(
        .y(fill5_33_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_1(
        .y(fill5_33),
        .a(fill5_33_zs),
        .b(s5_in[1]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_2(
        .y(fill5_34_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_2(
        .y(fill5_34),
        .a(fill5_34_zs),
        .b(s5_in[2]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_3(
        .y(fill5_35_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_3(
        .y(fill5_35),
        .a(fill5_35_zs),
        .b(s5_in[3]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_4(
        .y(fill5_36_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_4(
        .y(fill5_36),
        .a(fill5_36_zs),
        .b(s5_in[4]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_5(
        .y(fill5_37_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_5(
        .y(fill5_37),
        .a(fill5_37_zs),
        .b(s5_in[5]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_6(
        .y(fill5_38_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_6(
        .y(fill5_38),
        .a(fill5_38_zs),
        .b(s5_in[6]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_7(
        .y(fill5_39_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_7(
        .y(fill5_39),
        .a(fill5_39_zs),
        .b(s5_in[7]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_8(
        .y(fill5_40_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_8(
        .y(fill5_40),
        .a(fill5_40_zs),
        .b(s5_in[8]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_9(
        .y(fill5_41_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_9(
        .y(fill5_41),
        .a(fill5_41_zs),
        .b(s5_in[9]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_10(
        .y(fill5_42_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_10(
        .y(fill5_42),
        .a(fill5_42_zs),
        .b(s5_in[10]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_11(
        .y(fill5_43_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_11(
        .y(fill5_43),
        .a(fill5_43_zs),
        .b(s5_in[11]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_12(
        .y(fill5_44_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_12(
        .y(fill5_44),
        .a(fill5_44_zs),
        .b(s5_in[12]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_13(
        .y(fill5_45_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_13(
        .y(fill5_45),
        .a(fill5_45_zs),
        .b(s5_in[13]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_14(
        .y(fill5_46_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_14(
        .y(fill5_46),
        .a(fill5_46_zs),
        .b(s5_in[14]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_15(
        .y(fill5_47_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_15(
        .y(fill5_47),
        .a(fill5_47_zs),
        .b(s5_in[15]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_16(
        .y(fill5_48_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_16(
        .y(fill5_48),
        .a(fill5_48_zs),
        .b(s5_in[16]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_17(
        .y(fill5_49_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_17(
        .y(fill5_49),
        .a(fill5_49_zs),
        .b(s5_in[17]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_18(
        .y(fill5_50_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_18(
        .y(fill5_50),
        .a(fill5_50_zs),
        .b(s5_in[18]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_19(
        .y(fill5_51_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_19(
        .y(fill5_51),
        .a(fill5_51_zs),
        .b(s5_in[19]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_20(
        .y(fill5_52_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_20(
        .y(fill5_52),
        .a(fill5_52_zs),
        .b(s5_in[20]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_21(
        .y(fill5_53_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_21(
        .y(fill5_53),
        .a(fill5_53_zs),
        .b(s5_in[21]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_22(
        .y(fill5_54_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_22(
        .y(fill5_54),
        .a(fill5_54_zs),
        .b(s5_in[22]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_23(
        .y(fill5_55_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_23(
        .y(fill5_55),
        .a(fill5_55_zs),
        .b(s5_in[23]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_24(
        .y(fill5_56_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_24(
        .y(fill5_56),
        .a(fill5_56_zs),
        .b(s5_in[24]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_25(
        .y(fill5_57_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_25(
        .y(fill5_57),
        .a(fill5_57_zs),
        .b(s5_in[25]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_26(
        .y(fill5_58_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_26(
        .y(fill5_58),
        .a(fill5_58_zs),
        .b(s5_in[26]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_27(
        .y(fill5_59_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_27(
        .y(fill5_59),
        .a(fill5_59_zs),
        .b(s5_in[27]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_28(
        .y(fill5_60_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_28(
        .y(fill5_60),
        .a(fill5_60_zs),
        .b(s5_in[28]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_29(
        .y(fill5_61_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_29(
        .y(fill5_61),
        .a(fill5_61_zs),
        .b(s5_in[29]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_30(
        .y(fill5_62_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_30(
        .y(fill5_62),
        .a(fill5_62_zs),
        .b(s5_in[30]),
        .sel(op_ror)
    );
    mux2_1 u_fz5_31(
        .y(fill5_63_zs),
        .a(zero_bit),
        .b(sign_bit),
        .sel(op_asr)
    );
    mux2_1 u_ff5_31(
        .y(fill5_63),
        .a(fill5_63_zs),
        .b(s5_in[31]),
        .sel(op_ror)
    );

    // assign shifted5[31:0] = s5_in[63:32]
    assign shifted5[0] =  s5_in[32];
    assign shifted5[1] =  s5_in[33];
    assign shifted5[2] =  s5_in[34]; 
    assign shifted5[3] =  s5_in[35];
    assign shifted5[4] =  s5_in[36];
    assign shifted5[5] =  s5_in[37];
    assign shifted5[6] =  s5_in[38];
    assign shifted5[7] =  s5_in[39];
    assign shifted5[8] =  s5_in[40];
    assign shifted5[9] =  s5_in[41];
    assign shifted5[10] = s5_in[42];
    assign shifted5[11] = s5_in[43];
    assign shifted5[12] = s5_in[44];
    assign shifted5[13] = s5_in[45];
    assign shifted5[14] = s5_in[46];
    assign shifted5[15] = s5_in[47];
    assign shifted5[16] = s5_in[48];
    assign shifted5[17] = s5_in[49];
    assign shifted5[18] = s5_in[50];
    assign shifted5[19] = s5_in[51];
    assign shifted5[20] = s5_in[52];
    assign shifted5[21] = s5_in[53];
    assign shifted5[22] = s5_in[54];
    assign shifted5[23] = s5_in[55];
    assign shifted5[24] = s5_in[56];
    assign shifted5[25] = s5_in[57];
    assign shifted5[26] = s5_in[58];
    assign shifted5[27] = s5_in[59];
    assign shifted5[28] = s5_in[60];
    assign shifted5[29] = s5_in[61];
    assign shifted5[30] = s5_in[62];
    assign shifted5[31] = s5_in[63];

    assign shifted5[32] = fill5_32;
    assign shifted5[33] = fill5_33;
    assign shifted5[34] = fill5_34;
    assign shifted5[35] = fill5_35;
    assign shifted5[36] = fill5_36;
    assign shifted5[37] = fill5_37;
    assign shifted5[38] = fill5_38;
    assign shifted5[39] = fill5_39;
    assign shifted5[40] = fill5_40;
    assign shifted5[41] = fill5_41;
    assign shifted5[42] = fill5_42;
    assign shifted5[43] = fill5_43;
    assign shifted5[44] = fill5_44;
    assign shifted5[45] = fill5_45;
    assign shifted5[46] = fill5_46;
    assign shifted5[47] = fill5_47;
    assign shifted5[48] = fill5_48;
    assign shifted5[49] = fill5_49;
    assign shifted5[50] = fill5_50;
    assign shifted5[51] = fill5_51;
    assign shifted5[52] = fill5_52;
    assign shifted5[53] = fill5_53;
    assign shifted5[54] = fill5_54;
    assign shifted5[55] = fill5_55;
    assign shifted5[56] = fill5_56;
    assign shifted5[57] = fill5_57;
    assign shifted5[58] = fill5_58;
    assign shifted5[59] = fill5_59;
    assign shifted5[60] = fill5_60;
    assign shifted5[61] = fill5_61;
    assign shifted5[62] = fill5_62;
    assign shifted5[63] = fill5_63;

    wire [63:0] s6_in;
    mux2_1_64 u_st5(
        .y(s6_in),
        .a(s5_in),
        .b(shifted5),
        .sel(shamt[5])
    );

    wire [63:0] s6_in_rev;
    assign s6_in_rev = {
        s6_in[0], s6_in[1], s6_in[2], s6_in[3], s6_in[4], s6_in[5], s6_in[6], s6_in[7],
        s6_in[8], s6_in[9], s6_in[10], s6_in[11], s6_in[12], s6_in[13], s6_in[14], s6_in[15],
        s6_in[16], s6_in[17], s6_in[18], s6_in[19], s6_in[20], s6_in[21], s6_in[22], s6_in[23],
        s6_in[24], s6_in[25], s6_in[26], s6_in[27], s6_in[28], s6_in[29], s6_in[30], s6_in[31],
        s6_in[32], s6_in[33], s6_in[34], s6_in[35], s6_in[36], s6_in[37], s6_in[38], s6_in[39],
        s6_in[40], s6_in[41], s6_in[42], s6_in[43], s6_in[44], s6_in[45], s6_in[46], s6_in[47],
        s6_in[48], s6_in[49], s6_in[50], s6_in[51], s6_in[52], s6_in[53], s6_in[54], s6_in[55],
        s6_in[56], s6_in[57], s6_in[58], s6_in[59], s6_in[60], s6_in[61], s6_in[62], s6_in[63]
    };

    mux2_1_64 u_out_sel(
        .y(y),
        .a(s6_in),
        .b(s6_in_rev),
        .sel(op_lsl)
    );

    
endmodule