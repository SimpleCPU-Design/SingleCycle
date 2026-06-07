`timescale 1ns/1ps

// ================================================================================
//  instruction_mem -- read-only instruction memory (asynchronous ROM).
//
//  Holds the program as 32-bit words, initialised from a $readmemh hex file
//  (produced by the Rust assembler).  The PC is a byte address; instructions are
//  word-aligned, so the word index is addr[ A+1 : 2 ] (drop the low two byte
//  bits -- a bit-select, not a shift).  Read is combinational (no clock): the
//  instruction at the current PC is available in the same cycle.
//
//  Ports
//    addr[63:0]   byte address (the PC)
//    instr[31:0]  the 32-bit instruction word at that address
//
//  Parameters
//    DEPTH_LOG2   log2 of the word count (default 10 -> 1024 words = 4 KiB ROM)
//    INIT_FILE    $readmemh source (default mem/prog.hex)
// ================================================================================

module instruction_mem #(
    parameter DEPTH_LOG2 = 10,
    parameter INIT_FILE  = "mem/prog.hex"
)(
    output [31:0] instr,
    input  [63:0] addr
);
    localparam DEPTH = (1 << DEPTH_LOG2);

    reg [31:0] mem [0:DEPTH-1];

    initial begin
        $readmemh(INIT_FILE, mem);
    end

    // word index = addr / 4 = addr[DEPTH_LOG2+1 : 2]  (bit-select, no shift op)
    wire [DEPTH_LOG2-1:0] windex;
    assign windex = addr[DEPTH_LOG2+1:2];

    assign instr = mem[windex];
endmodule
