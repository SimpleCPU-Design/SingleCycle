`timescale 1ns/1ps

// ================================================================================
//  tb_control -- directed, self-checking testbench for the main control decoder.
//
//  One case per instruction: drives the 11-bit opcode and compares the entire
//  control vector against a hand-computed golden value.  Also checks that the
//  immediate-MSB bit (I-type) and the operand low bits (B/CB/IW prefixes) are
//  ignored, and that deferred / unknown opcodes decode to an inert NOP vector.
//  Purely combinational DUT, so each case is: drive opcode, settle, compare.
// ================================================================================

module tb_control;
    reg  [10:0] opcode;
    wire        reg_write, alu_src, mem_read, mem_write, mem_sign_ext, flag_write;
    wire        pair_op, reg2_loc;
    wire [1:0]  mem_to_reg, alu_op_main, mov_type;
    wire [2:0]  mem_width, branch_type, imm_sel;

    control dut(
        .reg_write   (reg_write),
        .alu_src     (alu_src),
        .mem_to_reg  (mem_to_reg),
        .mem_read    (mem_read),
        .mem_write   (mem_write),
        .mem_width   (mem_width),
        .mem_sign_ext(mem_sign_ext),
        .flag_write  (flag_write),
        .branch_type (branch_type),
        .alu_op_main (alu_op_main),
        .mov_type    (mov_type),
        .pair_op     (pair_op),
        .reg2_loc    (reg2_loc),
        .imm_sel     (imm_sel),
        .opcode      (opcode)
    );

    integer errors  = 0;
    integer n_tests = 0;

    // Drive one opcode, compare the full control vector field-by-field.
    //   args: op, rw, as, m2r, mr, mw, mwid, mse, fw, bt, aom, mov, po, r2l, is, tag
    task run_case;
        input [10:0]     op;
        input            e_rw, e_as;
        input [1:0]      e_m2r;
        input            e_mr, e_mw;
        input [2:0]      e_mwid;
        input            e_mse, e_fw;
        input [2:0]      e_bt;
        input [1:0]      e_aom, e_mov;
        input            e_po, e_r2l;
        input [2:0]      e_is;
        input [8*20-1:0] tag;
        begin
            opcode = op;
            #1;
            n_tests = n_tests + 1;
            if (reg_write    !== e_rw  || alu_src     !== e_as  ||
                mem_to_reg   !== e_m2r || mem_read    !== e_mr  ||
                mem_write    !== e_mw  || mem_width   !== e_mwid ||
                mem_sign_ext !== e_mse || flag_write  !== e_fw  ||
                branch_type  !== e_bt  || alu_op_main !== e_aom ||
                mov_type     !== e_mov || pair_op     !== e_po  ||
                reg2_loc     !== e_r2l || imm_sel     !== e_is) begin
                $display("FAIL [%0s] op=%b", tag, op);
                $display("   got rw=%b as=%b m2r=%b mr=%b mw=%b mwid=%b mse=%b fw=%b bt=%b aom=%b mov=%b po=%b r2l=%b is=%b",
                    reg_write,alu_src,mem_to_reg,mem_read,mem_write,mem_width,
                    mem_sign_ext,flag_write,branch_type,alu_op_main,mov_type,pair_op,reg2_loc,imm_sel);
                $display("   exp rw=%b as=%b m2r=%b mr=%b mw=%b mwid=%b mse=%b fw=%b bt=%b aom=%b mov=%b po=%b r2l=%b is=%b",
                    e_rw,e_as,e_m2r,e_mr,e_mw,e_mwid,e_mse,e_fw,e_bt,e_aom,e_mov,e_po,e_r2l,e_is);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_control);

        //        op             rw as m2r  mr mw mwid mse fw bt   aom mov po r2l is
        // --- R-type arithmetic ---
        run_case(11'b10001011000, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"ADD");
        run_case(11'b11001011000, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"SUB");
        run_case(11'b10101011000, 1,0,2'b00,0,0,3'b000,0,1,3'b000,2'b10,2'b00,0,0,3'b000,"ADDS");
        run_case(11'b11101011000, 1,0,2'b00,0,0,3'b000,0,1,3'b000,2'b10,2'b00,0,0,3'b000,"SUBS");
        run_case(11'b10011011000, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"MUL/MADD/MSUB");
        run_case(11'b10011011010, 1,0,2'b11,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"SMULH");
        run_case(11'b10011011110, 1,0,2'b11,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"UMULH");
        run_case(11'b10011010110, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"SDIV");
        run_case(11'b10011010111, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"UDIV");

        // --- R-type logical / shift ---
        run_case(11'b10001010000, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"AND");
        run_case(11'b10101010000, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"ORR");
        run_case(11'b11001010000, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"EOR");
        run_case(11'b11101010000, 1,0,2'b00,0,0,3'b000,0,1,3'b000,2'b10,2'b00,0,0,3'b000,"ANDS");
        run_case(11'b11010011011, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"LSL");
        run_case(11'b11010011010, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"LSR");
        run_case(11'b11010011001, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"ASR");
        run_case(11'b11010011000, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"ROR");
        run_case(11'b00001010001, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"BIC");
        run_case(11'b00101010001, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"ORN");
        run_case(11'b01001010001, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b10,2'b00,0,0,3'b000,"EON");

        // --- I-type (append imm-MSB = 0) ---
        run_case(11'b10010001000, 1,1,2'b00,0,0,3'b000,0,0,3'b000,2'b11,2'b00,0,0,3'b000,"ADDI");
        run_case(11'b11010001000, 1,1,2'b00,0,0,3'b000,0,0,3'b000,2'b11,2'b00,0,0,3'b000,"SUBI");
        run_case(11'b10110001000, 1,1,2'b00,0,0,3'b000,0,1,3'b000,2'b11,2'b00,0,0,3'b000,"ADDIS");
        run_case(11'b11110001000, 1,1,2'b00,0,0,3'b000,0,1,3'b000,2'b11,2'b00,0,0,3'b000,"SUBIS");
        run_case(11'b10010010000, 1,1,2'b00,0,0,3'b000,0,0,3'b000,2'b11,2'b00,0,0,3'b000,"ANDI");
        run_case(11'b10110010000, 1,1,2'b00,0,0,3'b000,0,0,3'b000,2'b11,2'b00,0,0,3'b000,"ORRI");
        run_case(11'b11010010000, 1,1,2'b00,0,0,3'b000,0,0,3'b000,2'b11,2'b00,0,0,3'b000,"EORI");
        // imm-MSB must be ignored: ADDI with opcode[0]=1 -> identical vector
        run_case(11'b10010001001, 1,1,2'b00,0,0,3'b000,0,0,3'b000,2'b11,2'b00,0,0,3'b000,"ADDI imm-msb=1");

        // --- D-type loads ---
        run_case(11'b11111000010, 1,1,2'b01,1,0,3'b000,0,0,3'b000,2'b00,2'b00,0,0,3'b001,"LDUR");
        run_case(11'b10111000100, 1,1,2'b01,1,0,3'b001,1,0,3'b000,2'b00,2'b00,0,0,3'b001,"LDURSW");
        run_case(11'b01111000010, 1,1,2'b01,1,0,3'b010,0,0,3'b000,2'b00,2'b00,0,0,3'b001,"LDURH");
        run_case(11'b00111000010, 1,1,2'b01,1,0,3'b011,0,0,3'b000,2'b00,2'b00,0,0,3'b001,"LDURB");
        run_case(11'b01111000100, 1,1,2'b01,1,0,3'b010,1,0,3'b000,2'b00,2'b00,0,0,3'b001,"LDURSH");
        run_case(11'b00111000100, 1,1,2'b01,1,0,3'b011,1,0,3'b000,2'b00,2'b00,0,0,3'b001,"LDURSB");
        run_case(11'b11001000010, 1,1,2'b01,1,0,3'b000,0,0,3'b000,2'b00,2'b00,0,0,3'b001,"LDXR");

        // --- D-type stores ---
        run_case(11'b11111000000, 0,1,2'b00,0,1,3'b000,0,0,3'b000,2'b00,2'b00,0,1,3'b001,"STUR");
        run_case(11'b10111000000, 0,1,2'b00,0,1,3'b001,0,0,3'b000,2'b00,2'b00,0,1,3'b001,"STURW");
        run_case(11'b01111000000, 0,1,2'b00,0,1,3'b010,0,0,3'b000,2'b00,2'b00,0,1,3'b001,"STURH");
        run_case(11'b00111000000, 0,1,2'b00,0,1,3'b011,0,0,3'b000,2'b00,2'b00,0,1,3'b001,"STURB");
        run_case(11'b11001000000, 0,1,2'b00,0,1,3'b000,0,0,3'b000,2'b00,2'b00,0,1,3'b001,"STXR");

        // --- P-type pair ---
        run_case(11'b10101001010, 1,1,2'b01,1,0,3'b000,0,0,3'b000,2'b00,2'b00,1,0,3'b101,"LDP");
        run_case(11'b10101001000, 0,1,2'b00,0,1,3'b000,0,0,3'b000,2'b00,2'b00,1,1,3'b101,"STP");

        // --- IW-type (append low bits = 00) ---
        run_case(11'b11010010100, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b00,2'b01,0,0,3'b100,"MOVZ");
        run_case(11'b11110010100, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b00,2'b10,0,0,3'b100,"MOVK");
        // operand low bits ignored
        run_case(11'b11010010111, 1,0,2'b00,0,0,3'b000,0,0,3'b000,2'b00,2'b01,0,0,3'b100,"MOVZ low=11");

        // --- CB-type (append low bits = 000) ---
        run_case(11'b10110100000, 0,0,2'b00,0,0,3'b000,0,0,3'b101,2'b01,2'b00,0,1,3'b011,"CBZ");
        run_case(11'b10110101000, 0,0,2'b00,0,0,3'b000,0,0,3'b110,2'b01,2'b00,0,1,3'b011,"CBNZ");
        run_case(11'b01010100000, 0,0,2'b00,0,0,3'b000,0,0,3'b111,2'b00,2'b00,0,0,3'b011,"B.cond");
        run_case(11'b10110100111, 0,0,2'b00,0,0,3'b000,0,0,3'b101,2'b01,2'b00,0,1,3'b011,"CBZ low=111");

        // --- B-type (append low bits = 00000) ---
        run_case(11'b00010100000, 0,0,2'b00,0,0,3'b000,0,0,3'b001,2'b00,2'b00,0,0,3'b010,"B");
        run_case(11'b10010100000, 1,0,2'b10,0,0,3'b000,0,0,3'b010,2'b00,2'b00,0,0,3'b010,"BL");
        run_case(11'b00010111111, 0,0,2'b00,0,0,3'b000,0,0,3'b001,2'b00,2'b00,0,0,3'b010,"B low=11111");

        // --- R-type branch (register indirect) ---
        run_case(11'b11010110000, 0,0,2'b00,0,0,3'b000,0,0,3'b011,2'b00,2'b00,0,0,3'b000,"BR");
        run_case(11'b11010110001, 1,0,2'b10,0,0,3'b000,0,0,3'b100,2'b00,2'b00,0,0,3'b000,"BLR");

        // --- Inert: NOP / HLT / BRK / deferred CSEL / unknown -> all-zero vector ---
        run_case(11'b11010101000, 0,0,2'b00,0,0,3'b000,0,0,3'b000,2'b00,2'b00,0,0,3'b000,"NOP");
        run_case(11'b11010100010, 0,0,2'b00,0,0,3'b000,0,0,3'b000,2'b00,2'b00,0,0,3'b000,"HLT");
        run_case(11'b11010100001, 0,0,2'b00,0,0,3'b000,0,0,3'b000,2'b00,2'b00,0,0,3'b000,"BRK");
        run_case(11'b10011010100, 0,0,2'b00,0,0,3'b000,0,0,3'b000,2'b00,2'b00,0,0,3'b000,"CSEL (deferred)");
        run_case(11'b11011010101, 0,0,2'b00,0,0,3'b000,0,0,3'b000,2'b00,2'b00,0,0,3'b000,"CSNEG (deferred)");
        run_case(11'b00000000000, 0,0,2'b00,0,0,3'b000,0,0,3'b000,2'b00,2'b00,0,0,3'b000,"unknown 0");

        // --- Summary
        if (errors == 0) $display("PASS: control (%0d cases)", n_tests);
        else             $display("FAIL: control - %0d / %0d errors", errors, n_tests);
        $finish;
    end

endmodule
