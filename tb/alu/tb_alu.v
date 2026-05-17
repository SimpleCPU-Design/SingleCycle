`timescale 1ns/1ps

//  Coverage
//    1)  Directed unit tests for every alu_op opcode  (20 ops × a few vectors)
//    2)  NZCV flag spot-checks for ADD / SUB
//    3)  mul_hi spot-checks for SMULH / UMULH
//    4)  Random tests: 200 vectors per op (where the golden is easy to express)

module tb_alu;

    reg [63:0] a, b, c;
    reg [5:0] alu_op;
    wire [63:0] y;
    wire [63:0] mul_hi;
    wire [3:0] nzcv;

    alu dut(
        .y(y),
        .mul_hi(mul_hi),
        .nzcv(nzcv),
        .a(a),
        .b(b),
        .c(c),
        .alu_op(alu_op)
    );

    // Opcode constants
    localparam OP_ADD    = 6'b000000;
    localparam OP_SUB    = 6'b000001;
    localparam OP_AND    = 6'b000010;
    localparam OP_ORR    = 6'b000011;
    localparam OP_EOR    = 6'b000100;
    localparam OP_BIC    = 6'b000101;
    localparam OP_ORN    = 6'b000110;
    localparam OP_EON    = 6'b000111;
    localparam OP_LSL    = 6'b001000;
    localparam OP_LSR    = 6'b001001;
    localparam OP_ASR    = 6'b001010;
    localparam OP_ROR    = 6'b001011;
    localparam OP_MUL    = 6'b001100;
    localparam OP_SMULH  = 6'b001101;
    localparam OP_UMULH  = 6'b001110;
    localparam OP_MADD   = 6'b001111;
    localparam OP_MSUB   = 6'b010000;
    localparam OP_SDIV   = 6'b010001;
    localparam OP_UDIV   = 6'b010010;
    localparam OP_PASS_B = 6'b010011;

    integer errors = 0;
    integer n_tests = 0;

    // Result-only checker (ignores flags)
    task check_y;
        input [63:0]     ta, tb, tc;
        input [5:0]      top;
        input [63:0]     exp_y;
        input [8*40-1:0] tag;
        begin
            a = ta; b = tb; c = tc; alu_op = top;
            #1;
            n_tests = n_tests + 1;
            if (y !== exp_y) begin
                errors = errors + 1;
                $display("FAIL [%0s] op=%b a=%h b=%h c=%h", tag, top, ta, tb, tc);
                $display("           y got=%h exp=%h", y, exp_y);
            end
        end
    endtask

    // Flag checker (used for ADD / SUB)
    task check_flags;
        input [63:0]     ta, tb;
        input [5:0]      top;
        input [63:0]     exp_y;
        input [3:0]      exp_nzcv;
        input [8*40-1:0] tag;
        begin
            a = ta; b = tb; c = 64'b0; alu_op = top;
            #1;
            n_tests = n_tests + 1;
            if (y !== exp_y || nzcv !== exp_nzcv) begin
                errors = errors + 1;
                $display("FAIL [%0s] op=%b a=%h b=%h", tag, top, ta, tb);
                $display("           y    got=%h exp=%h", y,    exp_y);
                $display("           nzcv got=%b exp=%b", nzcv, exp_nzcv);
            end
        end
    endtask

    // mul-hi checker
    task check_mul_hi;
        input [63:0]     ta, tb;
        input [5:0]      top;
        input [63:0]     exp_hi;
        input [8*40-1:0] tag;
        begin
            a = ta; b = tb; c = 64'b0; alu_op = top;
            #1;
            n_tests = n_tests + 1;
            if (mul_hi !== exp_hi) begin
                errors = errors + 1;
                $display("FAIL [%0s] op=%b a=%h b=%h", tag, top, ta, tb);
                $display("           mul_hi got=%h exp=%h", mul_hi, exp_hi);
            end
        end
    endtask

    // Random helper data
    integer i;
    reg [63:0]  ra, rb, rc;
    reg [127:0] rprod_u, rprod_s;

    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_alu);

        a = 64'b0; b = 64'b0; c = 64'b0; alu_op = 6'b0;
        #1;

        // DIRECTED — arithmetic
        check_y(64'd5,  64'd3, 64'b0, OP_ADD, 64'd8,  "ADD 5+3");
        check_y(64'd0,  64'd0, 64'b0, OP_ADD, 64'd0,  "ADD 0+0");
        check_y(64'hFFFFFFFFFFFFFFFF, 64'd1, 64'b0, OP_ADD, 64'd0, "ADD MAX+1");
        check_y(64'd10, 64'd3, 64'b0, OP_SUB, 64'd7,  "SUB 10-3");
        check_y(64'd3,  64'd5, 64'b0, OP_SUB, -64'd2, "SUB 3-5");
        check_y(64'd0,  64'd0, 64'b0, OP_SUB, 64'd0,  "SUB 0-0");

        // DIRECTED — logical
        check_y(64'hF0F0F0F0F0F0F0F0, 64'h0F0F0F0F0F0F0F0F, 64'b0,
                OP_AND, 64'h0,                "AND alt");
        check_y(64'hF0F0F0F0F0F0F0F0, 64'h0F0F0F0F0F0F0F0F, 64'b0,
                OP_ORR, 64'hFFFFFFFFFFFFFFFF, "ORR alt");
        check_y(64'hFFFFFFFFFFFFFFFF, 64'hAAAAAAAAAAAAAAAA, 64'b0,
                OP_EOR, 64'h5555555555555555, "EOR mask");
        check_y(64'hF0F0F0F0F0F0F0F0, 64'h0F0F0F0F0F0F0F0F, 64'b0,
                OP_BIC, 64'hF0F0F0F0F0F0F0F0, "BIC keep");
        check_y(64'h00000000000000FF, 64'h00000000000000F0, 64'b0,
                OP_BIC, 64'h000000000000000F, "BIC low");
        check_y(64'h0,                64'h0,                64'b0,
                OP_ORN, 64'hFFFFFFFFFFFFFFFF, "ORN 0|~0");
        check_y(64'hAAAAAAAAAAAAAAAA, 64'hAAAAAAAAAAAAAAAA, 64'b0,
                OP_EON, 64'hFFFFFFFFFFFFFFFF, "EON aa^~aa");

        //  DIRECTED — shift (shamt comes from b[5:0])
        check_y(64'h1,                64'd4, 64'b0, OP_LSL, 64'h10,                  "LSL 1<<4");
        check_y(64'h8000000000000000, 64'd63,64'b0, OP_LSR, 64'h1,                   "LSR top->1");
        check_y(64'h8000000000000000, 64'd1, 64'b0, OP_ASR, 64'hC000000000000000,    "ASR neg");
        check_y(64'h0000000000000001, 64'd1, 64'b0, OP_ROR, 64'h8000000000000000,    "ROR 1");
        check_y(64'hFFFFFFFFFFFFFFFF, 64'd0, 64'b0, OP_LSL, 64'hFFFFFFFFFFFFFFFF,    "LSL shamt=0");

        //  DIRECTED — multiply
        check_y(64'd6,   64'd7,  64'b0, OP_MUL, 64'd42, "MUL 6*7");
        check_y(-64'd6,  64'd7,  64'b0, OP_MUL, -64'd42,"MUL -6*7");
        check_y(64'd0,   64'd0,  64'b0, OP_MUL, 64'd0,  "MUL 0*0");
        // SMULH / UMULH
        // signed:    (-1) * 2 = -2  -> upper = -1 = 0xFFFFFFFFFFFFFFFF
        // unsigned:  (2^64-1)*2     -> upper = 1
        check_y(64'hFFFFFFFFFFFFFFFF, 64'd2, 64'b0, OP_SMULH, 64'hFFFFFFFFFFFFFFFF, "SMULH -1*2");
        check_y(64'hFFFFFFFFFFFFFFFF, 64'd2, 64'b0, OP_UMULH, 64'd1,                "UMULH MAX*2");
        // MADD / MSUB
        check_y(64'd3, 64'd4, 64'd10, OP_MADD, 64'd22,  "MADD 10+3*4");
        check_y(64'd3, 64'd4, 64'd10, OP_MSUB, -64'd2,  "MSUB 10-3*4");
        check_y(64'd0, 64'd0, 64'd99, OP_MADD, 64'd99,  "MADD c+0");
        check_y(64'd0, 64'd0, 64'd99, OP_MSUB, 64'd99,  "MSUB c-0");

        // DIRECTED — divide
        check_y(64'd20, 64'd4, 64'b0, OP_UDIV, 64'd5, "UDIV 20/4");
        check_y(64'd20, 64'd3, 64'b0, OP_UDIV, 64'd6, "UDIV 20/3");
        check_y(64'd20, 64'd0, 64'b0, OP_UDIV, 64'd0, "UDIV dz");
        check_y(-64'd20, 64'd4, 64'b0, OP_SDIV, -64'd5, "SDIV -20/4");
        check_y(-64'd20,-64'd4, 64'b0, OP_SDIV,  64'd5, "SDIV -20/-4");
        check_y(64'h8000000000000000,-64'd1, 64'b0, OP_SDIV,
                64'h8000000000000000, "SDIV INT_MIN/-1");

        // DIRECTED — PASS_B
        check_y(64'd123, 64'hDEADBEEF, 64'b0, OP_PASS_B, 64'hDEADBEEF, "PASS_B 1");
        check_y(64'b0,   64'b0,        64'b0, OP_PASS_B, 64'b0,        "PASS_B 0");

        // NZCV flag spot-checks
        //   ADD 0 + 0  -> Z=1, others 0
        check_flags(64'd0, 64'd0, OP_ADD, 64'd0, 4'b0100, "FLAG ADD 0+0");
        //   ADD MAX + 1  -> result 0, Z=1, C=1
        check_flags(64'hFFFFFFFFFFFFFFFF, 64'd1, OP_ADD, 64'd0, 4'b0110, "FLAG ADD MAX+1");
        //   ADD INT_MAX + 1  -> result = INT_MIN, N=1, V=1
        check_flags(64'h7FFFFFFFFFFFFFFF, 64'd1, OP_ADD,
                    64'h8000000000000000, 4'b1001, "FLAG ADD INT_MAX+1");
        //   SUB 5 - 3 -> 2, C=1 (no borrow), no other flags
        check_flags(64'd5, 64'd3, OP_SUB, 64'd2, 4'b0010, "FLAG SUB 5-3");
        //   SUB 3 - 5 -> -2, N=1, C=0 (borrow)
        check_flags(64'd3, 64'd5, OP_SUB, -64'd2, 4'b1000, "FLAG SUB 3-5");
        //   SUB 5 - 5 -> 0, Z=1, C=1
        check_flags(64'd5, 64'd5, OP_SUB, 64'd0, 4'b0110, "FLAG SUB 5-5");
        //   SUB INT_MIN - 1 -> INT_MAX, V=1, C=1, N=0
        check_flags(64'h8000000000000000, 64'd1, OP_SUB,
                    64'h7FFFFFFFFFFFFFFF, 4'b0011, "FLAG SUB INT_MIN-1");

        // mul_hi spot-checks (always present, regardless of alu_op)
        check_mul_hi(64'hFFFFFFFFFFFFFFFF, 64'd2, OP_SMULH,
                     64'hFFFFFFFFFFFFFFFF, "MUL_HI s -1*2");
        check_mul_hi(64'hFFFFFFFFFFFFFFFF, 64'd2, OP_UMULH,
                     64'd1,                "MUL_HI u MAX*2");

        // RANDOM — ADD / SUB / logical / shift
        for (i = 0; i < 200; i = i + 1) begin
            ra = {$random, $random};
            rb = {$random, $random};
            check_y(ra, rb, 64'b0, OP_ADD, ra + rb,                 "rand ADD");
            check_y(ra, rb, 64'b0, OP_SUB, ra - rb,                 "rand SUB");
            check_y(ra, rb, 64'b0, OP_AND, ra & rb,                 "rand AND");
            check_y(ra, rb, 64'b0, OP_ORR, ra | rb,                 "rand ORR");
            check_y(ra, rb, 64'b0, OP_EOR, ra ^ rb,                 "rand EOR");
            check_y(ra, rb, 64'b0, OP_BIC, ra & (~rb),              "rand BIC");
            check_y(ra, rb, 64'b0, OP_ORN, ra | (~rb),              "rand ORN");
            check_y(ra, rb, 64'b0, OP_EON, ra ^ (~rb),              "rand EON");

            // Shifts use only b[5:0] as shamt
            check_y(ra, {58'b0, rb[5:0]}, 64'b0, OP_LSL,
                    ra << rb[5:0],                   "rand LSL");
            check_y(ra, {58'b0, rb[5:0]}, 64'b0, OP_LSR,
                    ra >> rb[5:0],                   "rand LSR");
            check_y(ra, {58'b0, rb[5:0]}, 64'b0, OP_ASR,
                    $signed(ra) >>> rb[5:0],         "rand ASR");
        end

        // RANDOM — multiply
        for (i = 0; i < 200; i = i + 1) begin
            ra = {$random, $random};
            rb = {$random, $random};
            rc = {$random, $random};

            rprod_s = $signed(ra) * $signed(rb);   // 128-bit signed product
            rprod_u = ra * rb;                      // 128-bit unsigned product

            check_y(ra, rb, 64'b0, OP_MUL,   rprod_u[63:0],   "rand MUL");
            check_y(ra, rb, 64'b0, OP_SMULH, rprod_s[127:64], "rand SMULH");
            check_y(ra, rb, 64'b0, OP_UMULH, rprod_u[127:64], "rand UMULH");
            check_y(ra, rb, rc,    OP_MADD,  rc + rprod_u[63:0], "rand MADD");
            check_y(ra, rb, rc,    OP_MSUB,  rc - rprod_u[63:0], "rand MSUB");
        end

        // RANDOM — divide
        for (i = 0; i < 100; i = i + 1) begin
            ra = {$random, $random};
            rb = {$random, $random};
            if (rb == 64'b0) rb = 64'd1;   // skip divide-by-zero here
            check_y(ra, rb, 64'b0, OP_UDIV, ra / rb,                  "rand UDIV");
            check_y(ra, rb, 64'b0, OP_SDIV, $signed(ra) / $signed(rb), "rand SDIV");
        end
        // Explicit divide-by-zero
        check_y(64'd123, 64'd0, 64'b0, OP_UDIV, 64'd0, "UDIV dz extra");
        check_y(64'd123, 64'd0, 64'b0, OP_SDIV, 64'd0, "SDIV dz extra");

        // Summary
        $display("---------------------------------------------------");
        if (errors == 0) $display("PASS: alu — %0d cases", n_tests);
        else             $display("FAIL: alu — %0d / %0d errors", errors, n_tests);
        $finish;
    end
    
    
endmodule
