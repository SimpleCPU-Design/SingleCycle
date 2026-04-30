`timescale 1ns/1ps

// --- Half Adder ---
module half_adder (
    output sum, 
    output cout,
    input a,
    input b
);
    xor g_sum(sum, a, b);
    and g_cout(cout, a, b);
endmodule

// --- Full Adder ---
module full_adder (
    output sum,
    output cout,
    input a,
    input b,
    input cin
);
    wire w_xor_a_b, w_c1, w_c2;
    xor x1(w_xor_a_b, a, b);
    xor x2(sum, w_xor_a_b, cin);
    and a1(w_c1, a, b);
    and a2(w_c2, w_xor_a_b, cin);
    or o1(cout, w_c1, w_c2);
endmodule

// --- 2-to-1 MUX (1-bit) ---
// y = a when sel = 0, y = b when sel = 1
module mux2_1 (
    output y,
    input a,
    input b,
    input sel
);
    wire nsel, wa, wb;
    not n_1(nsel, sel);
    and a_1(wa, a, nsel);
    and a_2(wb, b, sel);
    or o_1(y, wa, wb);
endmodule

// --- 2-to-1 MUX (64-bit) (Array of mux2_1 instances) ---
module mux2_1_64 (
    output [63:0] y,
    input [63:0] a,
    input [63:0] b,
    input sel
);
    mux2_1 u[63:0](
        .y(y),
        .a(a),
        .b(b),
        .sel(sel)
    );
endmodule

// --- 4-to-1 MUX (64-bit) (Cascaded mux2_64) ---
module mux4_1_64 (
    output [63:0] y,
    input [63:0] a,
    input [63:0] b,
    input [63:0] c,
    input [63:0] d,
    input [1:0] sel
);
    wire [63:0] w0, w1;
    mux2_1_64 u0(
        .y(w0),
        .a(a),
        .b(b),
        .sel(sel[0])
    );
    mux2_1_64 u1(
        .y(w1),
        .a(c),
        .b(d),
        .sel(sel[0])
    );
    mux2_1_64 u2(
        .y(y),
        .a(w0),
        .b(w1),
        .sel(sel[1])
    );
endmodule

// --- 8-to-1 MUX (64-bit) (Cascaded) ---
module mux8_1_64 (
    output [63:0] y,
    input [63:0] a0,
    input [63:0] a1,
    input [63:0] a2,
    input [63:0] a3,
    input [63:0] a4,
    input [63:0] a5,
    input [63:0] a6,
    input [63:0] a7,
    input [2:0] sel
);
    wire [63:0] w0, w1;
    mux4_1_64 u0(
        .y(w0),
        .a(a0),
        .b(a1),
        .c(a2),
        .d(a3),
        .sel(sel[1:0])
    );
    mux4_1_64 u1(
        .y(w1),
        .a(a4),
        .b(a5),
        .c(a6),
        .d(a7),
        .sel(sel[1:0])
    );
    mux2_1_64 u2(
        .y(y),
        .a(w0),
        .b(w1),
        .sel(sel[2])
    );
endmodule

// --- 5-to-32 Decoder ---
module decoder5_32 (
    output [31:0] y,
    input [4:0] in
);
    wire n0, n1, n2, n3, n4;
    not n_0(n0, in[0]);
    not n_1(n1, in[1]);
    not n_2(n2, in[2]);
    not n_3(n3, in[3]);
    not n_4(n4, in[4]);

    and a0(y[0], n4, n3, n2, n1, n0);
    and a1(y[1], n4, n3, n2, n1, in[0]);
    and a2(y[2], n4, n3, n2, in[1], n0);
    and a3(y[3], n4, n3, n2, in[1], in[0]);
    and a4(y[4], n4, n3, in[2], n1, n0);
    and a5(y[5], n4, n3, in[2], n1, in[0]);
    and a6(y[6], n4, n3, in[2], in[1], n0);
    and a7(y[7], n4, n3, in[2], in[1], in[0]);
    and a8(y[8], n4, in[3], n2, n1, n0);
    and a9(y[9], n4, in[3], n2, n1, in[0]);
    and a10(y[10], n4, in[3], n2, in[1], n0);
    and a11(y[11], n4, in[3], n2, in[1], in[0]);
    and a12(y[12], n4, in[3], in[2], n1, n0);
    and a13(y[13], n4, in[3], in[2], n1, in[0]);
    and a14(y[14], n4, in[3], in[2], in[1], n0);
    and a15(y[15], n4, in[3], in[2], in[1], in[0]);
    and a16(y[16], in[4], n3, n2, n1, n0);
    and a17(y[17], in[4], n3, n2, n1, in[0]);
    and a18(y[18], in[4], n3, n2, in[1], n0);
    and a19(y[19], in[4], n3, n2, in[1], in[0]);
    and a20(y[20], in[4], n3, in[2], n1, n0);
    and a21(y[21], in[4], n3, in[2], n1, in[0]);
    and a22(y[22], in[4], n3, in[2], in[1], n0);
    and a23(y[23], in[4], n3, in[2], in[1], in[0]);
    and a24(y[24], in[4], in[3], n2, n1, n0);
    and a25(y[25], in[4], in[3], n2, n1, in[0]);
    and a26(y[26], in[4], in[3], n2, in[1], n0);
    and a27(y[27], in[4], in[3], n2, in[1], in[0]);
    and a28(y[28], in[4], in[3], in[2], n1, n0);
    and a29(y[29], in[4], in[3], in[2], n1, in[0]);
    and a30(y[30], in[4], in[3], in[2], in[1], n0);
    and a31(y[31], in[4], in[3], in[2], in[1], in[0]);
endmodule

// --- D Flip-Flop (1-bit, sync reset) ---
// Sync reset-to-0: when rst=1, d_in=0 -> q becomes 0 next clk edge
module dff (
    output reg q,
    input d,
    input clk,
    input rst
);
    wire nrst, d_in;
    not n_rst(nrst, rst);
    and a_0(d_in, d, nrst);
    always @(posedge clk) q <= d_in;
endmodule

// --- D Flip-Flop (64-bit, sync reset) ---
module dff64 (
    output reg [63:0] q,
    input [63:0] d,
    input clk,
    input rst
);
    wire nrst;
    wire [63:0] d_in;
    not n_rst(nrst, rst);
    and a_0[63:0](d_in, d, nrst);
    always @(posedge clk) q <= d_in;
endmodule