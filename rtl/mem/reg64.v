module reg64 (
    output [63:0] q, // qurrent
    input  [63:0] d, // data
    input en, clk, rst // write enable, clock, reset
);
    wire [63:0] mux_out;

    mux2_1_64 state_mux(
        .y(mux_out),
        .a(q),
        .b(d),
        .sel(en)
    );
    dff64 storage(
        .q(q),
        .d(mux_out),
        .clk(clk),
        .rst(rst)
    );
endmodule