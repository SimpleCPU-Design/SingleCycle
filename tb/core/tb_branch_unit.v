`timescale 1ns/1ps

// ================================================================================
//  tb_branch_unit -- self-checking testbench for branch_unit.
//
//  branch_unit is purely combinational, so each case is: drive inputs, settle,
//  compare branch_taken + branch_target against a behavioral reference.
//
//  Reference model (mirrors the DUT contract):
//    branch_type: 000 none 001 B 010 BL 011 BR 100 BLR 101 CBZ 110 CBNZ 111 B.cond
//    taken      = unconditional (B/BL/BR/BLR)
//               | CBZ  & (reg_rt==0) | CBNZ & (reg_rt!=0) | B.cond & cond_holds
//    target     = (BR/BLR) ? reg_rn : pc + (imm_ext<<2)
//    nzcv       = {N,Z,C,V}
//
//  Coverage: every branch_type, CBZ/CBNZ zero & non-zero, all 16 B.cond codes
//  against several flag patterns, high/low offsets, and a randomized stress loop.
// ================================================================================

module tb_branch_unit;
    reg  [2:0]  branch_type;
    reg  [63:0] pc, imm_ext, reg_rt, reg_rn;
    reg  [3:0]  cond, nzcv;
    wire        branch_taken;
    wire [63:0] branch_target;

    branch_unit dut(
        .branch_taken (branch_taken),
        .branch_target(branch_target),
        .branch_type  (branch_type),
        .pc           (pc),
        .imm_ext      (imm_ext),
        .reg_rt       (reg_rt),
        .reg_rn       (reg_rn),
        .cond         (cond),
        .nzcv         (nzcv)
    );

    integer errors  = 0;
    integer n_tests = 0;

    // --- Behavioral reference for the ARM condition codes ---
    //   nzcv = {N,Z,C,V}
    function cond_holds;
        input [3:0] c;
        input [3:0] f;
        reg n, z, cf, v;
        begin
            n = f[3]; z = f[2]; cf = f[1]; v = f[0];
            case (c)
                4'b0000: cond_holds = z;                 // EQ
                4'b0001: cond_holds = ~z;                // NE
                4'b0010: cond_holds = cf;                // CS/HS
                4'b0011: cond_holds = ~cf;               // CC/LO
                4'b0100: cond_holds = n;                 // MI
                4'b0101: cond_holds = ~n;                // PL
                4'b0110: cond_holds = v;                 // VS
                4'b0111: cond_holds = ~v;                // VC
                4'b1000: cond_holds = cf & ~z;           // HI
                4'b1001: cond_holds = ~(cf & ~z);        // LS
                4'b1010: cond_holds = (n == v);          // GE
                4'b1011: cond_holds = (n != v);          // LT
                4'b1100: cond_holds = ~z & (n == v);     // GT
                4'b1101: cond_holds = ~(~z & (n == v));  // LE
                4'b1110: cond_holds = 1'b1;              // AL
                4'b1111: cond_holds = 1'b1;              // NV (always)
            endcase
        end
    endfunction

    // --- Expected outputs for the current inputs ---
    reg        exp_taken;
    reg [63:0] exp_target;

    task compute_expected;
        begin
            case (branch_type)
                3'b001:  exp_taken = 1'b1;                       // B
                3'b010:  exp_taken = 1'b1;                       // BL
                3'b011:  exp_taken = 1'b1;                       // BR
                3'b100:  exp_taken = 1'b1;                       // BLR
                3'b101:  exp_taken = (reg_rt == 64'd0);          // CBZ
                3'b110:  exp_taken = (reg_rt != 64'd0);          // CBNZ
                3'b111:  exp_taken = cond_holds(cond, nzcv);     // B.cond
                default: exp_taken = 1'b0;                       // none
            endcase
            if (branch_type == 3'b011 || branch_type == 3'b100)
                exp_target = reg_rn;                             // BR/BLR
            else
                exp_target = pc + (imm_ext << 2);                // PC-relative
        end
    endtask

    task run_case;
        input [2:0]      bt;
        input [63:0]     tpc, timm, trt, trn;
        input [3:0]      tcond, tnzcv;
        input [8*24-1:0] tag;
        begin
            branch_type = bt;
            pc = tpc; imm_ext = timm; reg_rt = trt; reg_rn = trn;
            cond = tcond; nzcv = tnzcv;
            #1;
            compute_expected;
            n_tests = n_tests + 1;
            if (branch_taken !== exp_taken) begin
                $display("FAIL [%0s]: taken got=%b exp=%b (bt=%b cond=%b nzcv=%b)",
                         tag, branch_taken, exp_taken, bt, tcond, tnzcv);
                errors = errors + 1;
            end
            // target only matters when taken; check it whenever taken to be strict,
            // and also check the PC-relative path on not-taken conditional branches.
            if (branch_target !== exp_target) begin
                $display("FAIL [%0s]: target got=%h exp=%h (bt=%b)",
                         tag, branch_target, exp_target, bt);
                errors = errors + 1;
            end
        end
    endtask

    integer ci;
    integer fi;
    reg [3:0] flagvec [0:7];

    integer k;
    reg [2:0]  rbt;
    reg [63:0] rpc, rimm, rrt, rrn;
    reg [3:0]  rcond, rnzcv;

    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_branch_unit);

        // --- none: never taken; target is PC-relative (don't-care but defined) ---
        run_case(3'b000, 64'h1000, 64'd2, 64'h0, 64'h0, 4'b0000, 4'b0000, "none");

        // --- unconditional PC-relative B / BL ---
        run_case(3'b001, 64'h0000_1000, 64'd4,  64'h0, 64'h0, 4'b0, 4'b0, "B +16");
        run_case(3'b010, 64'h0000_2000, 64'd8,  64'h0, 64'h0, 4'b0, 4'b0, "BL +32");
        // negative offset (sign-extended -1 -> *4 = -4)
        run_case(3'b001, 64'h0000_1000, 64'hFFFF_FFFF_FFFF_FFFF, 64'h0, 64'h0,
                 4'b0, 4'b0, "B -4");

        // --- register-indirect BR / BLR: target = reg_rn ---
        run_case(3'b011, 64'h1234, 64'd99, 64'h0, 64'hDEAD_BEEF_0000_1000, 4'b0, 4'b0, "BR");
        run_case(3'b100, 64'h1234, 64'd99, 64'h0, 64'hCAFE_0000_0000_0008, 4'b0, 4'b0, "BLR");

        // --- CBZ / CBNZ ---
        run_case(3'b101, 64'h2000, 64'd2, 64'h0,        64'h0, 4'b0, 4'b0, "CBZ z");
        run_case(3'b101, 64'h2000, 64'd2, 64'h1,        64'h0, 4'b0, 4'b0, "CBZ nz");
        run_case(3'b110, 64'h2000, 64'd2, 64'h0,        64'h0, 4'b0, 4'b0, "CBNZ z");
        run_case(3'b110, 64'h2000, 64'd2, 64'hFF,       64'h0, 4'b0, 4'b0, "CBNZ nz");
        run_case(3'b101, 64'h2000, 64'd2, 64'h8000_0000_0000_0000, 64'h0,
                 4'b0, 4'b0, "CBZ high-bit nz");

        // --- B.cond: all 16 codes against several flag patterns ---
        flagvec[0] = 4'b0000;  // N=0 Z=0 C=0 V=0
        flagvec[1] = 4'b0100;  // Z=1
        flagvec[2] = 4'b0010;  // C=1
        flagvec[3] = 4'b1000;  // N=1
        flagvec[4] = 4'b0001;  // V=1
        flagvec[5] = 4'b1001;  // N=1 V=1
        flagvec[6] = 4'b0110;  // Z=1 C=1
        flagvec[7] = 4'b1111;  // all set
        for (ci = 0; ci < 16; ci = ci + 1)
            for (fi = 0; fi < 8; fi = fi + 1)
                run_case(3'b111, 64'h4000, 64'd3, 64'h0, 64'h0,
                         ci[3:0], flagvec[fi], "B.cond");

        // --- randomized stress ---
        for (k = 0; k < 3000; k = k + 1) begin
            rbt   = $random;
            rpc   = {$random, $random};
            rimm  = {$random, $random};
            rrt   = {$random, $random};
            rrn   = {$random, $random};
            rcond = $random;
            rnzcv = $random;
            run_case(rbt, rpc, rimm, rrt, rrn, rcond, rnzcv, "rand");
        end

        if (errors == 0) $display("PASS: branch_unit (%0d cases)", n_tests);
        else             $display("FAIL: branch_unit - %0d / %0d errors", errors, n_tests);
        $finish;
    end

endmodule
