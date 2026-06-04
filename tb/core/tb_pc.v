`timescale 1ns/1ps

// ================================================================================
//  tb_pc -- self-checking testbench for the Program Counter.
//
//  Reference model (exp_pc) mirrors the DUT contract:
//    posedge clk:
//        rst        -> exp_pc = 0                     (synchronous reset)
//        pc_write=0 -> exp_pc unchanged               (stall / hold)
//        pc_write=1 -> exp_pc = branch_taken ? branch_target : exp_pc + 4
//    combinational (any time):
//        pc_plus4   == pc + 4   (ALWAYS, even on a taken branch)
//
//  Coverage: reset-to-0, sequential +4, stall, stall-ignores-branch,
//  branch to low/high targets, mid-stream reset, and a randomized stress loop.
// ================================================================================

module tb_pc;
    reg         clk, rst, pc_write, branch_taken;
    reg  [63:0] branch_target;
    wire [63:0] pc, pc_plus4;

    pc dut(
        .pc           (pc),
        .pc_plus4     (pc_plus4),
        .clk          (clk),
        .rst          (rst),
        .pc_write     (pc_write),
        .branch_taken (branch_taken),
        .branch_target(branch_target)
    );

    reg [63:0] exp_pc;     // reference model of the registered PC
    integer    errors  = 0;
    integer    n_tests = 0;

    // --- Clock: 10ns period ---
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // --- Combinational + registered checks ---
    task check;
        input [8*40-1:0] tag;
        begin
            n_tests = n_tests + 1;
            if (pc !== exp_pc) begin
                $display("FAIL [%0s]: pc got=%h exp=%h", tag, pc, exp_pc);
                errors = errors + 1;
            end
            // pc_plus4 must always track pc+4 (64-bit wrap matches adder64)
            if (pc_plus4 !== (pc + 64'd4)) begin
                $display("FAIL [%0s]: pc_plus4 got=%h exp=%h (pc=%h)",
                         tag, pc_plus4, pc + 64'd4, pc);
                errors = errors + 1;
            end
        end
    endtask

    // --- Advance one clock with given inputs, update reference, check ---
    //   Drive inputs immediately (just after the previous negedge) so they are
    //   stable across the upcoming posedge that latches them, then sample at the
    //   following negedge -- far from any clock edge.  This avoids the
    //   posedge+#1 sampling race that Icarus and Verilator schedule differently.
    task step;
        input            twrite, tbtaken;
        input [63:0]     ttarget;
        input [8*40-1:0] tag;
        begin
            pc_write      = twrite;
            branch_taken  = tbtaken;
            branch_target = ttarget;
            if (twrite) begin
                if (tbtaken) exp_pc = ttarget;
                else         exp_pc = exp_pc + 64'd4;
            end
            @(negedge clk);     // posedge in between latched the inputs; pc stable
            check(tag);
        end
    endtask

    // --- Synchronous reset pulse ---
    task do_reset;
        input [8*40-1:0] tag;
        begin
            rst           = 1'b1;   // latched at the upcoming posedge -> pc = 0
            pc_write      = 1'b1;   // rst must dominate regardless
            branch_taken  = 1'b0;
            branch_target = 64'h0;
            exp_pc        = 64'h0;
            @(negedge clk);         // pc now reset; deassert before next cycle
            rst = 1'b0;
            check(tag);
        end
    endtask

    integer i;
    reg [63:0] rtarget;
    reg        rwrite, rtaken;

    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_pc);

        rst = 1'b1; pc_write = 1'b1; branch_taken = 1'b0; branch_target = 64'h0;

        // --- 1: reset forces pc = 0
        do_reset("reset->0");

        // --- 2: sequential +4
        step(1'b1, 1'b0, 64'h0, "seq+4 #1");   // 0x04
        step(1'b1, 1'b0, 64'h0, "seq+4 #2");   // 0x08
        step(1'b1, 1'b0, 64'h0, "seq+4 #3");   // 0x0c

        // --- 3: stall holds pc, even with a branch request pending
        step(1'b0, 1'b0, 64'h0,    "stall hold");
        step(1'b0, 1'b1, 64'h1000, "stall ignores branch");
        step(1'b1, 1'b0, 64'h0,    "resume +4");  // 0x10

        // --- 4: taken branch (low target) + fall-through
        step(1'b1, 1'b1, 64'h0000_0000_0000_2000, "branch->2000");
        step(1'b1, 1'b0, 64'h0,                    "after branch +4"); // 0x2004

        // --- 5: taken branch (high target) -- exercises full 64-bit path
        step(1'b1, 1'b1, 64'hDEAD_BEEF_0000_0000, "branch->high");
        step(1'b1, 1'b0, 64'h0,                    "high +4");

        // --- 6: pc_plus4 wrap at the top of the address space
        step(1'b1, 1'b1, 64'hFFFF_FFFF_FFFF_FFFC, "branch->-4");
        step(1'b1, 1'b0, 64'h0,                    "wrap to 0"); // -> 0

        // --- 7: reset mid-stream
        do_reset("reset mid->0");
        step(1'b1, 1'b0, 64'h0, "post-reset +4");

        // --- 8: randomized stress (mix of write/stall/branch)
        for (i = 0; i < 2000; i = i + 1) begin
            rtarget = {$random, $random};
            rwrite  = $random;
            rtaken  = $random;
            step(rwrite, rtaken, rtarget, "rand");
        end

        // --- Summary
        if (errors == 0) $display("PASS: pc (%0d cases)", n_tests);
        else             $display("FAIL: pc - %0d / %0d errors", errors, n_tests);
        $finish;
    end

endmodule
