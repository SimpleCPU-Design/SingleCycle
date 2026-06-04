`timescale 1ns/1ps

// ===========================================================
//  64-bit Multi-Cycle Restoring Divider — FSM
// ===========================================================
//
//  Algorithm — Restoring Division (1 bit / cycle):
//  -----------------------------------------------
//  We hold a 128-bit register {R, Q}:
//      Upper 64 bits (R): partial remainder
//      Lower 64 bits (Q): unprocessed dividend bits, becoming quotient bits
//
//  Initial state: rq = {64'b0, dividend_abs}
//
//  Each iteration (64 steps total):
//      1. shifted = rq << 1                          (1-bit left shift via concat)
//      2. trial   = shifted[127:64] - div_reg        (subtract divisor from R)
//      3. trial_cout = 1  <->  shifted[127:64] >= div_reg     (no borrow)
//      4. trial_cout=1  ->  R := trial_sum,         Q[0] := 1
//         trial_cout=0  ->  R := shifted[127:64],   Q[0] := 0   (RESTORE: keep old R)
//
//  After 64 iterations:
//      rq[63:0]   = quotient   (unsigned)
//      rq[127:64] = remainder  (unsigned)
//
//  Sign handling (for SDIV):
//  -------------------------
//  Inputs are taken as absolute values; the sign is fixed up at the output.
//      sign_d = is_signed & dividend[63]
//      sign_v = is_signed & divisor [63]
//      sign_q = sign_d ^ sign_v          (different signs -> negative quotient)
//      sign_r = sign_d                   (remainder takes the dividend's sign)
//
//  Negation:  -x = ~x + 1, computed with adder64(~x, 0, cin=1).
//  Corner case: when dividend = INT64_MIN, -INT64_MIN = INT64_MIN (2's-comp
//      overflow). The algorithm operates on the unsigned value 2^63; sign
//      correction at the output flips it back to negative. This matches
//      SDIV semantics (INT64_MIN / -1 = INT64_MIN, no exception).
//
//  Divide-by-zero (dz):
//  --------------------
//  SDIV/UDIV behaviour: divisor=0 -> quotient=0, no exception.
//  We skip the iteration when dz=1:
//      rq_init      = {dividend_abs, 64'b0}        // R = |dividend|, Q = 0
//      counter_init = 7'd64                        // iter_done set -> BUSY -> DONE
//  Sign correction at the output:
//      sign_q = is_signed & dividend[63] ^ 0  ->  q = +-0 = 0
//      sign_r = sign_d                        ->  r = dividend (with original sign)
//
//  Style:
//  ------
//  Pipeline interface:
//      hazard_unit stalls while busy=1.
//      done is a 1-cycle pulse — quotient/remainder are sampled on this cycle.
//      Results stay valid in rq_reg until the next start.
//
//  Latency:
//      1 (IDLE -> BUSY) + 64 iter + 1 (BUSY -> DONE) = 66 cycles, done pulse on cycle 66
//      dz=1 path: 1 (IDLE -> BUSY, counter=64) + 1 (BUSY -> DONE) = 2 cycles
// ===========================================================

module div64(
    output [63:0] quotient,
    output [63:0] remainder,
    output busy,
    output done,
    input [63:0] dividend,
    input [63:0] divisor,
    input is_signed,
    input start,
    input clk,
    input rst
);

    //  STATE register -- 2-bit binary
    //      2'b00 = IDLE, 2'b01 = BUSY, 2'b10 = DONE
    //  state is a wire, the dff array below drives it.
    wire [1:0] state, next_state;

    // --- Status Decoder ---
    wire ns0, ns1;
    not n_ns_inv0(ns0, state[0]);
    not n_ns_inv1(ns1, state[1]);

    wire is_idle, is_busy, is_done;
    and a_idle(is_idle, ns1, ns0); 
    and a_busy(is_busy, ns1, state[0]);
    and a_done(is_done, state[1], ns0);

    // --- Input Sign Bits ---
    //      sign_d = is_signed & dividend[63]
    //      sign_v = is_signed & divisor [63]
    //      sign_q = sign_d ^ sign_v
    //      sign_r = sign_d
    wire sign_d, sign_v;
    and a_sd(sign_d, is_signed, dividend[63]);
    and a_sv(sign_v, is_signed, divisor[63]);

    wire sign_q_init, sign_r_init;
    xor x_sqi(sign_q_init, sign_d, sign_v);
    assign sign_r_init = sign_d;

    // Absolute Value (-x = ~x + 1)
    wire [63:0] dividend_inv, divisor_inv;

    not n_d_inv_00(dividend_inv[0], dividend[0]);
    not n_d_inv_01(dividend_inv[1], dividend[1]);
    not n_d_inv_02(dividend_inv[2], dividend[2]);
    not n_d_inv_03(dividend_inv[3], dividend[3]);
    not n_d_inv_04(dividend_inv[4], dividend[4]);
    not n_d_inv_05(dividend_inv[5], dividend[5]);
    not n_d_inv_06(dividend_inv[6], dividend[6]);
    not n_d_inv_07(dividend_inv[7], dividend[7]);
    not n_d_inv_08(dividend_inv[8], dividend[8]);
    not n_d_inv_09(dividend_inv[9], dividend[9]);
    not n_d_inv_10(dividend_inv[10], dividend[10]);
    not n_d_inv_11(dividend_inv[11], dividend[11]);
    not n_d_inv_12(dividend_inv[12], dividend[12]);
    not n_d_inv_13(dividend_inv[13], dividend[13]);
    not n_d_inv_14(dividend_inv[14], dividend[14]);
    not n_d_inv_15(dividend_inv[15], dividend[15]);
    not n_d_inv_16(dividend_inv[16], dividend[16]);
    not n_d_inv_17(dividend_inv[17], dividend[17]);
    not n_d_inv_18(dividend_inv[18], dividend[18]);
    not n_d_inv_19(dividend_inv[19], dividend[19]);
    not n_d_inv_20(dividend_inv[20], dividend[20]);
    not n_d_inv_21(dividend_inv[21], dividend[21]);
    not n_d_inv_22(dividend_inv[22], dividend[22]);
    not n_d_inv_23(dividend_inv[23], dividend[23]);
    not n_d_inv_24(dividend_inv[24], dividend[24]);
    not n_d_inv_25(dividend_inv[25], dividend[25]);
    not n_d_inv_26(dividend_inv[26], dividend[26]);
    not n_d_inv_27(dividend_inv[27], dividend[27]);
    not n_d_inv_28(dividend_inv[28], dividend[28]);
    not n_d_inv_29(dividend_inv[29], dividend[29]);
    not n_d_inv_30(dividend_inv[30], dividend[30]);
    not n_d_inv_31(dividend_inv[31], dividend[31]);
    not n_d_inv_32(dividend_inv[32], dividend[32]);
    not n_d_inv_33(dividend_inv[33], dividend[33]);
    not n_d_inv_34(dividend_inv[34], dividend[34]);
    not n_d_inv_35(dividend_inv[35], dividend[35]);
    not n_d_inv_36(dividend_inv[36], dividend[36]);
    not n_d_inv_37(dividend_inv[37], dividend[37]);
    not n_d_inv_38(dividend_inv[38], dividend[38]);
    not n_d_inv_39(dividend_inv[39], dividend[39]);
    not n_d_inv_40(dividend_inv[40], dividend[40]);
    not n_d_inv_41(dividend_inv[41], dividend[41]);
    not n_d_inv_42(dividend_inv[42], dividend[42]);
    not n_d_inv_43(dividend_inv[43], dividend[43]);
    not n_d_inv_44(dividend_inv[44], dividend[44]);
    not n_d_inv_45(dividend_inv[45], dividend[45]);
    not n_d_inv_46(dividend_inv[46], dividend[46]);
    not n_d_inv_47(dividend_inv[47], dividend[47]);
    not n_d_inv_48(dividend_inv[48], dividend[48]);
    not n_d_inv_49(dividend_inv[49], dividend[49]);
    not n_d_inv_50(dividend_inv[50], dividend[50]);
    not n_d_inv_51(dividend_inv[51], dividend[51]);
    not n_d_inv_52(dividend_inv[52], dividend[52]);
    not n_d_inv_53(dividend_inv[53], dividend[53]);
    not n_d_inv_54(dividend_inv[54], dividend[54]);
    not n_d_inv_55(dividend_inv[55], dividend[55]);
    not n_d_inv_56(dividend_inv[56], dividend[56]);
    not n_d_inv_57(dividend_inv[57], dividend[57]);
    not n_d_inv_58(dividend_inv[58], dividend[58]);
    not n_d_inv_59(dividend_inv[59], dividend[59]);
    not n_d_inv_60(dividend_inv[60], dividend[60]);
    not n_d_inv_61(dividend_inv[61], dividend[61]);
    not n_d_inv_62(dividend_inv[62], dividend[62]);
    not n_d_inv_63(dividend_inv[63], dividend[63]);

    not n_v_inv_00(divisor_inv[0], divisor[0]);
    not n_v_inv_01(divisor_inv[1], divisor[1]);
    not n_v_inv_02(divisor_inv[2], divisor[2]);
    not n_v_inv_03(divisor_inv[3], divisor[3]);
    not n_v_inv_04(divisor_inv[4], divisor[4]);
    not n_v_inv_05(divisor_inv[5], divisor[5]);
    not n_v_inv_06(divisor_inv[6], divisor[6]);
    not n_v_inv_07(divisor_inv[7], divisor[7]);
    not n_v_inv_08(divisor_inv[8], divisor[8]);
    not n_v_inv_09(divisor_inv[9], divisor[9]);
    not n_v_inv_10(divisor_inv[10], divisor[10]);
    not n_v_inv_11(divisor_inv[11], divisor[11]);
    not n_v_inv_12(divisor_inv[12], divisor[12]);
    not n_v_inv_13(divisor_inv[13], divisor[13]);
    not n_v_inv_14(divisor_inv[14], divisor[14]);
    not n_v_inv_15(divisor_inv[15], divisor[15]);
    not n_v_inv_16(divisor_inv[16], divisor[16]);
    not n_v_inv_17(divisor_inv[17], divisor[17]);
    not n_v_inv_18(divisor_inv[18], divisor[18]);
    not n_v_inv_19(divisor_inv[19], divisor[19]);
    not n_v_inv_20(divisor_inv[20], divisor[20]);
    not n_v_inv_21(divisor_inv[21], divisor[21]);
    not n_v_inv_22(divisor_inv[22], divisor[22]);
    not n_v_inv_23(divisor_inv[23], divisor[23]);
    not n_v_inv_24(divisor_inv[24], divisor[24]);
    not n_v_inv_25(divisor_inv[25], divisor[25]);
    not n_v_inv_26(divisor_inv[26], divisor[26]);
    not n_v_inv_27(divisor_inv[27], divisor[27]);
    not n_v_inv_28(divisor_inv[28], divisor[28]);
    not n_v_inv_29(divisor_inv[29], divisor[29]);
    not n_v_inv_30(divisor_inv[30], divisor[30]);
    not n_v_inv_31(divisor_inv[31], divisor[31]);
    not n_v_inv_32(divisor_inv[32], divisor[32]);
    not n_v_inv_33(divisor_inv[33], divisor[33]);
    not n_v_inv_34(divisor_inv[34], divisor[34]);
    not n_v_inv_35(divisor_inv[35], divisor[35]);
    not n_v_inv_36(divisor_inv[36], divisor[36]);
    not n_v_inv_37(divisor_inv[37], divisor[37]);
    not n_v_inv_38(divisor_inv[38], divisor[38]);
    not n_v_inv_39(divisor_inv[39], divisor[39]);
    not n_v_inv_40(divisor_inv[40], divisor[40]);
    not n_v_inv_41(divisor_inv[41], divisor[41]);
    not n_v_inv_42(divisor_inv[42], divisor[42]);
    not n_v_inv_43(divisor_inv[43], divisor[43]);
    not n_v_inv_44(divisor_inv[44], divisor[44]);
    not n_v_inv_45(divisor_inv[45], divisor[45]);
    not n_v_inv_46(divisor_inv[46], divisor[46]);
    not n_v_inv_47(divisor_inv[47], divisor[47]);
    not n_v_inv_48(divisor_inv[48], divisor[48]);
    not n_v_inv_49(divisor_inv[49], divisor[49]);
    not n_v_inv_50(divisor_inv[50], divisor[50]);
    not n_v_inv_51(divisor_inv[51], divisor[51]);
    not n_v_inv_52(divisor_inv[52], divisor[52]);
    not n_v_inv_53(divisor_inv[53], divisor[53]);
    not n_v_inv_54(divisor_inv[54], divisor[54]);
    not n_v_inv_55(divisor_inv[55], divisor[55]);
    not n_v_inv_56(divisor_inv[56], divisor[56]);
    not n_v_inv_57(divisor_inv[57], divisor[57]);
    not n_v_inv_58(divisor_inv[58], divisor[58]);
    not n_v_inv_59(divisor_inv[59], divisor[59]);
    not n_v_inv_60(divisor_inv[60], divisor[60]);
    not n_v_inv_61(divisor_inv[61], divisor[61]);
    not n_v_inv_62(divisor_inv[62], divisor[62]);
    not n_v_inv_63(divisor_inv[63], divisor[63]);

    wire [63:0] dividend_neg, divisor_neg;
    adder64 u_neg_d(
        .sum(dividend_neg),
        .cout(),
        .a(dividend_inv),
        .b(64'b0),
        .cin(1'b1)
    );

    adder64 u_neg_v(
        .sum(divisor_neg),
        .cout(),
        .a(divisor_inv),
        .b(64'b0),
        .cin(1'b1)
    );

    wire [63:0] dividend_abs, divisor_abs;
    mux2_1_64 u_abs_d(
        .y(dividend_abs),
        .a(dividend),
        .b(dividend_neg),
        .sel(sign_d)
    );

    mux2_1_64 u_abs_v(
        .y(divisor_abs),
        .a(divisor),
        .b(divisor_neg),
        .sel(sign_v)
    );

    // --- Divide By Zero Detect ---
    wire [7:0] or8;
    or g_or8_0(or8[0], divisor[0], divisor[1], divisor[2], divisor[3],
                       divisor[4], divisor[5], divisor[6], divisor[7]);
    or g_or8_1(or8[1], divisor[8], divisor[9], divisor[10], divisor[11],
                       divisor[12], divisor[13], divisor[14], divisor[15]);
    or g_or8_2(or8[2], divisor[16], divisor[17], divisor[18], divisor[19],
                       divisor[20], divisor[21], divisor[22], divisor[23]);
    or g_or8_3(or8[3], divisor[24], divisor[25], divisor[26], divisor[27],
                       divisor[28], divisor[29], divisor[30], divisor[31]);
    or g_or8_4(or8[4], divisor[32], divisor[33], divisor[34], divisor[35],
                       divisor[36], divisor[37], divisor[38], divisor[39]);
    or g_or8_5(or8[5], divisor[40], divisor[41], divisor[42], divisor[43],
                       divisor[44], divisor[45], divisor[46], divisor[47]);
    or g_or8_6(or8[6], divisor[48], divisor[49], divisor[50], divisor[51],
                       divisor[52], divisor[53], divisor[54], divisor[55]);
    or g_or8_7(or8[7], divisor[56], divisor[57], divisor[58], divisor[59],
                       divisor[60], divisor[61], divisor[62], divisor[63]);


    wire any_v;
    or o_any_v(any_v, or8[0], or8[1], or8[2], or8[3],
                      or8[4], or8[5], or8[6], or8[7]);

    wire dz_in;
    not n_dz(dz_in, any_v);

    // --- Initial Values ---
    //      Normal:  rq_init = {64'b0, dividend_abs},  counter_init = 7'd0
    //      dz=1:    rq_init = {dividend_abs, 64'b0},  counter_init = 7'd64
    //
    //      counter_init = {dz_in, 6'b0} -> if dz=1 then counter[6]=1 (iter_done set)
    wire [127:0] rq_init_normal, rq_init_dz, rq_init;
    assign rq_init_normal = {64'b0, dividend_abs};
    assign rq_init_dz = {dividend_abs, 64'b0};

    mux2_1 u_rqi_00(.y(rq_init[0]), .a(rq_init_normal[0]), .b(rq_init_dz[0]), .sel(dz_in));
    mux2_1 u_rqi_01(.y(rq_init[1]), .a(rq_init_normal[1]), .b(rq_init_dz[1]), .sel(dz_in));
    mux2_1 u_rqi_02(.y(rq_init[2]), .a(rq_init_normal[2]), .b(rq_init_dz[2]), .sel(dz_in));
    mux2_1 u_rqi_03(.y(rq_init[3]), .a(rq_init_normal[3]), .b(rq_init_dz[3]), .sel(dz_in));
    mux2_1 u_rqi_04(.y(rq_init[4]), .a(rq_init_normal[4]), .b(rq_init_dz[4]), .sel(dz_in));
    mux2_1 u_rqi_05(.y(rq_init[5]), .a(rq_init_normal[5]), .b(rq_init_dz[5]), .sel(dz_in));
    mux2_1 u_rqi_06(.y(rq_init[6]), .a(rq_init_normal[6]), .b(rq_init_dz[6]), .sel(dz_in));
    mux2_1 u_rqi_07(.y(rq_init[7]), .a(rq_init_normal[7]), .b(rq_init_dz[7]), .sel(dz_in));
    mux2_1 u_rqi_08(.y(rq_init[8]), .a(rq_init_normal[8]), .b(rq_init_dz[8]), .sel(dz_in));
    mux2_1 u_rqi_09(.y(rq_init[9]), .a(rq_init_normal[9]), .b(rq_init_dz[9]), .sel(dz_in));
    mux2_1 u_rqi_10(.y(rq_init[10]), .a(rq_init_normal[10]), .b(rq_init_dz[10]), .sel(dz_in));
    mux2_1 u_rqi_11(.y(rq_init[11]), .a(rq_init_normal[11]), .b(rq_init_dz[11]), .sel(dz_in));
    mux2_1 u_rqi_12(.y(rq_init[12]), .a(rq_init_normal[12]), .b(rq_init_dz[12]), .sel(dz_in));
    mux2_1 u_rqi_13(.y(rq_init[13]), .a(rq_init_normal[13]), .b(rq_init_dz[13]), .sel(dz_in));
    mux2_1 u_rqi_14(.y(rq_init[14]), .a(rq_init_normal[14]), .b(rq_init_dz[14]), .sel(dz_in));
    mux2_1 u_rqi_15(.y(rq_init[15]), .a(rq_init_normal[15]), .b(rq_init_dz[15]), .sel(dz_in));
    mux2_1 u_rqi_16(.y(rq_init[16]), .a(rq_init_normal[16]), .b(rq_init_dz[16]), .sel(dz_in));
    mux2_1 u_rqi_17(.y(rq_init[17]), .a(rq_init_normal[17]), .b(rq_init_dz[17]), .sel(dz_in));
    mux2_1 u_rqi_18(.y(rq_init[18]), .a(rq_init_normal[18]), .b(rq_init_dz[18]), .sel(dz_in));
    mux2_1 u_rqi_19(.y(rq_init[19]), .a(rq_init_normal[19]), .b(rq_init_dz[19]), .sel(dz_in));
    mux2_1 u_rqi_20(.y(rq_init[20]), .a(rq_init_normal[20]), .b(rq_init_dz[20]), .sel(dz_in));
    mux2_1 u_rqi_21(.y(rq_init[21]), .a(rq_init_normal[21]), .b(rq_init_dz[21]), .sel(dz_in));
    mux2_1 u_rqi_22(.y(rq_init[22]), .a(rq_init_normal[22]), .b(rq_init_dz[22]), .sel(dz_in));
    mux2_1 u_rqi_23(.y(rq_init[23]), .a(rq_init_normal[23]), .b(rq_init_dz[23]), .sel(dz_in));
    mux2_1 u_rqi_24(.y(rq_init[24]), .a(rq_init_normal[24]), .b(rq_init_dz[24]), .sel(dz_in));
    mux2_1 u_rqi_25(.y(rq_init[25]), .a(rq_init_normal[25]), .b(rq_init_dz[25]), .sel(dz_in));
    mux2_1 u_rqi_26(.y(rq_init[26]), .a(rq_init_normal[26]), .b(rq_init_dz[26]), .sel(dz_in));
    mux2_1 u_rqi_27(.y(rq_init[27]), .a(rq_init_normal[27]), .b(rq_init_dz[27]), .sel(dz_in));
    mux2_1 u_rqi_28(.y(rq_init[28]), .a(rq_init_normal[28]), .b(rq_init_dz[28]), .sel(dz_in));
    mux2_1 u_rqi_29(.y(rq_init[29]), .a(rq_init_normal[29]), .b(rq_init_dz[29]), .sel(dz_in));
    mux2_1 u_rqi_30(.y(rq_init[30]), .a(rq_init_normal[30]), .b(rq_init_dz[30]), .sel(dz_in));
    mux2_1 u_rqi_31(.y(rq_init[31]), .a(rq_init_normal[31]), .b(rq_init_dz[31]), .sel(dz_in));
    mux2_1 u_rqi_32(.y(rq_init[32]), .a(rq_init_normal[32]), .b(rq_init_dz[32]), .sel(dz_in));
    mux2_1 u_rqi_33(.y(rq_init[33]), .a(rq_init_normal[33]), .b(rq_init_dz[33]), .sel(dz_in));
    mux2_1 u_rqi_34(.y(rq_init[34]), .a(rq_init_normal[34]), .b(rq_init_dz[34]), .sel(dz_in));
    mux2_1 u_rqi_35(.y(rq_init[35]), .a(rq_init_normal[35]), .b(rq_init_dz[35]), .sel(dz_in));
    mux2_1 u_rqi_36(.y(rq_init[36]), .a(rq_init_normal[36]), .b(rq_init_dz[36]), .sel(dz_in));
    mux2_1 u_rqi_37(.y(rq_init[37]), .a(rq_init_normal[37]), .b(rq_init_dz[37]), .sel(dz_in));
    mux2_1 u_rqi_38(.y(rq_init[38]), .a(rq_init_normal[38]), .b(rq_init_dz[38]), .sel(dz_in));
    mux2_1 u_rqi_39(.y(rq_init[39]), .a(rq_init_normal[39]), .b(rq_init_dz[39]), .sel(dz_in));
    mux2_1 u_rqi_40(.y(rq_init[40]), .a(rq_init_normal[40]), .b(rq_init_dz[40]), .sel(dz_in));
    mux2_1 u_rqi_41(.y(rq_init[41]), .a(rq_init_normal[41]), .b(rq_init_dz[41]), .sel(dz_in));
    mux2_1 u_rqi_42(.y(rq_init[42]), .a(rq_init_normal[42]), .b(rq_init_dz[42]), .sel(dz_in));
    mux2_1 u_rqi_43(.y(rq_init[43]), .a(rq_init_normal[43]), .b(rq_init_dz[43]), .sel(dz_in));
    mux2_1 u_rqi_44(.y(rq_init[44]), .a(rq_init_normal[44]), .b(rq_init_dz[44]), .sel(dz_in));
    mux2_1 u_rqi_45(.y(rq_init[45]), .a(rq_init_normal[45]), .b(rq_init_dz[45]), .sel(dz_in));
    mux2_1 u_rqi_46(.y(rq_init[46]), .a(rq_init_normal[46]), .b(rq_init_dz[46]), .sel(dz_in));
    mux2_1 u_rqi_47(.y(rq_init[47]), .a(rq_init_normal[47]), .b(rq_init_dz[47]), .sel(dz_in));
    mux2_1 u_rqi_48(.y(rq_init[48]), .a(rq_init_normal[48]), .b(rq_init_dz[48]), .sel(dz_in));
    mux2_1 u_rqi_49(.y(rq_init[49]), .a(rq_init_normal[49]), .b(rq_init_dz[49]), .sel(dz_in));
    mux2_1 u_rqi_50(.y(rq_init[50]), .a(rq_init_normal[50]), .b(rq_init_dz[50]), .sel(dz_in));
    mux2_1 u_rqi_51(.y(rq_init[51]), .a(rq_init_normal[51]), .b(rq_init_dz[51]), .sel(dz_in));
    mux2_1 u_rqi_52(.y(rq_init[52]), .a(rq_init_normal[52]), .b(rq_init_dz[52]), .sel(dz_in));
    mux2_1 u_rqi_53(.y(rq_init[53]), .a(rq_init_normal[53]), .b(rq_init_dz[53]), .sel(dz_in));
    mux2_1 u_rqi_54(.y(rq_init[54]), .a(rq_init_normal[54]), .b(rq_init_dz[54]), .sel(dz_in));
    mux2_1 u_rqi_55(.y(rq_init[55]), .a(rq_init_normal[55]), .b(rq_init_dz[55]), .sel(dz_in));
    mux2_1 u_rqi_56(.y(rq_init[56]), .a(rq_init_normal[56]), .b(rq_init_dz[56]), .sel(dz_in));
    mux2_1 u_rqi_57(.y(rq_init[57]), .a(rq_init_normal[57]), .b(rq_init_dz[57]), .sel(dz_in));
    mux2_1 u_rqi_58(.y(rq_init[58]), .a(rq_init_normal[58]), .b(rq_init_dz[58]), .sel(dz_in));
    mux2_1 u_rqi_59(.y(rq_init[59]), .a(rq_init_normal[59]), .b(rq_init_dz[59]), .sel(dz_in));
    mux2_1 u_rqi_60(.y(rq_init[60]), .a(rq_init_normal[60]), .b(rq_init_dz[60]), .sel(dz_in));
    mux2_1 u_rqi_61(.y(rq_init[61]), .a(rq_init_normal[61]), .b(rq_init_dz[61]), .sel(dz_in));
    mux2_1 u_rqi_62(.y(rq_init[62]), .a(rq_init_normal[62]), .b(rq_init_dz[62]), .sel(dz_in));
    mux2_1 u_rqi_63(.y(rq_init[63]), .a(rq_init_normal[63]), .b(rq_init_dz[63]), .sel(dz_in));
    mux2_1 u_rqi_64(.y(rq_init[64]), .a(rq_init_normal[64]), .b(rq_init_dz[64]), .sel(dz_in));
    mux2_1 u_rqi_65(.y(rq_init[65]), .a(rq_init_normal[65]), .b(rq_init_dz[65]), .sel(dz_in));
    mux2_1 u_rqi_66(.y(rq_init[66]), .a(rq_init_normal[66]), .b(rq_init_dz[66]), .sel(dz_in));
    mux2_1 u_rqi_67(.y(rq_init[67]), .a(rq_init_normal[67]), .b(rq_init_dz[67]), .sel(dz_in));
    mux2_1 u_rqi_68(.y(rq_init[68]), .a(rq_init_normal[68]), .b(rq_init_dz[68]), .sel(dz_in));
    mux2_1 u_rqi_69(.y(rq_init[69]), .a(rq_init_normal[69]), .b(rq_init_dz[69]), .sel(dz_in));
    mux2_1 u_rqi_70(.y(rq_init[70]), .a(rq_init_normal[70]), .b(rq_init_dz[70]), .sel(dz_in));
    mux2_1 u_rqi_71(.y(rq_init[71]), .a(rq_init_normal[71]), .b(rq_init_dz[71]), .sel(dz_in));
    mux2_1 u_rqi_72(.y(rq_init[72]), .a(rq_init_normal[72]), .b(rq_init_dz[72]), .sel(dz_in));
    mux2_1 u_rqi_73(.y(rq_init[73]), .a(rq_init_normal[73]), .b(rq_init_dz[73]), .sel(dz_in));
    mux2_1 u_rqi_74(.y(rq_init[74]), .a(rq_init_normal[74]), .b(rq_init_dz[74]), .sel(dz_in));
    mux2_1 u_rqi_75(.y(rq_init[75]), .a(rq_init_normal[75]), .b(rq_init_dz[75]), .sel(dz_in));
    mux2_1 u_rqi_76(.y(rq_init[76]), .a(rq_init_normal[76]), .b(rq_init_dz[76]), .sel(dz_in));
    mux2_1 u_rqi_77(.y(rq_init[77]), .a(rq_init_normal[77]), .b(rq_init_dz[77]), .sel(dz_in));
    mux2_1 u_rqi_78(.y(rq_init[78]), .a(rq_init_normal[78]), .b(rq_init_dz[78]), .sel(dz_in));
    mux2_1 u_rqi_79(.y(rq_init[79]), .a(rq_init_normal[79]), .b(rq_init_dz[79]), .sel(dz_in));
    mux2_1 u_rqi_80(.y(rq_init[80]), .a(rq_init_normal[80]), .b(rq_init_dz[80]), .sel(dz_in));
    mux2_1 u_rqi_81(.y(rq_init[81]), .a(rq_init_normal[81]), .b(rq_init_dz[81]), .sel(dz_in));
    mux2_1 u_rqi_82(.y(rq_init[82]), .a(rq_init_normal[82]), .b(rq_init_dz[82]), .sel(dz_in));
    mux2_1 u_rqi_83(.y(rq_init[83]), .a(rq_init_normal[83]), .b(rq_init_dz[83]), .sel(dz_in));
    mux2_1 u_rqi_84(.y(rq_init[84]), .a(rq_init_normal[84]), .b(rq_init_dz[84]), .sel(dz_in));
    mux2_1 u_rqi_85(.y(rq_init[85]), .a(rq_init_normal[85]), .b(rq_init_dz[85]), .sel(dz_in));
    mux2_1 u_rqi_86(.y(rq_init[86]), .a(rq_init_normal[86]), .b(rq_init_dz[86]), .sel(dz_in));
    mux2_1 u_rqi_87(.y(rq_init[87]), .a(rq_init_normal[87]), .b(rq_init_dz[87]), .sel(dz_in));
    mux2_1 u_rqi_88(.y(rq_init[88]), .a(rq_init_normal[88]), .b(rq_init_dz[88]), .sel(dz_in));
    mux2_1 u_rqi_89(.y(rq_init[89]), .a(rq_init_normal[89]), .b(rq_init_dz[89]), .sel(dz_in));
    mux2_1 u_rqi_90(.y(rq_init[90]), .a(rq_init_normal[90]), .b(rq_init_dz[90]), .sel(dz_in));
    mux2_1 u_rqi_91(.y(rq_init[91]), .a(rq_init_normal[91]), .b(rq_init_dz[91]), .sel(dz_in));
    mux2_1 u_rqi_92(.y(rq_init[92]), .a(rq_init_normal[92]), .b(rq_init_dz[92]), .sel(dz_in));
    mux2_1 u_rqi_93(.y(rq_init[93]), .a(rq_init_normal[93]), .b(rq_init_dz[93]), .sel(dz_in));
    mux2_1 u_rqi_94(.y(rq_init[94]), .a(rq_init_normal[94]), .b(rq_init_dz[94]), .sel(dz_in));
    mux2_1 u_rqi_95(.y(rq_init[95]), .a(rq_init_normal[95]), .b(rq_init_dz[95]), .sel(dz_in));
    mux2_1 u_rqi_96(.y(rq_init[96]), .a(rq_init_normal[96]), .b(rq_init_dz[96]), .sel(dz_in));
    mux2_1 u_rqi_97(.y(rq_init[97]), .a(rq_init_normal[97]), .b(rq_init_dz[97]), .sel(dz_in));
    mux2_1 u_rqi_98(.y(rq_init[98]), .a(rq_init_normal[98]), .b(rq_init_dz[98]), .sel(dz_in));
    mux2_1 u_rqi_99(.y(rq_init[99]), .a(rq_init_normal[99]), .b(rq_init_dz[99]), .sel(dz_in));
    mux2_1 u_rqi_100(.y(rq_init[100]), .a(rq_init_normal[100]), .b(rq_init_dz[100]), .sel(dz_in));
    mux2_1 u_rqi_101(.y(rq_init[101]), .a(rq_init_normal[101]), .b(rq_init_dz[101]), .sel(dz_in));
    mux2_1 u_rqi_102(.y(rq_init[102]), .a(rq_init_normal[102]), .b(rq_init_dz[102]), .sel(dz_in));
    mux2_1 u_rqi_103(.y(rq_init[103]), .a(rq_init_normal[103]), .b(rq_init_dz[103]), .sel(dz_in));
    mux2_1 u_rqi_104(.y(rq_init[104]), .a(rq_init_normal[104]), .b(rq_init_dz[104]), .sel(dz_in));
    mux2_1 u_rqi_105(.y(rq_init[105]), .a(rq_init_normal[105]), .b(rq_init_dz[105]), .sel(dz_in));
    mux2_1 u_rqi_106(.y(rq_init[106]), .a(rq_init_normal[106]), .b(rq_init_dz[106]), .sel(dz_in));
    mux2_1 u_rqi_107(.y(rq_init[107]), .a(rq_init_normal[107]), .b(rq_init_dz[107]), .sel(dz_in));
    mux2_1 u_rqi_108(.y(rq_init[108]), .a(rq_init_normal[108]), .b(rq_init_dz[108]), .sel(dz_in));
    mux2_1 u_rqi_109(.y(rq_init[109]), .a(rq_init_normal[109]), .b(rq_init_dz[109]), .sel(dz_in));
    mux2_1 u_rqi_110(.y(rq_init[110]), .a(rq_init_normal[110]), .b(rq_init_dz[110]), .sel(dz_in));
    mux2_1 u_rqi_111(.y(rq_init[111]), .a(rq_init_normal[111]), .b(rq_init_dz[111]), .sel(dz_in));
    mux2_1 u_rqi_112(.y(rq_init[112]), .a(rq_init_normal[112]), .b(rq_init_dz[112]), .sel(dz_in));
    mux2_1 u_rqi_113(.y(rq_init[113]), .a(rq_init_normal[113]), .b(rq_init_dz[113]), .sel(dz_in));
    mux2_1 u_rqi_114(.y(rq_init[114]), .a(rq_init_normal[114]), .b(rq_init_dz[114]), .sel(dz_in));
    mux2_1 u_rqi_115(.y(rq_init[115]), .a(rq_init_normal[115]), .b(rq_init_dz[115]), .sel(dz_in));
    mux2_1 u_rqi_116(.y(rq_init[116]), .a(rq_init_normal[116]), .b(rq_init_dz[116]), .sel(dz_in));
    mux2_1 u_rqi_117(.y(rq_init[117]), .a(rq_init_normal[117]), .b(rq_init_dz[117]), .sel(dz_in));
    mux2_1 u_rqi_118(.y(rq_init[118]), .a(rq_init_normal[118]), .b(rq_init_dz[118]), .sel(dz_in));
    mux2_1 u_rqi_119(.y(rq_init[119]), .a(rq_init_normal[119]), .b(rq_init_dz[119]), .sel(dz_in));
    mux2_1 u_rqi_120(.y(rq_init[120]), .a(rq_init_normal[120]), .b(rq_init_dz[120]), .sel(dz_in));
    mux2_1 u_rqi_121(.y(rq_init[121]), .a(rq_init_normal[121]), .b(rq_init_dz[121]), .sel(dz_in));
    mux2_1 u_rqi_122(.y(rq_init[122]), .a(rq_init_normal[122]), .b(rq_init_dz[122]), .sel(dz_in));
    mux2_1 u_rqi_123(.y(rq_init[123]), .a(rq_init_normal[123]), .b(rq_init_dz[123]), .sel(dz_in));
    mux2_1 u_rqi_124(.y(rq_init[124]), .a(rq_init_normal[124]), .b(rq_init_dz[124]), .sel(dz_in));
    mux2_1 u_rqi_125(.y(rq_init[125]), .a(rq_init_normal[125]), .b(rq_init_dz[125]), .sel(dz_in));
    mux2_1 u_rqi_126(.y(rq_init[126]), .a(rq_init_normal[126]), .b(rq_init_dz[126]), .sel(dz_in));
    mux2_1 u_rqi_127(.y(rq_init[127]), .a(rq_init_normal[127]), .b(rq_init_dz[127]), .sel(dz_in));
    
    wire [6:0] counter_init;
    assign counter_init = {dz_in, 6'b0};

    //  rq_reg REGISTER — 128-bit (2x dff64)
    //  div_reg REGISTER — 64-bit (1x dff64)
    wire [127:0] rq_reg, next_rq;
    wire [63:0] div_reg, next_div;

    //  ITERATION combinational logic
    //      shifted    = {rq_reg[126:0], 1'b0}                  (1-bit left shift)
    //      trial_sum  = shifted[127:64] + ~div_reg + 1   = R - div_reg
    //      trial_cout = 1  ⇔  R >= div_reg
    //      new_R = trial_cout ? trial_sum : shifted[127:64]    (mux2_1_64)
    //      q_bit = trial_cout
    //      rq_iter = {new_R, shifted[63:1], q_bit}
    wire [127:0] shifted;
    assign shifted = {rq_reg[126:0], 1'b0};

    wire [63:0] div_reg_inv;
    not n_dr_inv_00(div_reg_inv[0], div_reg[0]);
    not n_dr_inv_01(div_reg_inv[1], div_reg[1]);
    not n_dr_inv_02(div_reg_inv[2], div_reg[2]);
    not n_dr_inv_03(div_reg_inv[3], div_reg[3]);
    not n_dr_inv_04(div_reg_inv[4], div_reg[4]);
    not n_dr_inv_05(div_reg_inv[5], div_reg[5]);
    not n_dr_inv_06(div_reg_inv[6], div_reg[6]);
    not n_dr_inv_07(div_reg_inv[7], div_reg[7]);
    not n_dr_inv_08(div_reg_inv[8], div_reg[8]);
    not n_dr_inv_09(div_reg_inv[9], div_reg[9]);
    not n_dr_inv_10(div_reg_inv[10], div_reg[10]);
    not n_dr_inv_11(div_reg_inv[11], div_reg[11]);
    not n_dr_inv_12(div_reg_inv[12], div_reg[12]);
    not n_dr_inv_13(div_reg_inv[13], div_reg[13]);
    not n_dr_inv_14(div_reg_inv[14], div_reg[14]);
    not n_dr_inv_15(div_reg_inv[15], div_reg[15]);
    not n_dr_inv_16(div_reg_inv[16], div_reg[16]);
    not n_dr_inv_17(div_reg_inv[17], div_reg[17]);
    not n_dr_inv_18(div_reg_inv[18], div_reg[18]);
    not n_dr_inv_19(div_reg_inv[19], div_reg[19]);
    not n_dr_inv_20(div_reg_inv[20], div_reg[20]);
    not n_dr_inv_21(div_reg_inv[21], div_reg[21]);
    not n_dr_inv_22(div_reg_inv[22], div_reg[22]);
    not n_dr_inv_23(div_reg_inv[23], div_reg[23]);
    not n_dr_inv_24(div_reg_inv[24], div_reg[24]);
    not n_dr_inv_25(div_reg_inv[25], div_reg[25]);
    not n_dr_inv_26(div_reg_inv[26], div_reg[26]);
    not n_dr_inv_27(div_reg_inv[27], div_reg[27]);
    not n_dr_inv_28(div_reg_inv[28], div_reg[28]);
    not n_dr_inv_29(div_reg_inv[29], div_reg[29]);
    not n_dr_inv_30(div_reg_inv[30], div_reg[30]);
    not n_dr_inv_31(div_reg_inv[31], div_reg[31]);
    not n_dr_inv_32(div_reg_inv[32], div_reg[32]);
    not n_dr_inv_33(div_reg_inv[33], div_reg[33]);
    not n_dr_inv_34(div_reg_inv[34], div_reg[34]);
    not n_dr_inv_35(div_reg_inv[35], div_reg[35]);
    not n_dr_inv_36(div_reg_inv[36], div_reg[36]);
    not n_dr_inv_37(div_reg_inv[37], div_reg[37]);
    not n_dr_inv_38(div_reg_inv[38], div_reg[38]);
    not n_dr_inv_39(div_reg_inv[39], div_reg[39]);
    not n_dr_inv_40(div_reg_inv[40], div_reg[40]);
    not n_dr_inv_41(div_reg_inv[41], div_reg[41]);
    not n_dr_inv_42(div_reg_inv[42], div_reg[42]);
    not n_dr_inv_43(div_reg_inv[43], div_reg[43]);
    not n_dr_inv_44(div_reg_inv[44], div_reg[44]);
    not n_dr_inv_45(div_reg_inv[45], div_reg[45]);
    not n_dr_inv_46(div_reg_inv[46], div_reg[46]);
    not n_dr_inv_47(div_reg_inv[47], div_reg[47]);
    not n_dr_inv_48(div_reg_inv[48], div_reg[48]);
    not n_dr_inv_49(div_reg_inv[49], div_reg[49]);
    not n_dr_inv_50(div_reg_inv[50], div_reg[50]);
    not n_dr_inv_51(div_reg_inv[51], div_reg[51]);
    not n_dr_inv_52(div_reg_inv[52], div_reg[52]);
    not n_dr_inv_53(div_reg_inv[53], div_reg[53]);
    not n_dr_inv_54(div_reg_inv[54], div_reg[54]);
    not n_dr_inv_55(div_reg_inv[55], div_reg[55]);
    not n_dr_inv_56(div_reg_inv[56], div_reg[56]);
    not n_dr_inv_57(div_reg_inv[57], div_reg[57]);
    not n_dr_inv_58(div_reg_inv[58], div_reg[58]);
    not n_dr_inv_59(div_reg_inv[59], div_reg[59]);
    not n_dr_inv_60(div_reg_inv[60], div_reg[60]);
    not n_dr_inv_61(div_reg_inv[61], div_reg[61]);
    not n_dr_inv_62(div_reg_inv[62], div_reg[62]);
    not n_dr_inv_63(div_reg_inv[63], div_reg[63]);

    wire [63:0] trial_sum;
    wire trial_cout;
    
    adder64 u_trial(
        .sum(trial_sum),
        .cout(trial_cout),
        .a(shifted[127:64]),
        .b(div_reg_inv),
        .cin(1'b1)
    );

    wire [63:0] new_R;
    mux2_1_64 u_new_r(
        .y(new_R),
        .a(shifted[127:64]),
        .b(trial_sum),
        .sel(trial_cout)
    );

    wire [127:0] rq_iter;
    assign rq_iter = {new_R, shifted[63:1], trial_cout};

    //  COUNTER register — 7-bit (7x dff)
    //  counter_p1 = counter + 1 (gate-level half_adder ripple chain)
    wire [6:0] counter, next_counter;

    wire [6:0] counter_p1;
    wire [5:0] cc;
    half_adder ha_c0(.sum(counter_p1[0]), .cout(cc[0]), .a(counter[0]), .b(1'b1));
    half_adder ha_c1(.sum(counter_p1[1]), .cout(cc[1]), .a(counter[1]), .b(cc[0]));
    half_adder ha_c2(.sum(counter_p1[2]), .cout(cc[2]), .a(counter[2]), .b(cc[1]));
    half_adder ha_c3(.sum(counter_p1[3]), .cout(cc[3]), .a(counter[3]), .b(cc[2]));
    half_adder ha_c4(.sum(counter_p1[4]), .cout(cc[4]), .a(counter[4]), .b(cc[3]));
    half_adder ha_c5(.sum(counter_p1[5]), .cout(cc[5]), .a(counter[5]), .b(cc[4]));
    half_adder ha_c6(.sum(counter_p1[6]), .cout(), .a(counter[6]), .b(cc[5]));

    // iter_done = counter == 64 <-> counter[6] == 1
    wire iter_done;
    assign iter_done = counter[6];

    //  FSM NEXT-STATE LOGIC
    //
    //      idle_start = is_idle & start           (load init values)
    //      busy_iter  = is_busy & ~iter_done      (do iter, increment counter)
    //      busy_done  = is_busy &  iter_done      (transition to DONE)
    //
    //      next_state[0] = idle_start | busy_iter      (BUSY = 01)
    //      next_state[1] = busy_done                   (DONE = 10)
    //      All other cycles → next_state = 00 (IDLE), default safe
    wire idle_start;
    and a_is(idle_start, is_idle, start);

    wire n_iter_done;
    not n_id(n_iter_done, iter_done);

    wire busy_iter, busy_done;
    and a_bi(busy_iter, is_busy, n_iter_done);
    and a_bd(busy_done, is_busy, iter_done);

    or o_ns0(next_state[0], idle_start, busy_iter);
    assign next_state[1] = busy_done;

    //  COUNTER NEXT — 3-way select (load-init / increment / hold)
    //      idle_start -> counter_init
    //      busy_iter  -> counter_p1
    //      else       -> counter (hold)
    //
    //  Two-stage mux:
    //      cnt_inner   = busy_iter  ? counter_p1   : counter
    //      next_counter= idle_start ? counter_init : cnt_inner
    wire [6:0] cnt_inner;
    mux2_1 u_cnt_inner_0(.y(cnt_inner[0]), .a(counter[0]), .b(counter_p1[0]), .sel(busy_iter));
    mux2_1 u_cnt_inner_1(.y(cnt_inner[1]), .a(counter[1]), .b(counter_p1[1]), .sel(busy_iter));
    mux2_1 u_cnt_inner_2(.y(cnt_inner[2]), .a(counter[2]), .b(counter_p1[2]), .sel(busy_iter));
    mux2_1 u_cnt_inner_3(.y(cnt_inner[3]), .a(counter[3]), .b(counter_p1[3]), .sel(busy_iter));
    mux2_1 u_cnt_inner_4(.y(cnt_inner[4]), .a(counter[4]), .b(counter_p1[4]), .sel(busy_iter));
    mux2_1 u_cnt_inner_5(.y(cnt_inner[5]), .a(counter[5]), .b(counter_p1[5]), .sel(busy_iter));
    mux2_1 u_cnt_inner_6(.y(cnt_inner[6]), .a(counter[6]), .b(counter_p1[6]), .sel(busy_iter));

    mux2_1 u_cnt_next_0(.y(next_counter[0]), .a(cnt_inner[0]), .b(counter_init[0]), .sel(idle_start));
    mux2_1 u_cnt_next_1(.y(next_counter[1]), .a(cnt_inner[1]), .b(counter_init[1]), .sel(idle_start));
    mux2_1 u_cnt_next_2(.y(next_counter[2]), .a(cnt_inner[2]), .b(counter_init[2]), .sel(idle_start));
    mux2_1 u_cnt_next_3(.y(next_counter[3]), .a(cnt_inner[3]), .b(counter_init[3]), .sel(idle_start));
    mux2_1 u_cnt_next_4(.y(next_counter[4]), .a(cnt_inner[4]), .b(counter_init[4]), .sel(idle_start));
    mux2_1 u_cnt_next_5(.y(next_counter[5]), .a(cnt_inner[5]), .b(counter_init[5]), .sel(idle_start));
    mux2_1 u_cnt_next_6(.y(next_counter[6]), .a(cnt_inner[6]), .b(counter_init[6]), .sel(idle_start));

    //  rq_reg NEXT — same 3-way select
    //      idle_start -> rq_init
    //      busy_iter  -> rq_iter
    //      else       -> rq_reg (hold)
    wire [127:0] rq_inner;
    mux2_1 u_rq_inner_00(.y(rq_inner[0]), .a(rq_reg[0]), .b(rq_iter[0]), .sel(busy_iter));
    mux2_1 u_rq_inner_01(.y(rq_inner[1]), .a(rq_reg[1]), .b(rq_iter[1]), .sel(busy_iter));
    mux2_1 u_rq_inner_02(.y(rq_inner[2]), .a(rq_reg[2]), .b(rq_iter[2]), .sel(busy_iter));
    mux2_1 u_rq_inner_03(.y(rq_inner[3]), .a(rq_reg[3]), .b(rq_iter[3]), .sel(busy_iter));
    mux2_1 u_rq_inner_04(.y(rq_inner[4]), .a(rq_reg[4]), .b(rq_iter[4]), .sel(busy_iter));
    mux2_1 u_rq_inner_05(.y(rq_inner[5]), .a(rq_reg[5]), .b(rq_iter[5]), .sel(busy_iter));
    mux2_1 u_rq_inner_06(.y(rq_inner[6]), .a(rq_reg[6]), .b(rq_iter[6]), .sel(busy_iter));
    mux2_1 u_rq_inner_07(.y(rq_inner[7]), .a(rq_reg[7]), .b(rq_iter[7]), .sel(busy_iter));
    mux2_1 u_rq_inner_08(.y(rq_inner[8]), .a(rq_reg[8]), .b(rq_iter[8]), .sel(busy_iter));
    mux2_1 u_rq_inner_09(.y(rq_inner[9]), .a(rq_reg[9]), .b(rq_iter[9]), .sel(busy_iter));
    mux2_1 u_rq_inner_10(.y(rq_inner[10]), .a(rq_reg[10]), .b(rq_iter[10]), .sel(busy_iter));
    mux2_1 u_rq_inner_11(.y(rq_inner[11]), .a(rq_reg[11]), .b(rq_iter[11]), .sel(busy_iter));
    mux2_1 u_rq_inner_12(.y(rq_inner[12]), .a(rq_reg[12]), .b(rq_iter[12]), .sel(busy_iter));
    mux2_1 u_rq_inner_13(.y(rq_inner[13]), .a(rq_reg[13]), .b(rq_iter[13]), .sel(busy_iter));
    mux2_1 u_rq_inner_14(.y(rq_inner[14]), .a(rq_reg[14]), .b(rq_iter[14]), .sel(busy_iter));
    mux2_1 u_rq_inner_15(.y(rq_inner[15]), .a(rq_reg[15]), .b(rq_iter[15]), .sel(busy_iter));
    mux2_1 u_rq_inner_16(.y(rq_inner[16]), .a(rq_reg[16]), .b(rq_iter[16]), .sel(busy_iter));
    mux2_1 u_rq_inner_17(.y(rq_inner[17]), .a(rq_reg[17]), .b(rq_iter[17]), .sel(busy_iter));
    mux2_1 u_rq_inner_18(.y(rq_inner[18]), .a(rq_reg[18]), .b(rq_iter[18]), .sel(busy_iter));
    mux2_1 u_rq_inner_19(.y(rq_inner[19]), .a(rq_reg[19]), .b(rq_iter[19]), .sel(busy_iter));
    mux2_1 u_rq_inner_20(.y(rq_inner[20]), .a(rq_reg[20]), .b(rq_iter[20]), .sel(busy_iter));
    mux2_1 u_rq_inner_21(.y(rq_inner[21]), .a(rq_reg[21]), .b(rq_iter[21]), .sel(busy_iter));
    mux2_1 u_rq_inner_22(.y(rq_inner[22]), .a(rq_reg[22]), .b(rq_iter[22]), .sel(busy_iter));
    mux2_1 u_rq_inner_23(.y(rq_inner[23]), .a(rq_reg[23]), .b(rq_iter[23]), .sel(busy_iter));
    mux2_1 u_rq_inner_24(.y(rq_inner[24]), .a(rq_reg[24]), .b(rq_iter[24]), .sel(busy_iter));
    mux2_1 u_rq_inner_25(.y(rq_inner[25]), .a(rq_reg[25]), .b(rq_iter[25]), .sel(busy_iter));
    mux2_1 u_rq_inner_26(.y(rq_inner[26]), .a(rq_reg[26]), .b(rq_iter[26]), .sel(busy_iter));
    mux2_1 u_rq_inner_27(.y(rq_inner[27]), .a(rq_reg[27]), .b(rq_iter[27]), .sel(busy_iter));
    mux2_1 u_rq_inner_28(.y(rq_inner[28]), .a(rq_reg[28]), .b(rq_iter[28]), .sel(busy_iter));
    mux2_1 u_rq_inner_29(.y(rq_inner[29]), .a(rq_reg[29]), .b(rq_iter[29]), .sel(busy_iter));
    mux2_1 u_rq_inner_30(.y(rq_inner[30]), .a(rq_reg[30]), .b(rq_iter[30]), .sel(busy_iter));
    mux2_1 u_rq_inner_31(.y(rq_inner[31]), .a(rq_reg[31]), .b(rq_iter[31]), .sel(busy_iter));
    mux2_1 u_rq_inner_32(.y(rq_inner[32]), .a(rq_reg[32]), .b(rq_iter[32]), .sel(busy_iter));
    mux2_1 u_rq_inner_33(.y(rq_inner[33]), .a(rq_reg[33]), .b(rq_iter[33]), .sel(busy_iter));
    mux2_1 u_rq_inner_34(.y(rq_inner[34]), .a(rq_reg[34]), .b(rq_iter[34]), .sel(busy_iter));
    mux2_1 u_rq_inner_35(.y(rq_inner[35]), .a(rq_reg[35]), .b(rq_iter[35]), .sel(busy_iter));
    mux2_1 u_rq_inner_36(.y(rq_inner[36]), .a(rq_reg[36]), .b(rq_iter[36]), .sel(busy_iter));
    mux2_1 u_rq_inner_37(.y(rq_inner[37]), .a(rq_reg[37]), .b(rq_iter[37]), .sel(busy_iter));
    mux2_1 u_rq_inner_38(.y(rq_inner[38]), .a(rq_reg[38]), .b(rq_iter[38]), .sel(busy_iter));
    mux2_1 u_rq_inner_39(.y(rq_inner[39]), .a(rq_reg[39]), .b(rq_iter[39]), .sel(busy_iter));
    mux2_1 u_rq_inner_40(.y(rq_inner[40]), .a(rq_reg[40]), .b(rq_iter[40]), .sel(busy_iter));
    mux2_1 u_rq_inner_41(.y(rq_inner[41]), .a(rq_reg[41]), .b(rq_iter[41]), .sel(busy_iter));
    mux2_1 u_rq_inner_42(.y(rq_inner[42]), .a(rq_reg[42]), .b(rq_iter[42]), .sel(busy_iter));
    mux2_1 u_rq_inner_43(.y(rq_inner[43]), .a(rq_reg[43]), .b(rq_iter[43]), .sel(busy_iter));
    mux2_1 u_rq_inner_44(.y(rq_inner[44]), .a(rq_reg[44]), .b(rq_iter[44]), .sel(busy_iter));
    mux2_1 u_rq_inner_45(.y(rq_inner[45]), .a(rq_reg[45]), .b(rq_iter[45]), .sel(busy_iter));
    mux2_1 u_rq_inner_46(.y(rq_inner[46]), .a(rq_reg[46]), .b(rq_iter[46]), .sel(busy_iter));
    mux2_1 u_rq_inner_47(.y(rq_inner[47]), .a(rq_reg[47]), .b(rq_iter[47]), .sel(busy_iter));
    mux2_1 u_rq_inner_48(.y(rq_inner[48]), .a(rq_reg[48]), .b(rq_iter[48]), .sel(busy_iter));
    mux2_1 u_rq_inner_49(.y(rq_inner[49]), .a(rq_reg[49]), .b(rq_iter[49]), .sel(busy_iter));
    mux2_1 u_rq_inner_50(.y(rq_inner[50]), .a(rq_reg[50]), .b(rq_iter[50]), .sel(busy_iter));
    mux2_1 u_rq_inner_51(.y(rq_inner[51]), .a(rq_reg[51]), .b(rq_iter[51]), .sel(busy_iter));
    mux2_1 u_rq_inner_52(.y(rq_inner[52]), .a(rq_reg[52]), .b(rq_iter[52]), .sel(busy_iter));
    mux2_1 u_rq_inner_53(.y(rq_inner[53]), .a(rq_reg[53]), .b(rq_iter[53]), .sel(busy_iter));
    mux2_1 u_rq_inner_54(.y(rq_inner[54]), .a(rq_reg[54]), .b(rq_iter[54]), .sel(busy_iter));
    mux2_1 u_rq_inner_55(.y(rq_inner[55]), .a(rq_reg[55]), .b(rq_iter[55]), .sel(busy_iter));
    mux2_1 u_rq_inner_56(.y(rq_inner[56]), .a(rq_reg[56]), .b(rq_iter[56]), .sel(busy_iter));
    mux2_1 u_rq_inner_57(.y(rq_inner[57]), .a(rq_reg[57]), .b(rq_iter[57]), .sel(busy_iter));
    mux2_1 u_rq_inner_58(.y(rq_inner[58]), .a(rq_reg[58]), .b(rq_iter[58]), .sel(busy_iter));
    mux2_1 u_rq_inner_59(.y(rq_inner[59]), .a(rq_reg[59]), .b(rq_iter[59]), .sel(busy_iter));
    mux2_1 u_rq_inner_60(.y(rq_inner[60]), .a(rq_reg[60]), .b(rq_iter[60]), .sel(busy_iter));
    mux2_1 u_rq_inner_61(.y(rq_inner[61]), .a(rq_reg[61]), .b(rq_iter[61]), .sel(busy_iter));
    mux2_1 u_rq_inner_62(.y(rq_inner[62]), .a(rq_reg[62]), .b(rq_iter[62]), .sel(busy_iter));
    mux2_1 u_rq_inner_63(.y(rq_inner[63]), .a(rq_reg[63]), .b(rq_iter[63]), .sel(busy_iter));
    mux2_1 u_rq_inner_64(.y(rq_inner[64]), .a(rq_reg[64]), .b(rq_iter[64]), .sel(busy_iter));
    mux2_1 u_rq_inner_65(.y(rq_inner[65]), .a(rq_reg[65]), .b(rq_iter[65]), .sel(busy_iter));
    mux2_1 u_rq_inner_66(.y(rq_inner[66]), .a(rq_reg[66]), .b(rq_iter[66]), .sel(busy_iter));
    mux2_1 u_rq_inner_67(.y(rq_inner[67]), .a(rq_reg[67]), .b(rq_iter[67]), .sel(busy_iter));
    mux2_1 u_rq_inner_68(.y(rq_inner[68]), .a(rq_reg[68]), .b(rq_iter[68]), .sel(busy_iter));
    mux2_1 u_rq_inner_69(.y(rq_inner[69]), .a(rq_reg[69]), .b(rq_iter[69]), .sel(busy_iter));
    mux2_1 u_rq_inner_70(.y(rq_inner[70]), .a(rq_reg[70]), .b(rq_iter[70]), .sel(busy_iter));
    mux2_1 u_rq_inner_71(.y(rq_inner[71]), .a(rq_reg[71]), .b(rq_iter[71]), .sel(busy_iter));
    mux2_1 u_rq_inner_72(.y(rq_inner[72]), .a(rq_reg[72]), .b(rq_iter[72]), .sel(busy_iter));
    mux2_1 u_rq_inner_73(.y(rq_inner[73]), .a(rq_reg[73]), .b(rq_iter[73]), .sel(busy_iter));
    mux2_1 u_rq_inner_74(.y(rq_inner[74]), .a(rq_reg[74]), .b(rq_iter[74]), .sel(busy_iter));
    mux2_1 u_rq_inner_75(.y(rq_inner[75]), .a(rq_reg[75]), .b(rq_iter[75]), .sel(busy_iter));
    mux2_1 u_rq_inner_76(.y(rq_inner[76]), .a(rq_reg[76]), .b(rq_iter[76]), .sel(busy_iter));
    mux2_1 u_rq_inner_77(.y(rq_inner[77]), .a(rq_reg[77]), .b(rq_iter[77]), .sel(busy_iter));
    mux2_1 u_rq_inner_78(.y(rq_inner[78]), .a(rq_reg[78]), .b(rq_iter[78]), .sel(busy_iter));
    mux2_1 u_rq_inner_79(.y(rq_inner[79]), .a(rq_reg[79]), .b(rq_iter[79]), .sel(busy_iter));
    mux2_1 u_rq_inner_80(.y(rq_inner[80]), .a(rq_reg[80]), .b(rq_iter[80]), .sel(busy_iter));
    mux2_1 u_rq_inner_81(.y(rq_inner[81]), .a(rq_reg[81]), .b(rq_iter[81]), .sel(busy_iter));
    mux2_1 u_rq_inner_82(.y(rq_inner[82]), .a(rq_reg[82]), .b(rq_iter[82]), .sel(busy_iter));
    mux2_1 u_rq_inner_83(.y(rq_inner[83]), .a(rq_reg[83]), .b(rq_iter[83]), .sel(busy_iter));
    mux2_1 u_rq_inner_84(.y(rq_inner[84]), .a(rq_reg[84]), .b(rq_iter[84]), .sel(busy_iter));
    mux2_1 u_rq_inner_85(.y(rq_inner[85]), .a(rq_reg[85]), .b(rq_iter[85]), .sel(busy_iter));
    mux2_1 u_rq_inner_86(.y(rq_inner[86]), .a(rq_reg[86]), .b(rq_iter[86]), .sel(busy_iter));
    mux2_1 u_rq_inner_87(.y(rq_inner[87]), .a(rq_reg[87]), .b(rq_iter[87]), .sel(busy_iter));
    mux2_1 u_rq_inner_88(.y(rq_inner[88]), .a(rq_reg[88]), .b(rq_iter[88]), .sel(busy_iter));
    mux2_1 u_rq_inner_89(.y(rq_inner[89]), .a(rq_reg[89]), .b(rq_iter[89]), .sel(busy_iter));
    mux2_1 u_rq_inner_90(.y(rq_inner[90]), .a(rq_reg[90]), .b(rq_iter[90]), .sel(busy_iter));
    mux2_1 u_rq_inner_91(.y(rq_inner[91]), .a(rq_reg[91]), .b(rq_iter[91]), .sel(busy_iter));
    mux2_1 u_rq_inner_92(.y(rq_inner[92]), .a(rq_reg[92]), .b(rq_iter[92]), .sel(busy_iter));
    mux2_1 u_rq_inner_93(.y(rq_inner[93]), .a(rq_reg[93]), .b(rq_iter[93]), .sel(busy_iter));
    mux2_1 u_rq_inner_94(.y(rq_inner[94]), .a(rq_reg[94]), .b(rq_iter[94]), .sel(busy_iter));
    mux2_1 u_rq_inner_95(.y(rq_inner[95]), .a(rq_reg[95]), .b(rq_iter[95]), .sel(busy_iter));
    mux2_1 u_rq_inner_96(.y(rq_inner[96]), .a(rq_reg[96]), .b(rq_iter[96]), .sel(busy_iter));
    mux2_1 u_rq_inner_97(.y(rq_inner[97]), .a(rq_reg[97]), .b(rq_iter[97]), .sel(busy_iter));
    mux2_1 u_rq_inner_98(.y(rq_inner[98]), .a(rq_reg[98]), .b(rq_iter[98]), .sel(busy_iter));
    mux2_1 u_rq_inner_99(.y(rq_inner[99]), .a(rq_reg[99]), .b(rq_iter[99]), .sel(busy_iter));
    mux2_1 u_rq_inner_100(.y(rq_inner[100]), .a(rq_reg[100]), .b(rq_iter[100]), .sel(busy_iter));
    mux2_1 u_rq_inner_101(.y(rq_inner[101]), .a(rq_reg[101]), .b(rq_iter[101]), .sel(busy_iter));
    mux2_1 u_rq_inner_102(.y(rq_inner[102]), .a(rq_reg[102]), .b(rq_iter[102]), .sel(busy_iter));
    mux2_1 u_rq_inner_103(.y(rq_inner[103]), .a(rq_reg[103]), .b(rq_iter[103]), .sel(busy_iter));
    mux2_1 u_rq_inner_104(.y(rq_inner[104]), .a(rq_reg[104]), .b(rq_iter[104]), .sel(busy_iter));
    mux2_1 u_rq_inner_105(.y(rq_inner[105]), .a(rq_reg[105]), .b(rq_iter[105]), .sel(busy_iter));
    mux2_1 u_rq_inner_106(.y(rq_inner[106]), .a(rq_reg[106]), .b(rq_iter[106]), .sel(busy_iter));
    mux2_1 u_rq_inner_107(.y(rq_inner[107]), .a(rq_reg[107]), .b(rq_iter[107]), .sel(busy_iter));
    mux2_1 u_rq_inner_108(.y(rq_inner[108]), .a(rq_reg[108]), .b(rq_iter[108]), .sel(busy_iter));
    mux2_1 u_rq_inner_109(.y(rq_inner[109]), .a(rq_reg[109]), .b(rq_iter[109]), .sel(busy_iter));
    mux2_1 u_rq_inner_110(.y(rq_inner[110]), .a(rq_reg[110]), .b(rq_iter[110]), .sel(busy_iter));
    mux2_1 u_rq_inner_111(.y(rq_inner[111]), .a(rq_reg[111]), .b(rq_iter[111]), .sel(busy_iter));
    mux2_1 u_rq_inner_112(.y(rq_inner[112]), .a(rq_reg[112]), .b(rq_iter[112]), .sel(busy_iter));
    mux2_1 u_rq_inner_113(.y(rq_inner[113]), .a(rq_reg[113]), .b(rq_iter[113]), .sel(busy_iter));
    mux2_1 u_rq_inner_114(.y(rq_inner[114]), .a(rq_reg[114]), .b(rq_iter[114]), .sel(busy_iter));
    mux2_1 u_rq_inner_115(.y(rq_inner[115]), .a(rq_reg[115]), .b(rq_iter[115]), .sel(busy_iter));
    mux2_1 u_rq_inner_116(.y(rq_inner[116]), .a(rq_reg[116]), .b(rq_iter[116]), .sel(busy_iter));
    mux2_1 u_rq_inner_117(.y(rq_inner[117]), .a(rq_reg[117]), .b(rq_iter[117]), .sel(busy_iter));
    mux2_1 u_rq_inner_118(.y(rq_inner[118]), .a(rq_reg[118]), .b(rq_iter[118]), .sel(busy_iter));
    mux2_1 u_rq_inner_119(.y(rq_inner[119]), .a(rq_reg[119]), .b(rq_iter[119]), .sel(busy_iter));
    mux2_1 u_rq_inner_120(.y(rq_inner[120]), .a(rq_reg[120]), .b(rq_iter[120]), .sel(busy_iter));
    mux2_1 u_rq_inner_121(.y(rq_inner[121]), .a(rq_reg[121]), .b(rq_iter[121]), .sel(busy_iter));
    mux2_1 u_rq_inner_122(.y(rq_inner[122]), .a(rq_reg[122]), .b(rq_iter[122]), .sel(busy_iter));
    mux2_1 u_rq_inner_123(.y(rq_inner[123]), .a(rq_reg[123]), .b(rq_iter[123]), .sel(busy_iter));
    mux2_1 u_rq_inner_124(.y(rq_inner[124]), .a(rq_reg[124]), .b(rq_iter[124]), .sel(busy_iter));
    mux2_1 u_rq_inner_125(.y(rq_inner[125]), .a(rq_reg[125]), .b(rq_iter[125]), .sel(busy_iter));
    mux2_1 u_rq_inner_126(.y(rq_inner[126]), .a(rq_reg[126]), .b(rq_iter[126]), .sel(busy_iter));
    mux2_1 u_rq_inner_127(.y(rq_inner[127]), .a(rq_reg[127]), .b(rq_iter[127]), .sel(busy_iter));

    
    
    mux2_1 u_rq_next_00(.y(next_rq[0]), .a(rq_inner[0]), .b(rq_init[0]), .sel(idle_start));
        mux2_1 u_rq_next_01(.y(next_rq[1]), .a(rq_inner[1]), .b(rq_init[1]), .sel(idle_start));
        mux2_1 u_rq_next_02(.y(next_rq[2]), .a(rq_inner[2]), .b(rq_init[2]), .sel(idle_start));
        mux2_1 u_rq_next_03(.y(next_rq[3]), .a(rq_inner[3]), .b(rq_init[3]), .sel(idle_start));
        mux2_1 u_rq_next_04(.y(next_rq[4]), .a(rq_inner[4]), .b(rq_init[4]), .sel(idle_start));
        mux2_1 u_rq_next_05(.y(next_rq[5]), .a(rq_inner[5]), .b(rq_init[5]), .sel(idle_start));
        mux2_1 u_rq_next_06(.y(next_rq[6]), .a(rq_inner[6]), .b(rq_init[6]), .sel(idle_start));
        mux2_1 u_rq_next_07(.y(next_rq[7]), .a(rq_inner[7]), .b(rq_init[7]), .sel(idle_start));
        mux2_1 u_rq_next_08(.y(next_rq[8]), .a(rq_inner[8]), .b(rq_init[8]), .sel(idle_start));
        mux2_1 u_rq_next_09(.y(next_rq[9]), .a(rq_inner[9]), .b(rq_init[9]), .sel(idle_start));
        mux2_1 u_rq_next_10(.y(next_rq[10]), .a(rq_inner[10]), .b(rq_init[10]), .sel(idle_start));
        mux2_1 u_rq_next_11(.y(next_rq[11]), .a(rq_inner[11]), .b(rq_init[11]), .sel(idle_start));
        mux2_1 u_rq_next_12(.y(next_rq[12]), .a(rq_inner[12]), .b(rq_init[12]), .sel(idle_start));
        mux2_1 u_rq_next_13(.y(next_rq[13]), .a(rq_inner[13]), .b(rq_init[13]), .sel(idle_start));
        mux2_1 u_rq_next_14(.y(next_rq[14]), .a(rq_inner[14]), .b(rq_init[14]), .sel(idle_start));
        mux2_1 u_rq_next_15(.y(next_rq[15]), .a(rq_inner[15]), .b(rq_init[15]), .sel(idle_start));
        mux2_1 u_rq_next_16(.y(next_rq[16]), .a(rq_inner[16]), .b(rq_init[16]), .sel(idle_start));
        mux2_1 u_rq_next_17(.y(next_rq[17]), .a(rq_inner[17]), .b(rq_init[17]), .sel(idle_start));
        mux2_1 u_rq_next_18(.y(next_rq[18]), .a(rq_inner[18]), .b(rq_init[18]), .sel(idle_start));
        mux2_1 u_rq_next_19(.y(next_rq[19]), .a(rq_inner[19]), .b(rq_init[19]), .sel(idle_start));
        mux2_1 u_rq_next_20(.y(next_rq[20]), .a(rq_inner[20]), .b(rq_init[20]), .sel(idle_start));
        mux2_1 u_rq_next_21(.y(next_rq[21]), .a(rq_inner[21]), .b(rq_init[21]), .sel(idle_start));
        mux2_1 u_rq_next_22(.y(next_rq[22]), .a(rq_inner[22]), .b(rq_init[22]), .sel(idle_start));
        mux2_1 u_rq_next_23(.y(next_rq[23]), .a(rq_inner[23]), .b(rq_init[23]), .sel(idle_start));
        mux2_1 u_rq_next_24(.y(next_rq[24]), .a(rq_inner[24]), .b(rq_init[24]), .sel(idle_start));
        mux2_1 u_rq_next_25(.y(next_rq[25]), .a(rq_inner[25]), .b(rq_init[25]), .sel(idle_start));
        mux2_1 u_rq_next_26(.y(next_rq[26]), .a(rq_inner[26]), .b(rq_init[26]), .sel(idle_start));
        mux2_1 u_rq_next_27(.y(next_rq[27]), .a(rq_inner[27]), .b(rq_init[27]), .sel(idle_start));
        mux2_1 u_rq_next_28(.y(next_rq[28]), .a(rq_inner[28]), .b(rq_init[28]), .sel(idle_start));
        mux2_1 u_rq_next_29(.y(next_rq[29]), .a(rq_inner[29]), .b(rq_init[29]), .sel(idle_start));
        mux2_1 u_rq_next_30(.y(next_rq[30]), .a(rq_inner[30]), .b(rq_init[30]), .sel(idle_start));
        mux2_1 u_rq_next_31(.y(next_rq[31]), .a(rq_inner[31]), .b(rq_init[31]), .sel(idle_start));
        mux2_1 u_rq_next_32(.y(next_rq[32]), .a(rq_inner[32]), .b(rq_init[32]), .sel(idle_start));
        mux2_1 u_rq_next_33(.y(next_rq[33]), .a(rq_inner[33]), .b(rq_init[33]), .sel(idle_start));
        mux2_1 u_rq_next_34(.y(next_rq[34]), .a(rq_inner[34]), .b(rq_init[34]), .sel(idle_start));
        mux2_1 u_rq_next_35(.y(next_rq[35]), .a(rq_inner[35]), .b(rq_init[35]), .sel(idle_start));
        mux2_1 u_rq_next_36(.y(next_rq[36]), .a(rq_inner[36]), .b(rq_init[36]), .sel(idle_start));
        mux2_1 u_rq_next_37(.y(next_rq[37]), .a(rq_inner[37]), .b(rq_init[37]), .sel(idle_start));
        mux2_1 u_rq_next_38(.y(next_rq[38]), .a(rq_inner[38]), .b(rq_init[38]), .sel(idle_start));
        mux2_1 u_rq_next_39(.y(next_rq[39]), .a(rq_inner[39]), .b(rq_init[39]), .sel(idle_start));
        mux2_1 u_rq_next_40(.y(next_rq[40]), .a(rq_inner[40]), .b(rq_init[40]), .sel(idle_start));
        mux2_1 u_rq_next_41(.y(next_rq[41]), .a(rq_inner[41]), .b(rq_init[41]), .sel(idle_start));
        mux2_1 u_rq_next_42(.y(next_rq[42]), .a(rq_inner[42]), .b(rq_init[42]), .sel(idle_start));
        mux2_1 u_rq_next_43(.y(next_rq[43]), .a(rq_inner[43]), .b(rq_init[43]), .sel(idle_start));
        mux2_1 u_rq_next_44(.y(next_rq[44]), .a(rq_inner[44]), .b(rq_init[44]), .sel(idle_start));
        mux2_1 u_rq_next_45(.y(next_rq[45]), .a(rq_inner[45]), .b(rq_init[45]), .sel(idle_start));
        mux2_1 u_rq_next_46(.y(next_rq[46]), .a(rq_inner[46]), .b(rq_init[46]), .sel(idle_start));
        mux2_1 u_rq_next_47(.y(next_rq[47]), .a(rq_inner[47]), .b(rq_init[47]), .sel(idle_start));
        mux2_1 u_rq_next_48(.y(next_rq[48]), .a(rq_inner[48]), .b(rq_init[48]), .sel(idle_start));
        mux2_1 u_rq_next_49(.y(next_rq[49]), .a(rq_inner[49]), .b(rq_init[49]), .sel(idle_start));
        mux2_1 u_rq_next_50(.y(next_rq[50]), .a(rq_inner[50]), .b(rq_init[50]), .sel(idle_start));
        mux2_1 u_rq_next_51(.y(next_rq[51]), .a(rq_inner[51]), .b(rq_init[51]), .sel(idle_start));
        mux2_1 u_rq_next_52(.y(next_rq[52]), .a(rq_inner[52]), .b(rq_init[52]), .sel(idle_start));
        mux2_1 u_rq_next_53(.y(next_rq[53]), .a(rq_inner[53]), .b(rq_init[53]), .sel(idle_start));
        mux2_1 u_rq_next_54(.y(next_rq[54]), .a(rq_inner[54]), .b(rq_init[54]), .sel(idle_start));
        mux2_1 u_rq_next_55(.y(next_rq[55]), .a(rq_inner[55]), .b(rq_init[55]), .sel(idle_start));
        mux2_1 u_rq_next_56(.y(next_rq[56]), .a(rq_inner[56]), .b(rq_init[56]), .sel(idle_start));
        mux2_1 u_rq_next_57(.y(next_rq[57]), .a(rq_inner[57]), .b(rq_init[57]), .sel(idle_start));
        mux2_1 u_rq_next_58(.y(next_rq[58]), .a(rq_inner[58]), .b(rq_init[58]), .sel(idle_start));
        mux2_1 u_rq_next_59(.y(next_rq[59]), .a(rq_inner[59]), .b(rq_init[59]), .sel(idle_start));
        mux2_1 u_rq_next_60(.y(next_rq[60]), .a(rq_inner[60]), .b(rq_init[60]), .sel(idle_start));
        mux2_1 u_rq_next_61(.y(next_rq[61]), .a(rq_inner[61]), .b(rq_init[61]), .sel(idle_start));
        mux2_1 u_rq_next_62(.y(next_rq[62]), .a(rq_inner[62]), .b(rq_init[62]), .sel(idle_start));
        mux2_1 u_rq_next_63(.y(next_rq[63]), .a(rq_inner[63]), .b(rq_init[63]), .sel(idle_start));
        mux2_1 u_rq_next_64(.y(next_rq[64]), .a(rq_inner[64]), .b(rq_init[64]), .sel(idle_start));
        mux2_1 u_rq_next_65(.y(next_rq[65]), .a(rq_inner[65]), .b(rq_init[65]), .sel(idle_start));
        mux2_1 u_rq_next_66(.y(next_rq[66]), .a(rq_inner[66]), .b(rq_init[66]), .sel(idle_start));
        mux2_1 u_rq_next_67(.y(next_rq[67]), .a(rq_inner[67]), .b(rq_init[67]), .sel(idle_start));
        mux2_1 u_rq_next_68(.y(next_rq[68]), .a(rq_inner[68]), .b(rq_init[68]), .sel(idle_start));
        mux2_1 u_rq_next_69(.y(next_rq[69]), .a(rq_inner[69]), .b(rq_init[69]), .sel(idle_start));
        mux2_1 u_rq_next_70(.y(next_rq[70]), .a(rq_inner[70]), .b(rq_init[70]), .sel(idle_start));
        mux2_1 u_rq_next_71(.y(next_rq[71]), .a(rq_inner[71]), .b(rq_init[71]), .sel(idle_start));
        mux2_1 u_rq_next_72(.y(next_rq[72]), .a(rq_inner[72]), .b(rq_init[72]), .sel(idle_start));
        mux2_1 u_rq_next_73(.y(next_rq[73]), .a(rq_inner[73]), .b(rq_init[73]), .sel(idle_start));
        mux2_1 u_rq_next_74(.y(next_rq[74]), .a(rq_inner[74]), .b(rq_init[74]), .sel(idle_start));
        mux2_1 u_rq_next_75(.y(next_rq[75]), .a(rq_inner[75]), .b(rq_init[75]), .sel(idle_start));
        mux2_1 u_rq_next_76(.y(next_rq[76]), .a(rq_inner[76]), .b(rq_init[76]), .sel(idle_start));
        mux2_1 u_rq_next_77(.y(next_rq[77]), .a(rq_inner[77]), .b(rq_init[77]), .sel(idle_start));
        mux2_1 u_rq_next_78(.y(next_rq[78]), .a(rq_inner[78]), .b(rq_init[78]), .sel(idle_start));
        mux2_1 u_rq_next_79(.y(next_rq[79]), .a(rq_inner[79]), .b(rq_init[79]), .sel(idle_start));
        mux2_1 u_rq_next_80(.y(next_rq[80]), .a(rq_inner[80]), .b(rq_init[80]), .sel(idle_start));
        mux2_1 u_rq_next_81(.y(next_rq[81]), .a(rq_inner[81]), .b(rq_init[81]), .sel(idle_start));
        mux2_1 u_rq_next_82(.y(next_rq[82]), .a(rq_inner[82]), .b(rq_init[82]), .sel(idle_start));
        mux2_1 u_rq_next_83(.y(next_rq[83]), .a(rq_inner[83]), .b(rq_init[83]), .sel(idle_start));
        mux2_1 u_rq_next_84(.y(next_rq[84]), .a(rq_inner[84]), .b(rq_init[84]), .sel(idle_start));
        mux2_1 u_rq_next_85(.y(next_rq[85]), .a(rq_inner[85]), .b(rq_init[85]), .sel(idle_start));
        mux2_1 u_rq_next_86(.y(next_rq[86]), .a(rq_inner[86]), .b(rq_init[86]), .sel(idle_start));
        mux2_1 u_rq_next_87(.y(next_rq[87]), .a(rq_inner[87]), .b(rq_init[87]), .sel(idle_start));
        mux2_1 u_rq_next_88(.y(next_rq[88]), .a(rq_inner[88]), .b(rq_init[88]), .sel(idle_start));
        mux2_1 u_rq_next_89(.y(next_rq[89]), .a(rq_inner[89]), .b(rq_init[89]), .sel(idle_start));
        mux2_1 u_rq_next_90(.y(next_rq[90]), .a(rq_inner[90]), .b(rq_init[90]), .sel(idle_start));
        mux2_1 u_rq_next_91(.y(next_rq[91]), .a(rq_inner[91]), .b(rq_init[91]), .sel(idle_start));
        mux2_1 u_rq_next_92(.y(next_rq[92]), .a(rq_inner[92]), .b(rq_init[92]), .sel(idle_start));
        mux2_1 u_rq_next_93(.y(next_rq[93]), .a(rq_inner[93]), .b(rq_init[93]), .sel(idle_start));
        mux2_1 u_rq_next_94(.y(next_rq[94]), .a(rq_inner[94]), .b(rq_init[94]), .sel(idle_start));
        mux2_1 u_rq_next_95(.y(next_rq[95]), .a(rq_inner[95]), .b(rq_init[95]), .sel(idle_start));
        mux2_1 u_rq_next_96(.y(next_rq[96]), .a(rq_inner[96]), .b(rq_init[96]), .sel(idle_start));
        mux2_1 u_rq_next_97(.y(next_rq[97]), .a(rq_inner[97]), .b(rq_init[97]), .sel(idle_start));
        mux2_1 u_rq_next_98(.y(next_rq[98]), .a(rq_inner[98]), .b(rq_init[98]), .sel(idle_start));
        mux2_1 u_rq_next_99(.y(next_rq[99]), .a(rq_inner[99]), .b(rq_init[99]), .sel(idle_start));
        mux2_1 u_rq_next_100(.y(next_rq[100]), .a(rq_inner[100]), .b(rq_init[100]), .sel(idle_start));
        mux2_1 u_rq_next_101(.y(next_rq[101]), .a(rq_inner[101]), .b(rq_init[101]), .sel(idle_start));
        mux2_1 u_rq_next_102(.y(next_rq[102]), .a(rq_inner[102]), .b(rq_init[102]), .sel(idle_start));
        mux2_1 u_rq_next_103(.y(next_rq[103]), .a(rq_inner[103]), .b(rq_init[103]), .sel(idle_start));
        mux2_1 u_rq_next_104(.y(next_rq[104]), .a(rq_inner[104]), .b(rq_init[104]), .sel(idle_start));
        mux2_1 u_rq_next_105(.y(next_rq[105]), .a(rq_inner[105]), .b(rq_init[105]), .sel(idle_start));
        mux2_1 u_rq_next_106(.y(next_rq[106]), .a(rq_inner[106]), .b(rq_init[106]), .sel(idle_start));
        mux2_1 u_rq_next_107(.y(next_rq[107]), .a(rq_inner[107]), .b(rq_init[107]), .sel(idle_start));
        mux2_1 u_rq_next_108(.y(next_rq[108]), .a(rq_inner[108]), .b(rq_init[108]), .sel(idle_start));
        mux2_1 u_rq_next_109(.y(next_rq[109]), .a(rq_inner[109]), .b(rq_init[109]), .sel(idle_start));
        mux2_1 u_rq_next_110(.y(next_rq[110]), .a(rq_inner[110]), .b(rq_init[110]), .sel(idle_start));
        mux2_1 u_rq_next_111(.y(next_rq[111]), .a(rq_inner[111]), .b(rq_init[111]), .sel(idle_start));
        mux2_1 u_rq_next_112(.y(next_rq[112]), .a(rq_inner[112]), .b(rq_init[112]), .sel(idle_start));
        mux2_1 u_rq_next_113(.y(next_rq[113]), .a(rq_inner[113]), .b(rq_init[113]), .sel(idle_start));
        mux2_1 u_rq_next_114(.y(next_rq[114]), .a(rq_inner[114]), .b(rq_init[114]), .sel(idle_start));
        mux2_1 u_rq_next_115(.y(next_rq[115]), .a(rq_inner[115]), .b(rq_init[115]), .sel(idle_start));
        mux2_1 u_rq_next_116(.y(next_rq[116]), .a(rq_inner[116]), .b(rq_init[116]), .sel(idle_start));
        mux2_1 u_rq_next_117(.y(next_rq[117]), .a(rq_inner[117]), .b(rq_init[117]), .sel(idle_start));
        mux2_1 u_rq_next_118(.y(next_rq[118]), .a(rq_inner[118]), .b(rq_init[118]), .sel(idle_start));
        mux2_1 u_rq_next_119(.y(next_rq[119]), .a(rq_inner[119]), .b(rq_init[119]), .sel(idle_start));
        mux2_1 u_rq_next_120(.y(next_rq[120]), .a(rq_inner[120]), .b(rq_init[120]), .sel(idle_start));
        mux2_1 u_rq_next_121(.y(next_rq[121]), .a(rq_inner[121]), .b(rq_init[121]), .sel(idle_start));
        mux2_1 u_rq_next_122(.y(next_rq[122]), .a(rq_inner[122]), .b(rq_init[122]), .sel(idle_start));
        mux2_1 u_rq_next_123(.y(next_rq[123]), .a(rq_inner[123]), .b(rq_init[123]), .sel(idle_start));
        mux2_1 u_rq_next_124(.y(next_rq[124]), .a(rq_inner[124]), .b(rq_init[124]), .sel(idle_start));
        mux2_1 u_rq_next_125(.y(next_rq[125]), .a(rq_inner[125]), .b(rq_init[125]), .sel(idle_start));
        mux2_1 u_rq_next_126(.y(next_rq[126]), .a(rq_inner[126]), .b(rq_init[126]), .sel(idle_start));
        mux2_1 u_rq_next_127(.y(next_rq[127]), .a(rq_inner[127]), .b(rq_init[127]), .sel(idle_start));

    //  div_reg / sign_q_reg / sign_r_reg NEXT — load-or-hold
    //      idle_start -> init value
    //      else       -> hold
    mux2_1_64 u_div_next(.y(next_div), .a(div_reg), .b(divisor_abs), .sel(idle_start));

    wire sign_q_reg, sign_r_reg, next_sign_q, next_sign_r;
    mux2_1 u_sq_next(.y(next_sign_q), .a(sign_q_reg), .b(sign_q_init), .sel(idle_start));
    mux2_1 u_sr_next(.y(next_sign_r), .a(sign_r_reg), .b(sign_r_init), .sel(idle_start));

    //  REGISTER INSTANCES — dff / dff64 (sync reset to 0)
    //  Every register loads its next value each cycle; hold behaviour is
    //  produced by the feedback muxes above.
    dff   u_state[1:0](.q(state), .d(next_state), .clk(clk), .rst(rst));
    dff   u_counter[6:0](.q(counter), .d(next_counter), .clk(clk), .rst(rst));
    dff   u_signq(.q(sign_q_reg), .d(next_sign_q), .clk(clk), .rst(rst));
    dff   u_signr(.q(sign_r_reg), .d(next_sign_r), .clk(clk), .rst(rst));
    dff64 u_divreg(.q(div_reg), .d(next_div), .clk(clk), .rst(rst));
    dff64 u_rq_lo(.q(rq_reg[ 63: 0]), .d(next_rq[ 63: 0]), .clk(clk), .rst(rst));
    dff64 u_rq_hi(.q(rq_reg[127:64]), .d(next_rq[127:64]), .clk(clk), .rst(rst));

    //  OUTPUT SIGN CORRECTION
    //      q_pos = rq_reg[63:0],     r_pos = rq_reg[127:64]
    //      q_neg = -q_pos,           r_neg = -r_pos          (adder64 with +1)
    //      quotient  = sign_q_reg ? q_neg : q_pos
    //      remainder = sign_r_reg ? r_neg : r_pos
    // 
    wire [63:0] q_pos, r_pos;
    assign q_pos = rq_reg[63:0];
    assign r_pos = rq_reg[127:64];

    wire [63:0] q_inv, r_inv;
    not n_g_inv_00(q_inv[0], q_pos[0]);
    not n_g_inv_01(q_inv[1], q_pos[1]);
    not n_g_inv_02(q_inv[2], q_pos[2]);
    not n_g_inv_03(q_inv[3], q_pos[3]);
    not n_g_inv_04(q_inv[4], q_pos[4]);
    not n_g_inv_05(q_inv[5], q_pos[5]);
    not n_g_inv_06(q_inv[6], q_pos[6]);
    not n_g_inv_07(q_inv[7], q_pos[7]);
    not n_g_inv_08(q_inv[8], q_pos[8]);
    not n_g_inv_09(q_inv[9], q_pos[9]);
    not n_g_inv_10(q_inv[10], q_pos[10]);
    not n_g_inv_11(q_inv[11], q_pos[11]);
    not n_g_inv_12(q_inv[12], q_pos[12]);
    not n_g_inv_13(q_inv[13], q_pos[13]);
    not n_g_inv_14(q_inv[14], q_pos[14]);
    not n_g_inv_15(q_inv[15], q_pos[15]);
    not n_g_inv_16(q_inv[16], q_pos[16]);
    not n_g_inv_17(q_inv[17], q_pos[17]);
    not n_g_inv_18(q_inv[18], q_pos[18]);
    not n_g_inv_19(q_inv[19], q_pos[19]);
    not n_g_inv_20(q_inv[20], q_pos[20]);
    not n_g_inv_21(q_inv[21], q_pos[21]);
    not n_g_inv_22(q_inv[22], q_pos[22]);
    not n_g_inv_23(q_inv[23], q_pos[23]);
    not n_g_inv_24(q_inv[24], q_pos[24]);
    not n_g_inv_25(q_inv[25], q_pos[25]);
    not n_g_inv_26(q_inv[26], q_pos[26]);
    not n_g_inv_27(q_inv[27], q_pos[27]);
    not n_g_inv_28(q_inv[28], q_pos[28]);
    not n_g_inv_29(q_inv[29], q_pos[29]);
    not n_g_inv_30(q_inv[30], q_pos[30]);
    not n_g_inv_31(q_inv[31], q_pos[31]);
    not n_g_inv_32(q_inv[32], q_pos[32]);
    not n_g_inv_33(q_inv[33], q_pos[33]);
    not n_g_inv_34(q_inv[34], q_pos[34]);
    not n_g_inv_35(q_inv[35], q_pos[35]);
    not n_g_inv_36(q_inv[36], q_pos[36]);
    not n_g_inv_37(q_inv[37], q_pos[37]);
    not n_g_inv_38(q_inv[38], q_pos[38]);
    not n_g_inv_39(q_inv[39], q_pos[39]);
    not n_g_inv_40(q_inv[40], q_pos[40]);
    not n_g_inv_41(q_inv[41], q_pos[41]);
    not n_g_inv_42(q_inv[42], q_pos[42]);
    not n_g_inv_43(q_inv[43], q_pos[43]);
    not n_g_inv_44(q_inv[44], q_pos[44]);
    not n_g_inv_45(q_inv[45], q_pos[45]);
    not n_g_inv_46(q_inv[46], q_pos[46]);
    not n_g_inv_47(q_inv[47], q_pos[47]);
    not n_g_inv_48(q_inv[48], q_pos[48]);
    not n_g_inv_49(q_inv[49], q_pos[49]);
    not n_g_inv_50(q_inv[50], q_pos[50]);
    not n_g_inv_51(q_inv[51], q_pos[51]);
    not n_g_inv_52(q_inv[52], q_pos[52]);
    not n_g_inv_53(q_inv[53], q_pos[53]);
    not n_g_inv_54(q_inv[54], q_pos[54]);
    not n_g_inv_55(q_inv[55], q_pos[55]);
    not n_g_inv_56(q_inv[56], q_pos[56]);
    not n_g_inv_57(q_inv[57], q_pos[57]);
    not n_g_inv_58(q_inv[58], q_pos[58]);
    not n_g_inv_59(q_inv[59], q_pos[59]);
    not n_g_inv_60(q_inv[60], q_pos[60]);
    not n_g_inv_61(q_inv[61], q_pos[61]);
    not n_g_inv_62(q_inv[62], q_pos[62]);
    not n_g_inv_63(q_inv[63], q_pos[63]);
    
    not n_r_inv_00(r_inv[0], r_pos[0]);
    not n_r_inv_01(r_inv[1], r_pos[1]);
    not n_r_inv_02(r_inv[2], r_pos[2]);
    not n_r_inv_03(r_inv[3], r_pos[3]);
    not n_r_inv_04(r_inv[4], r_pos[4]);
    not n_r_inv_05(r_inv[5], r_pos[5]);
    not n_r_inv_06(r_inv[6], r_pos[6]);
    not n_r_inv_07(r_inv[7], r_pos[7]);
    not n_r_inv_08(r_inv[8], r_pos[8]);
    not n_r_inv_09(r_inv[9], r_pos[9]);
    not n_r_inv_10(r_inv[10], r_pos[10]);
    not n_r_inv_11(r_inv[11], r_pos[11]);
    not n_r_inv_12(r_inv[12], r_pos[12]);
    not n_r_inv_13(r_inv[13], r_pos[13]);
    not n_r_inv_14(r_inv[14], r_pos[14]);
    not n_r_inv_15(r_inv[15], r_pos[15]);
    not n_r_inv_16(r_inv[16], r_pos[16]);
    not n_r_inv_17(r_inv[17], r_pos[17]);
    not n_r_inv_18(r_inv[18], r_pos[18]);
    not n_r_inv_19(r_inv[19], r_pos[19]);
    not n_r_inv_20(r_inv[20], r_pos[20]);
    not n_r_inv_21(r_inv[21], r_pos[21]);
    not n_r_inv_22(r_inv[22], r_pos[22]);
    not n_r_inv_23(r_inv[23], r_pos[23]);
    not n_r_inv_24(r_inv[24], r_pos[24]);
    not n_r_inv_25(r_inv[25], r_pos[25]);
    not n_r_inv_26(r_inv[26], r_pos[26]);
    not n_r_inv_27(r_inv[27], r_pos[27]);
    not n_r_inv_28(r_inv[28], r_pos[28]);
    not n_r_inv_29(r_inv[29], r_pos[29]);
    not n_r_inv_30(r_inv[30], r_pos[30]);
    not n_r_inv_31(r_inv[31], r_pos[31]);
    not n_r_inv_32(r_inv[32], r_pos[32]);
    not n_r_inv_33(r_inv[33], r_pos[33]);
    not n_r_inv_34(r_inv[34], r_pos[34]);
    not n_r_inv_35(r_inv[35], r_pos[35]);
    not n_r_inv_36(r_inv[36], r_pos[36]);
    not n_r_inv_37(r_inv[37], r_pos[37]);
    not n_r_inv_38(r_inv[38], r_pos[38]);
    not n_r_inv_39(r_inv[39], r_pos[39]);
    not n_r_inv_40(r_inv[40], r_pos[40]);
    not n_r_inv_41(r_inv[41], r_pos[41]);
    not n_r_inv_42(r_inv[42], r_pos[42]);
    not n_r_inv_43(r_inv[43], r_pos[43]);
    not n_r_inv_44(r_inv[44], r_pos[44]);
    not n_r_inv_45(r_inv[45], r_pos[45]);
    not n_r_inv_46(r_inv[46], r_pos[46]);
    not n_r_inv_47(r_inv[47], r_pos[47]);
    not n_r_inv_48(r_inv[48], r_pos[48]);
    not n_r_inv_49(r_inv[49], r_pos[49]);
    not n_r_inv_50(r_inv[50], r_pos[50]);
    not n_r_inv_51(r_inv[51], r_pos[51]);
    not n_r_inv_52(r_inv[52], r_pos[52]);
    not n_r_inv_53(r_inv[53], r_pos[53]);
    not n_r_inv_54(r_inv[54], r_pos[54]);
    not n_r_inv_55(r_inv[55], r_pos[55]);
    not n_r_inv_56(r_inv[56], r_pos[56]);
    not n_r_inv_57(r_inv[57], r_pos[57]);
    not n_r_inv_58(r_inv[58], r_pos[58]);
    not n_r_inv_59(r_inv[59], r_pos[59]);
    not n_r_inv_60(r_inv[60], r_pos[60]);
    not n_r_inv_61(r_inv[61], r_pos[61]);
    not n_r_inv_62(r_inv[62], r_pos[62]);
    not n_r_inv_63(r_inv[63], r_pos[63]);
    
    wire [63:0] q_neg, r_neg;
    adder64 u_q_neg(.sum(q_neg), .cout(), .a(q_inv), .b(64'b0), .cin(1'b1));
    adder64 u_r_neg(.sum(r_neg), .cout(), .a(r_inv), .b(64'b0), .cin(1'b1));

    mux2_1_64 u_qout(.y(quotient), .a(q_pos), .b(q_neg), .sel(sign_q_reg));
    mux2_1_64 u_rout(.y(remainder), .a(r_pos), .b(r_neg), .sel(sign_r_reg));

    assign busy = is_busy;
    assign done = is_done;

endmodule