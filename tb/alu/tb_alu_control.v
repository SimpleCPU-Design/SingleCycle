`timescale 1ns/1ps

//  Coverage
//    1) alu_op_main = 00 → always ADD,  01 -> always SUB  (opcode ignored)
//    2) Every R-type opcode -> expected alu_op
//    3) Ambiguous-group funct disambiguation (MADD/MSUB, ASR/ROR/SDIV/UDIV)
//    4) Every I-type opcode -> expected alu_op

module tb_alu_control;
    reg  [1:0]  alu_op_main;
    reg  [10:0] opcode;
    reg  [5:0]  funct;
    wire [5:0]  alu_op;
    
    alu_control dut(
        .alu_op(alu_op),
        .alu_op_main(alu_op_main),
        .opcode(opcode),
        .funct(funct)
    );

    // alu_op codes
    localparam OP_ADD   = 6'b000000;
    localparam OP_SUB   = 6'b000001;
    localparam OP_AND   = 6'b000010;
    localparam OP_ORR   = 6'b000011;
    localparam OP_EOR   = 6'b000100;
    localparam OP_BIC   = 6'b000101;
    localparam OP_ORN   = 6'b000110;
    localparam OP_EON   = 6'b000111;
    localparam OP_LSL   = 6'b001000;
    localparam OP_LSR   = 6'b001001;
    localparam OP_ASR   = 6'b001010;
    localparam OP_ROR   = 6'b001011;
    localparam OP_SMULH = 6'b001101;
    localparam OP_UMULH = 6'b001110;
    localparam OP_MADD  = 6'b001111;
    localparam OP_MSUB  = 6'b010000;
    localparam OP_SDIV  = 6'b010001;
    localparam OP_UDIV  = 6'b010010;

    // alu_op_main codes
    localparam M_ADD = 2'b00;
    localparam M_SUB = 2'b01;
    localparam M_R   = 2'b10;
    localparam M_I   = 2'b11;

    integer errors = 0;
    integer n_tests = 0;

    task chk;
        input [1:0]      tmain;
        input [10:0]     topc;
        input [5:0]      tfun;
        input [5:0]      exp;
        input [8*32-1:0] tag;
        begin
            alu_op_main = tmain;
            opcode      = topc;
            funct       = tfun;
            #1;
            n_tests = n_tests + 1;
            if (alu_op !== exp) begin
                errors = errors + 1;
                $display("FAIL [%0s] main=%b opc=%b fun=%b", tag, tmain, topc, tfun);
                $display("           alu_op got=%b exp=%b", alu_op, exp);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_alu_control);

        // main = 00 / 01 force ADD / SUB (opcode must be ignored)
        chk(M_ADD, 11'h000, 6'h00, OP_ADD, "main00 a");
        chk(M_ADD, 11'h7FF, 6'h3F, OP_ADD, "main00 b");
        chk(M_ADD, 11'b10001011000, 6'h00, OP_ADD, "main00 c");
        chk(M_SUB, 11'h000, 6'h00, OP_SUB, "main01 a");
        chk(M_SUB, 11'h7FF, 6'h3F, OP_SUB, "main01 b");
        chk(M_SUB, 11'b11010011011, 6'h00, OP_SUB, "main01 c");

        // R-type opcodes
        chk(M_R, 11'b10001011000, 6'h00, OP_ADD,   "ADD"  );
        chk(M_R, 11'b10101011000, 6'h00, OP_ADD,   "ADDS" );
        chk(M_R, 11'b11001011000, 6'h00, OP_SUB,   "SUB"  );
        chk(M_R, 11'b11101011000, 6'h00, OP_SUB,   "SUBS" );
        chk(M_R, 11'b10001010000, 6'h00, OP_AND,   "AND"  );
        chk(M_R, 11'b10101010000, 6'h00, OP_ORR,   "ORR"  );
        chk(M_R, 11'b11001010000, 6'h00, OP_EOR,   "EOR"  );
        chk(M_R, 11'b11101010000, 6'h00, OP_AND,   "ANDS" );
        chk(M_R, 11'b00001010001, 6'h00, OP_BIC,   "BIC"  );
        chk(M_R, 11'b00101010001, 6'h00, OP_ORN,   "ORN"  );
        chk(M_R, 11'b01001010001, 6'h00, OP_EON,   "EON"  );
        chk(M_R, 11'b11010011011, 6'h00, OP_LSL,   "LSL"  );
        chk(M_R, 11'b11010011010, 6'h00, OP_LSR,   "LSR"  );
        chk(M_R, 11'b10011011010, 6'h00, OP_SMULH, "SMULH");
        chk(M_R, 11'b10011011110, 6'h00, OP_UMULH, "UMULH");

        // MUL/MADD/MSUB share 10011011000 -- instr[15]=o0 disambig
        chk(M_R, 11'b10011011000, 6'b000000, OP_MADD, "MADD (o0=0)");
        chk(M_R, 11'b10011011000, 6'b011111, OP_MADD, "MUL→MADD Ra=XZR");
        chk(M_R, 11'b10011011000, 6'b100000, OP_MSUB, "MSUB (o0=1)");
        chk(M_R, 11'b10011011000, 6'b111111, OP_MSUB, "MSUB Ra=all1");

        // ASR/ROR/SDIV/UDIV -- distinct opcodes (funct irrelevant)
        chk(M_R, 11'b11010011001, 6'h00, OP_ASR,  "ASR"    );
        chk(M_R, 11'b11010011001, 6'h3F, OP_ASR,  "ASR fX" ); // funct ignored
        chk(M_R, 11'b11010011000, 6'h00, OP_ROR,  "ROR"    );
        chk(M_R, 11'b11010011000, 6'h2A, OP_ROR,  "ROR fX" );
        chk(M_R, 11'b10011010110, 6'h00, OP_SDIV, "SDIV"   );
        chk(M_R, 11'b10011010110, 6'h15, OP_SDIV, "SDIV fX");
        chk(M_R, 11'b10011010111, 6'h00, OP_UDIV, "UDIV"   );
        chk(M_R, 11'b10011010111, 6'h3F, OP_UDIV, "UDIV fX");
        // distinctness: LSL/LSR neighbours must not be mistaken for ASR/ROR
        chk(M_R, 11'b11010011011, 6'h00, OP_LSL,  "LSL nbr");
        chk(M_R, 11'b11010011010, 6'h00, OP_LSR,  "LSR nbr");

        // I-type opcodes (opcode[10:1] = instr[31:22], opcode[0]=dontcare)
        //   ADDI  1001000100 -> opcode = 1001000100_0
        chk(M_I, 11'b10010001000, 6'h00, OP_ADD, "ADDI" );
        chk(M_I, 11'b10010001001, 6'h00, OP_ADD, "ADDI o0=1");
        //   SUBI  1101000100
        chk(M_I, 11'b11010001000, 6'h00, OP_SUB, "SUBI" );
        //   ADDIS 1011000100
        chk(M_I, 11'b10110001000, 6'h00, OP_ADD, "ADDIS");
        //   SUBIS 1111000100
        chk(M_I, 11'b11110001000, 6'h00, OP_SUB, "SUBIS");
        //   ANDI  1001001000
        chk(M_I, 11'b10010010000, 6'h00, OP_AND, "ANDI" );
        //   ORRI  1011001000
        chk(M_I, 11'b10110010000, 6'h00, OP_ORR, "ORRI" );
        //   EORI  1101001000
        chk(M_I, 11'b11010010000, 6'h00, OP_EOR, "EORI" );

        // Unknown opcode in R/I -> defaults to ADD (all-zero)
        chk(M_R, 11'b00000000000, 6'h00, OP_ADD, "R unknown");
        chk(M_I, 11'b00000000000, 6'h00, OP_ADD, "I unknown");

        // Summary
        $display("---------------------------------------------------");
        if (errors == 0) $display("PASS: alu_control — %0d cases", n_tests);
        else             $display("FAIL: alu_control — %0d / %0d errors", errors, n_tests);
        $finish;
    end
    
endmodule