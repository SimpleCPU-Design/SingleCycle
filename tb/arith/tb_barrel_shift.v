`timescale 1ns/1ps

module tb_barrel_shift;
    reg [63:0] a;
    reg [5:0] shamt;
    reg [1:0] op;
    wire [63:0] y;

    barrel_shift dut(
        .y(y), 
        .a(a), 
        .shamt(shamt), 
        .op(op)
    );

    function [63:0] ref_shift;
        input [63:0] va;
        input [5:0]  vsh;
        input [1:0]  vop;
        begin
            case (vop)
                2'b00: ref_shift = va << vsh;                          // LSL
                2'b01: ref_shift = va >> vsh;                          // LSR
                2'b10: ref_shift = $signed(va) >>> vsh;                // ASR
                2'b11: begin                                           // ROR
                    if (vsh == 6'd0) ref_shift = va;                   // shamt=0 edge
                    else ref_shift = (va >> vsh) | (va << (7'd64 - vsh));
                end
                default: ref_shift = 64'hx;
            endcase
        end
    endfunction

    integer errors  = 0;
    integer n_tests = 0;

    task run_case;
        input [63:0]      va;
        input [5:0]       vsh;
        input [1:0]       vop;
        input [8*40-1:0]  tag;
        reg   [63:0]      exp;
        begin
            a = va; shamt = vsh; op = vop;
            #1;
            exp = ref_shift(va, vsh, vop);
            n_tests = n_tests + 1;
            if (y !== exp) begin
                $display("FAIL [%0s]: a=%h shamt=%0d op=%b | got=%h exp=%h",
                         tag, va, vsh, vop, y, exp);
                errors = errors + 1;
            end
        end
    endtask

    integer i, k;
    reg [63:0] ra;
    reg [5:0]  rs;
    reg [1:0]  ro;

    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_barrel_shift);

        // ─── 1) shamt=0
        run_case(64'hDEADBEEFCAFEBABE, 6'd0, 2'b00, "LSL sh0");
        run_case(64'hDEADBEEFCAFEBABE, 6'd0, 2'b01, "LSR sh0");
        run_case(64'hDEADBEEFCAFEBABE, 6'd0, 2'b10, "ASR sh0");
        run_case(64'hDEADBEEFCAFEBABE, 6'd0, 2'b11, "ROR sh0");

        // ─── 2) shamt=63
        run_case(64'h1,                   6'd63, 2'b00, "LSL sh63");  // → 0x80...00
        run_case(64'h8000000000000000,    6'd63, 2'b01, "LSR sh63");  // → 0x1
        run_case(64'h8000000000000000,    6'd63, 2'b10, "ASR sh63");  // → 0xFF..FF
        run_case(64'h7FFFFFFFFFFFFFFF,    6'd63, 2'b10, "ASR sh63 pos"); // → 0x0
        run_case(64'h8000000000000001,    6'd63, 2'b11, "ROR sh63");

        // ─── 3) shamt=32
        run_case(64'h00000000FFFFFFFF, 6'd32, 2'b00, "LSL sh32");  // → 0xFFFFFFFF00000000
        run_case(64'hFFFFFFFF00000000, 6'd32, 2'b01, "LSR sh32");  // → 0x00000000FFFFFFFF
        run_case(64'h8000000000000000, 6'd32, 2'b10, "ASR sh32");
        run_case(64'h0123456789ABCDEF, 6'd32, 2'b11, "ROR sh32");

        // ─── 4) shamt = 1, 2, 4, 8, 16
        run_case(64'hAAAAAAAAAAAAAAAA, 6'd1,  2'b00, "LSL 1");
        run_case(64'hAAAAAAAAAAAAAAAA, 6'd2,  2'b00, "LSL 2");
        run_case(64'hAAAAAAAAAAAAAAAA, 6'd4,  2'b00, "LSL 4");
        run_case(64'hAAAAAAAAAAAAAAAA, 6'd8,  2'b00, "LSL 8");
        run_case(64'hAAAAAAAAAAAAAAAA, 6'd16, 2'b00, "LSL 16");

        run_case(64'h5555555555555555, 6'd1,  2'b01, "LSR 1");
        run_case(64'h5555555555555555, 6'd2,  2'b01, "LSR 2");
        run_case(64'h5555555555555555, 6'd4,  2'b01, "LSR 4");
        run_case(64'h5555555555555555, 6'd8,  2'b01, "LSR 8");
        run_case(64'h5555555555555555, 6'd16, 2'b01, "LSR 16");

        // ─── 5)
        run_case(64'hFFFFFFFFFFFFFFFF, 6'd1,  2'b10, "ASR all1 sh1");   // → all1
        run_case(64'hFFFFFFFFFFFFFFFF, 6'd31, 2'b10, "ASR all1 sh31");
        run_case(64'h8000000000000000, 6'd1,  2'b10, "ASR INTMIN sh1"); // → 0xC0...00
        run_case(64'h7FFFFFFFFFFFFFFF, 6'd1,  2'b10, "ASR INTMAX sh1"); // → 0x3F...FF
        run_case(64'h0,                6'd5,  2'b10, "ASR zero");
        run_case(64'hFEDCBA9876543210, 6'd17, 2'b10, "ASR neg pattern");

        // ─── 6) ROR
        run_case(64'h0123456789ABCDEF, 6'd4,  2'b11, "ROR 4");
        run_case(64'hF000000000000001, 6'd4,  2'b11, "ROR 4 wrap");
        // ROR 1, ROR 2, ROR 4, ROR 8, ROR 16 — her aşamayı izole ediyor
        run_case(64'h8000000000000001, 6'd1,  2'b11, "ROR 1");
        run_case(64'h8000000000000001, 6'd2,  2'b11, "ROR 2");
        run_case(64'h8000000000000001, 6'd16, 2'b11, "ROR 16");

        // ─── 7) LSL and LSR
        for (i = 0; i < 64; i = i + 1) begin
            // LSL: 1 << i
            run_case(64'h1, i[5:0], 2'b00, "LSL bitwalk");
            // LSR: 0x80...00 >> i
            run_case(64'h8000000000000000, i[5:0], 2'b01, "LSR bitwalk");
        end

        // ─── 8) ROR all shamt values
        for (i = 0; i < 64; i = i + 1) begin
            run_case(64'h0123456789ABCDEF, i[5:0], 2'b11, "ROR sweep");
        end

        // ─── 9) Random 1000
        for (i = 0; i < 1000; i = i + 1) begin
            ra = {$random, $random};
            rs = $random;          // alt 6 bit
            ro = $random;          // alt 2 bit
            run_case(ra, rs, ro, "rand");
        end

        // ─── Summary
        if (errors == 0) $display("PASS: barrel_shift (%0d cases)", n_tests);
        else             $display("FAIL: barrel_shift — %0d / %0d errors", errors, n_tests);
        $finish;
    end

endmodule