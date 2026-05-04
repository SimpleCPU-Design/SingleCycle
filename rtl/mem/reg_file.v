//|----------------------------------------------------------------------|
//| reg numbers |           purpose              |   protected on call?  |
//|-------------|--------------------------------|-----------------------|
//|X0-X7        | args / result loc              | no                    |
//|X8           | temp result loc                | no                    |
//|X9-X15       | Temporaries                    | no                    |    
//|X16          | Linker scratch register (IP0)  | no                    |                        
//|X17          | Linker scratch register (IP1)  | no                    |
//|X18          | Platform Register              | no                    |
//|X19-X27      | Saved Registers                | yes                   |
//|X28          | Stack Pointer                  | yes                   |
//|X29          | Frame pointer                  | yes                   |
//|X30          | Link register                  | yes                   |
//|XZR          | constant 0                     | -                     |
//|----------------------------------------------------------------------|
module reg_file (
    input [4:0] read_reg1, read_reg2, write_reg,
    input clk, rst, reg_write,
    input [63:0] write_data,
    output [63:0] read_data1, read_data2
);
    wire [31:0] write_decoded, write_enables;
    wire [63:0] x0, x1, x2, x3, x4, x5, x6, x7;
    wire [63:0] x8;
    wire [63:0] x9, x10, x11, x12, x13, x14, x15;
    wire [63:0] x16, x17, x18;
    wire [63:0] x19, x20, x21, x22, x23, x24, x25, x26, x27;
    wire [63:0] x28, x29, x30;
    wire [63:0] xzr;

    
    decoder5_32 decoder(
        .y(write_decoded),
        .in(write_reg)
    );

    and gate_en[31:0](write_enables, write_decoded, reg_write);

    reg64 r0(.q(x0), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[0]));
    reg64 r1(.q(x1), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[1]));
    reg64 r2(.q(x2), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[2]));
    reg64 r3(.q(x3), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[3]));
    reg64 r4(.q(x4), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[4]));
    reg64 r5(.q(x5), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[5]));
    reg64 r6(.q(x6), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[6]));
    reg64 r7(.q(x7), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[7]));
    reg64 r8(.q(x8), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[8]));
    reg64 r9(.q(x9), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[9]));
    reg64 r10(.q(x10), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[10]));
    reg64 r11(.q(x11), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[11]));
    reg64 r12(.q(x12), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[12]));
    reg64 r13(.q(x13), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[13]));
    reg64 r14(.q(x14), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[14]));
    reg64 r15(.q(x15), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[15]));
    reg64 r16(.q(x16), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[16]));
    reg64 r17(.q(x17), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[17]));
    reg64 r18(.q(x18), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[18]));
    reg64 r19(.q(x19), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[19]));
    reg64 r20(.q(x20), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[20]));
    reg64 r21(.q(x21), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[21]));
    reg64 r22(.q(x22), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[22]));
    reg64 r23(.q(x23), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[23]));
    reg64 r24(.q(x24), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[24]));
    reg64 r25(.q(x25), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[25]));
    reg64 r26(.q(x26), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[26]));
    reg64 r27(.q(x27), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[27]));
    reg64 r28(.q(x28), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[28]));
    reg64 r29(.q(x29), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[29]));
    reg64 r30(.q(x30), .d(write_data), .clk(clk), .rst(rst), .en(write_enables[30]));
    assign xzr = 64'b0;

    mux32_1_64 u1(
        .y(read_data1),
        .a0(x0), .a1(x1), .a2(x2), .a3(x3), .a4(x4), .a5(x5), .a6(x6), .a7(x7),
        .a8(x8),
        .a9(x9), .a10(x10), .a11(x11), .a12(x12), .a13(x13), .a14(x14), .a15(x15),
        .a16(x16), .a17(x17), .a18(x18),
        .a19(x19), .a20(x20), .a21(x21), .a22(x22), .a23(x23), .a24(x24), .a25(x25), .a26(x26), .a27(x27),
        .a28(x28), .a29(x29), .a30(x30),
        .a31(xzr), 
        .sel(read_reg1)
    );

    mux32_1_64 u2(
        .y(read_data2),
        .a0(x0), .a1(x1), .a2(x2), .a3(x3), .a4(x4), .a5(x5), .a6(x6), .a7(x7),
        .a8(x8),
        .a9(x9), .a10(x10), .a11(x11), .a12(x12), .a13(x13), .a14(x14), .a15(x15),
        .a16(x16), .a17(x17), .a18(x18),
        .a19(x19), .a20(x20), .a21(x21), .a22(x22), .a23(x23), .a24(x24), .a25(x25), .a26(x26), .a27(x27),
        .a28(x28), .a29(x29), .a30(x30),
        .a31(xzr), 
        .sel(read_reg2)
    );
    
endmodule