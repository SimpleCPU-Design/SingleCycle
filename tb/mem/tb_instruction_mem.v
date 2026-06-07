`timescale 1ns/1ps

// ================================================================================
//  tb_instruction_mem -- self-checking testbench for the instruction ROM.
//
//  Loads a known 8-word image (sim/itest.hex, written to disk before the run)
//  and checks that each PC byte address returns the matching word, that the low
//  two PC bits are ignored (word alignment), and that reads are combinational.
// ================================================================================

module tb_instruction_mem;
    reg  [63:0] addr;
    wire [31:0] instr;

    instruction_mem #(.DEPTH_LOG2(10), .INIT_FILE("sim/itest.hex")) dut(
        .instr(instr),
        .addr (addr)
    );

    integer errors  = 0;
    integer n_tests = 0;

    // expected image (must match sim/itest.hex)
    reg [31:0] golden [0:7];

    task chk;
        input [63:0]     a;
        input [31:0]     exp;
        input [8*24-1:0] tag;
        begin
            addr = a;
            #1;
            n_tests = n_tests + 1;
            if (instr !== exp) begin
                $display("FAIL [%0s]: addr=%h instr=%h exp=%h", tag, a, instr, exp);
                errors = errors + 1;
            end
        end
    endtask

    integer i;
    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_instruction_mem);

        golden[0] = 32'h8B010020; golden[1] = 32'hCB020041;
        golden[2] = 32'hF8400123; golden[3] = 32'hF8000456;
        golden[4] = 32'h14000004; golden[5] = 32'hD61F0120;
        golden[6] = 32'hDEADBEEF; golden[7] = 32'h00000000;

        // word-aligned fetches
        for (i = 0; i < 8; i = i + 1)
            chk(i*4, golden[i], "aligned");

        // low two PC bits ignored within a word
        chk(64'h1, golden[0], "addr+1");
        chk(64'h2, golden[0], "addr+2");
        chk(64'h3, golden[0], "addr+3");
        chk(64'h7, golden[1], "word1+3");

        if (errors == 0) $display("PASS: instruction_mem (%0d cases)", n_tests);
        else             $display("FAIL: instruction_mem - %0d / %0d errors", errors, n_tests);
        $finish;
    end
endmodule
