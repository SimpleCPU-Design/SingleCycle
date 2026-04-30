`timescale 1ns/1ps

module tb_primitives;

    integer errors = 0;

    task check;
        input [63:0] got;
        input [63:0] exp;
        input [127:0] tag;
        begin
            if(got !== exp) begin
                $display("FAIL [%0s]: got=%0h exp=%0h", tag, got, exp);
                errors = errors + 1;
            end
        end
    endtask

    // half adder
    reg ha_a, ha_b;
    wire ha_sum, ha_cout;
    half_adder u_ha(
        .sum(ha_sum),
        .cout(ha_cout),
        .a(ha_a),
        .b(ha_b)
    );

    // full adder
    reg fa_a, fa_b, fa_cin;
    wire fa_sum, fa_cout;
    full_adder u_fa(
        .sum(fa_sum), 
        .cout(fa_cout), 
        .a(fa_a), 
        .b(fa_b), 
        .cin(fa_cin)
    );

    // mux2_1
    reg mx_a, mx_b, mx_sel;
    wire mx_y;
    mux2_1 u_mx(
        .y(mx_y),
        .a(mx_a),
        .b(mx_b),
        .sel(mx_sel)
    );

    // mux2_1_64
    reg [63:0] mx64_a, mx64_b;
    reg mx64_sel;
    wire [63:0] mx64_y;
    mux2_1_64 u_mx64(
        .y(mx64_y),
        .a(mx64_a),
        .b(mx64_b),
        .sel(mx64_sel)
    );

    // decoder5_32
    reg [4:0] dec_in;
    wire [31:0] dec_y;
    decoder5_32 u_dec(
        .y(dec_y),
        .in(dec_in)
    );

    // dff 1-bit
    reg clk = 0, rst, dff_d;
    wire dff_q;
    dff u_dff(
        .q(dff_q),
        .d(dff_d),
        .clk(clk),
        .rst(rst)
    );
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_primitives);

        // half adder truth table
        {ha_a, ha_b} = 2'b00; #1;
        check(ha_sum, 0, "ha 00 sum"); check(ha_cout, 0, "ha 00 cout");
        {ha_a, ha_b} = 2'b01; #1;
        check(ha_sum, 1, "ha 01 sum"); check(ha_cout, 0, "ha 01 cout");
        {ha_a, ha_b} = 2'b10; #1;
        check(ha_sum, 1, "ha 10 sum"); check(ha_cout, 0, "ha 10 cout");
        {ha_a, ha_b} = 2'b11; #1;
        check(ha_sum, 0, "ha 11 sum"); check(ha_cout, 1, "ha 11 cout");

        // full adder truth table
        {fa_a, fa_b, fa_cin} = 3'b000; #1; check(fa_sum, 0, "fa 000"); check(fa_cout, 0, "fa_c 000");
        {fa_a, fa_b, fa_cin} = 3'b011; #1; check(fa_sum, 0, "fa 011"); check(fa_cout, 1, "fa_c 011");
        {fa_a, fa_b, fa_cin} = 3'b111; #1; check(fa_sum, 1, "fa 111"); check(fa_cout, 1, "fa_c 111");
        {fa_a, fa_b, fa_cin} = 3'b101; #1; check(fa_sum, 0, "fa 101"); check(fa_cout, 1, "fa_c 101");

        // mux 2-1
        mx_a = 0; mx_b = 1; mx_sel = 0; #1; check(mx_y, 0, "mux sel=0");
        mx_a = 0; mx_b = 1; mx_sel = 1; #1; check(mx_y, 1, "mux sel=1");
        mx_a = 1; mx_b = 0; mx_sel = 0; #1; check(mx_y, 1, "mux a=1 sel=0");

        // mux 2-1 64-bit
        mx64_a = 64'hAAAA_BBBB_CCCC_DDDD;
        mx64_b = 64'h1111_2222_3333_4444;
        mx64_sel = 0; #1; check(mx64_y, mx64_a, "mx64 sel=0");
        mx64_sel = 1; #1; check(mx64_y, mx64_b, "mx64 sel=1");

        // decoder 5-32
        dec_in = 5'd0; #1; check(dec_y, 32'h00000001, "dec 0");
        dec_in = 5'd1; #1; check(dec_y, 32'h00000002, "dec 1");
        dec_in = 5'd31; #1; check(dec_y, 32'h80000000, "dec 31");
        dec_in = 5'd5; #1; check(dec_y, 32'h00000020, "dec 5");

        // dff
        rst = 1; dff_d = 1; @(posedge clk); #1;
        check(dff_q, 0, "dff rst");
        rst = 0; dff_d = 1; @(posedge clk); #1;
        check(dff_q, 1, "dff d=1");
        dff_d=0; @(posedge clk); #1;
        check(dff_q, 0, "dff d=0");

        if (errors == 0)
            $display("PASS: primitives - all checks OK");
        else
            $display("FAIL: primitives - %0d errors", errors);

        $finish;
    end
endmodule