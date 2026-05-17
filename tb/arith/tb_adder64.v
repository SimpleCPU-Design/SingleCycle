`timescale 1ns/1ps

module tb_adder64;
    reg [63:0] a, b;
    reg cin;
    wire [63:0] sum;
    wire cout;

    adder64 dut(
        .sum(sum),
        .cout(cout),
        .a(a),
        .b(b),
        .cin(cin)
    );

    reg [63:0] ref_sum;
    reg ref_cout;
    integer errors = 0;
    integer n_tests = 0;

    task run_case;
        input [63:0] ta, tb_in;
        input tcin;
        input [8*40-1:0] tag;
        begin
            a = ta;
            b = tb_in;
            cin = tcin;
            #1;
            {ref_cout, ref_sum} = ta + tb_in + tcin;
            n_tests = n_tests + 1;
            if (sum !== ref_sum || cout !== ref_cout) begin
                $display("FAIL [%0s]: a=%h b=%h cin=%b | sum got=%h exp=%h | cout got=%b exp=%b",
                         tag, ta, tb_in, tcin, sum, ref_sum, cout, ref_cout);
                errors = errors + 1;
            end
        end
    endtask

    integer i;
    reg[63:0] ra, rb;
    reg rc;

    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_adder64);

        // --- 1
        run_case(64'h0, 64'h0, 1'b0, "0+0+0");
        run_case(64'h0, 64'h0, 1'b1, "0+0+1");
        run_case(64'h1, 64'h0, 1'b0, "1+0");
        run_case(64'h0, 64'h1, 1'b0, "0+1");

        // --- 2
        run_case(64'hFFFFFFFFFFFFFFFF, 64'h1, 1'b0, "ALL1+1=0,c=1");
        run_case(64'hFFFFFFFFFFFFFFFF, 64'h0, 1'b1, "ALL1+cin");
        run_case(64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 1'b0, "MAX+MAX");
        run_case(64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 1'b1, "MAX+MAX+1");

        // --- 3
        run_case(64'h00000000FFFFFFFF, 64'h0000000000000001, 1'b0, "lo32 carry");
        run_case(64'hFFFFFFFF00000000, 64'h0000000100000000, 1'b0, "hi32 carry");

        // --- 4
        // INT64_MAX = 0x7FFF...FF, INT64_MIN = 0x8000...00
        run_case(64'h7FFFFFFFFFFFFFFF, 64'h1, 1'b0, "INTMAX+1");           // pos overflow
        run_case(64'h8000000000000000, 64'hFFFFFFFFFFFFFFFF, 1'b0, "INTMIN+(-1)"); // neg overflow
        run_case(64'h7FFFFFFFFFFFFFFF, 64'h7FFFFFFFFFFFFFFF, 1'b0, "INTMAX+INTMAX");
        run_case(64'h8000000000000000, 64'h8000000000000000, 1'b0, "INTMIN+INTMIN");

        // --- 5
        for (i = 0; i < 64; i = i + 1) begin
            run_case(64'h1 << i, 64'h1 << i, 1'b0, "bit_walk");
        end

        // --- 6
        run_case(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555, 1'b0, "alt+alt=ALL1");
        run_case(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555, 1'b1, "alt+alt+1");
        run_case(64'hDEADBEEFCAFEBABE, 64'h0123456789ABCDEF, 1'b0, "whatever_this_is");
        run_case(64'hDEADBEEFCAFEBABE, 64'h0123456789ABCDEF, 1'b1, "whatever_this_is + 1");

        // --- 7
        for (i = 0; i < 1000; i = i + 1) begin
            ra = {$random, $random};
            rb = {$random, $random};
            rc = $random;
            run_case(ra, rb, rc, "rand");
        end

        // --- Summary
        if (errors == 0) $display("PASS: adder64 (%0d cases)", n_tests);
        else             $display("FAIL: adder64 — %0d / %0d errors", errors, n_tests);
        $finish;
    end
    
endmodule