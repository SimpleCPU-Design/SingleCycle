`timescale 1ns/1ps

module tb_mul64;
    reg [63:0] a, b;
    reg is_signed;
    wire [127:0] product;

    mul64 dut(
        .product(product),
        .a(a),
        .b(b),
        .is_signed(is_signed)
    );

    integer errors = 0;
    integer total = 0;

    function [127:0] mult;
        input [63:0] x;
        input [63:0] y;
        input sgn;
        reg [127:0] xe, ye;
        begin
            if (sgn) begin
                xe = {{64{x[63]}}, x};
                ye = {{64{y[63]}}, y};
                mult = $signed(xe) * $signed(ye);
            end else begin
                xe = {64'b0, x};
                ye = {64'b0, y};
                mult = xe * ye;
            end
        end
    endfunction

    task chk;
        input [8*32-1:0] tag;
        reg [127:0] exp;
        begin
            #1;
            exp = mult(a, b, is_signed);
            total = total + 1;
            if (product !== exp) begin
                errors = errors + 1;
                $display("FAIL [%0s] sgn=%0d a=%h b=%h", tag, is_signed, a, b);
                $display("              got=%h", product);
                $display("              exp=%h", exp);
            end
        end
    endtask

    integer i;
    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_mul64);

        // --- UNSIGNED ---
        is_signed = 1'b0;
        a = 64'd0;                   b = 64'd0;                   chk("u 0*0");
        a = 64'd1;                   b = 64'd0;                   chk("u 1*0");
        a = 64'd0;                   b = 64'd1;                   chk("u 0*1");
        a = 64'd1;                   b = 64'd1;                   chk("u 1*1");
        a = 64'd2;                   b = 64'd3;                   chk("u 2*3");
        a = 64'd7;                   b = 64'd9;                   chk("u 7*9");
        a = 64'hDEAD_BEEF;           b = 64'hCAFE_BABE;           chk("u dead*cafe");
        a = 64'hFFFF_FFFF;           b = 64'hFFFF_FFFF;           chk("u max32^2");
        a = 64'hFFFFFFFFFFFFFFFF;    b = 64'd1;                   chk("u max64*1");
        a = 64'hFFFFFFFFFFFFFFFF;    b = 64'hFFFFFFFFFFFFFFFF;    chk("u max64^2");
        a = 64'h8000000000000000;    b = 64'h8000000000000000;    chk("u msb*msb");
        a = 64'hAAAAAAAAAAAAAAAA;    b = 64'h5555555555555555;    chk("u alt-bits");

        // --- SIGNED ---
        is_signed = 1'b1;
        a = 64'd0;                   b = 64'd0;                   chk("s 0*0");
        a = 64'd1;                   b = 64'd1;                   chk("s 1*1");
        a = -64'd1;                  b = -64'd1;                  chk("s -1*-1");
        a = -64'd1;                  b =  64'd1;                  chk("s -1*1");
        a = -64'd2;                  b =  64'd3;                  chk("s -2*3");
        a =  64'd2;                  b = -64'd3;                  chk("s 2*-3");
        a = 64'h8000000000000000;    b = -64'd1;                  chk("s INT_MIN*-1");
        a = 64'h7FFFFFFFFFFFFFFF;    b = 64'h7FFFFFFFFFFFFFFF;    chk("s INT_MAX^2");
        a = 64'h8000000000000000;    b = 64'h8000000000000000;    chk("s INT_MIN^2");
        a = 64'h7FFFFFFFFFFFFFFF;    b = 64'h8000000000000000;    chk("s MAX*MIN");
        a = 64'hFFFFFFFFFFFFFFFF;    b = 64'hFFFFFFFFFFFFFFFF;    chk("s -1*-1 v2");

        // RANDOM --- both signed and unsigned
        for (i = 0; i < 500; i = i + 1) begin
            a = {$random, $random};
            b = {$random, $random};
            is_signed = 1'b0; chk("rand_u");
            is_signed = 1'b1; chk("rand_s");
        end

        $display("---------------------------------------------------");
        if (errors == 0) $display("PASS: mul64 — %0d test", total);
        else             $display("FAIL: mul64 — %0d / %0d test", errors, total);
        $finish;
    end
endmodule