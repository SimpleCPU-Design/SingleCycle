`timescale 1ns/1ps

module tb_div64;

    // DUT connections
    reg          clk, rst;
    reg          start, is_signed;
    reg  [63:0]  dividend, divisor;
    wire [63:0]  quotient, remainder;
    wire         busy, done;

    div64 dut(
        .quotient (quotient),
        .remainder(remainder),
        .busy     (busy),
        .done     (done),
        .dividend (dividend),
        .divisor  (divisor),
        .is_signed(is_signed),
        .start    (start),
        .clk      (clk),
        .rst      (rst)
    );

    // Clock generation (10 ns period)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Counters
    integer errors  = 0;
    integer n_tests = 0;

    // Golden reference
    //  Verilog "/" and "%" operators:
    //    signed:   trunc-toward-zero, remainder takes dividend's sign  (matches
    //              ARM SDIV)
    //    unsigned: standard
    //  Divide-by-zero is handled specially: q=0, r=dividend (matches ARM/DUT
    //  convention).
    task golden;
        input  [63:0] da;
        input  [63:0] dv;
        input         sgn;
        output [63:0] gq;
        output [63:0] gr;
        begin
            if (dv == 64'd0) begin
                gq = 64'd0;
                gr = da;
            end else if (sgn && da == 64'h8000000000000000
                             && dv == 64'hFFFFFFFFFFFFFFFF) begin
                gq = 64'h8000000000000000;
                gr = 64'd0;
            end else if (sgn) begin
                gq = $signed(da) / $signed(dv);
                gr = $signed(da) % $signed(dv);
            end else begin
                gq = da / dv;
                gr = da % dv;
            end
        end
    endtask

    // Single-case runner
    //   Sample inputs on negedge, hold start high for 1 cycle, wait for done.
    //   Timeout safety: 200 cycles (DUT's expected latency is ≤ 70).
    task run_case;
        input [63:0]      ta;
        input [63:0]      tb;
        input             tsgn;
        input [8*40-1:0]  tag;
        reg   [63:0]      exp_q, exp_r;
        integer           cycles;
        begin
            @(negedge clk);
            dividend  = ta;
            divisor   = tb;
            is_signed = tsgn;
            start     = 1'b1;
            @(negedge clk);
            start = 1'b0;

            cycles = 0;
            while (!done && cycles < 200) begin
                @(negedge clk);
                cycles = cycles + 1;
            end

            n_tests = n_tests + 1;
            golden(ta, tb, tsgn, exp_q, exp_r);

            if (cycles >= 200) begin
                errors = errors + 1;
                $display("FAIL [%0s]: TIMEOUT (no done) sgn=%0d a=%h b=%h",
                         tag, tsgn, ta, tb);
            end else if (quotient !== exp_q || remainder !== exp_r) begin
                errors = errors + 1;
                $display("FAIL [%0s] sgn=%0d a=%h b=%h", tag, tsgn, ta, tb);
                $display("           q got=%h exp=%h", quotient,  exp_q);
                $display("           r got=%h exp=%h", remainder, exp_r);
            end
        end
    endtask

    integer i;
    reg [63:0] ra, rb;

    // Test program
    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_div64);

        // Reset
        rst       = 1'b1;
        start     = 1'b0;
        is_signed = 1'b0;
        dividend  = 64'b0;
        divisor   = 64'b0;
        @(negedge clk);
        @(negedge clk);
        rst = 1'b0;
        @(negedge clk);

        // 1) UNSIGNED directed cases
        run_case(64'd0,                  64'd1,                  1'b0, "u 0/1");
        run_case(64'd1,                  64'd1,                  1'b0, "u 1/1");
        run_case(64'd2,                  64'd1,                  1'b0, "u 2/1");
        run_case(64'd10,                 64'd3,                  1'b0, "u 10/3");
        run_case(64'd100,                64'd7,                  1'b0, "u 100/7");
        run_case(64'd1234567890,         64'd13,                 1'b0, "u 1234.../13");
        run_case(64'd1,                  64'hFFFFFFFFFFFFFFFF,   1'b0, "u 1/MAX");
        run_case(64'd0,                  64'hFFFFFFFFFFFFFFFF,   1'b0, "u 0/MAX");
        run_case(64'hFFFFFFFFFFFFFFFF,   64'd1,                  1'b0, "u MAX/1");
        run_case(64'hFFFFFFFFFFFFFFFF,   64'd2,                  1'b0, "u MAX/2");
        run_case(64'hFFFFFFFFFFFFFFFF,   64'hFFFFFFFFFFFFFFFF,   1'b0, "u MAX/MAX");
        run_case(64'h8000000000000000,   64'd1,                  1'b0, "u 2^63/1");
        run_case(64'h8000000000000000,   64'd2,                  1'b0, "u 2^63/2");
        run_case(64'hDEADBEEFCAFEBABE,   64'd123456,             1'b0, "u dead/123456");
        run_case(64'hAAAAAAAAAAAAAAAA,   64'h5555555555555555,   1'b0, "u alt/alt");
        run_case(64'h0123456789ABCDEF,   64'hFEDCBA9876543210,   1'b0, "u hex/hex");

        // 2) SIGNED directed — all 4 sign combinations
        run_case( 64'd7,                 64'd3,                  1'b1, "s 7/3");
        run_case(-64'd7,                 64'd3,                  1'b1, "s -7/3");
        run_case( 64'd7,                -64'd3,                  1'b1, "s 7/-3");
        run_case(-64'd7,                -64'd3,                  1'b1, "s -7/-3");
        run_case( 64'd100,               64'd7,                  1'b1, "s 100/7");
        run_case(-64'd100,               64'd7,                  1'b1, "s -100/7");
        run_case( 64'd100,              -64'd7,                  1'b1, "s 100/-7");
        run_case(-64'd100,              -64'd7,                  1'b1, "s -100/-7");
        run_case( 64'd1,                 64'd1,                  1'b1, "s 1/1");
        run_case(-64'd1,                -64'd1,                  1'b1, "s -1/-1");
        run_case(-64'd1,                 64'd1,                  1'b1, "s -1/1");
        run_case( 64'd1,                -64'd1,                  1'b1, "s 1/-1");

        // 3) SIGNED corners — INT_MIN / INT_MAX combinations
        run_case(64'h8000000000000000,   64'd1,                  1'b1, "s INT_MIN/1");
        run_case(64'h8000000000000000,  -64'd1,                  1'b1, "s INT_MIN/-1");
        run_case(64'h8000000000000000,   64'd2,                  1'b1, "s INT_MIN/2");
        run_case(64'h8000000000000000,  -64'd2,                  1'b1, "s INT_MIN/-2");
        run_case(64'h8000000000000000,   64'h8000000000000000,   1'b1, "s INT_MIN/INT_MIN");
        run_case(64'h8000000000000000,   64'h7FFFFFFFFFFFFFFF,   1'b1, "s INT_MIN/INT_MAX");
        run_case(64'h7FFFFFFFFFFFFFFF,   64'd1,                  1'b1, "s INT_MAX/1");
        run_case(64'h7FFFFFFFFFFFFFFF,  -64'd1,                  1'b1, "s INT_MAX/-1");
        run_case(64'h7FFFFFFFFFFFFFFF,   64'd2,                  1'b1, "s INT_MAX/2");
        run_case(64'h7FFFFFFFFFFFFFFF,   64'h7FFFFFFFFFFFFFFF,   1'b1, "s INT_MAX/INT_MAX");
        run_case(64'h7FFFFFFFFFFFFFFF,   64'h8000000000000000,   1'b1, "s INT_MAX/INT_MIN");

        // 4) Divide-by-zero — ARM: q=0, r=dividend
        run_case(64'd0,                  64'd0,                  1'b0, "u 0/0");
        run_case(64'd5,                  64'd0,                  1'b0, "u 5/0");
        run_case(64'd1,                  64'd0,                  1'b0, "u 1/0");
        run_case(64'hFFFFFFFFFFFFFFFF,   64'd0,                  1'b0, "u MAX/0");
        run_case(64'd0,                  64'd0,                  1'b1, "s 0/0");
        run_case( 64'd5,                 64'd0,                  1'b1, "s 5/0");
        run_case(-64'd5,                 64'd0,                  1'b1, "s -5/0");
        run_case(64'h8000000000000000,   64'd0,                  1'b1, "s INT_MIN/0");
        run_case(64'h7FFFFFFFFFFFFFFF,   64'd0,                  1'b1, "s INT_MAX/0");

        // 5) Single-bit walk — 2^i / 2^i = 1, 2^i / 1 = 2^i
        for (i = 0; i < 64; i = i + 1) begin
            run_case(64'd1 << i, 64'd1,    1'b0, "u walk/1");
            run_case(64'd1 << i, 64'd1<<i, 1'b0, "u walk/walk");
        end

        // 6) Random UNSIGNED — 500 cases
        for (i = 0; i < 500; i = i + 1) begin
            ra = {$random, $random};
            rb = {$random, $random};
            run_case(ra, rb, 1'b0, "rand u");
        end

        // 7) Random SIGNED — 500 cases
        for (i = 0; i < 500; i = i + 1) begin
            ra = {$random, $random};
            rb = {$random, $random};
            run_case(ra, rb, 1'b1, "rand s");
        end

        // 8) Random small divisor (16-bit) — exercises more iterations
        for (i = 0; i < 100; i = i + 1) begin
            ra = {$random, $random};
            rb = {$random, $random} & 64'hFFFF;
            run_case(ra, rb, 1'b0, "small_u");
            run_case(ra, rb, 1'b1, "small_s");
        end

        // 9) Random large divisor (upper 32 bits set)
        for (i = 0; i < 100; i = i + 1) begin
            ra  = {$random, $random};
            rb  = {$random, $random} | 64'hFFFFFFFF00000000;
            run_case(ra, rb, 1'b0, "bigdiv_u");
            run_case(ra, rb, 1'b1, "bigdiv_s");
        end

        // Summary
        $display("---------------------------------------------------");
        if (errors == 0) $display("PASS: div64 — %0d cases", n_tests);
        else             $display("FAIL: div64 — %0d / %0d errors", errors, n_tests);
        $finish;
    end

    // Global timeout safety
    initial begin
        #50000000;   // 50 ms
        $display("FATAL: tb_div64 global timeout");
        $finish;
    end

endmodule
