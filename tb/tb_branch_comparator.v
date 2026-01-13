// tb_branch_comparator.v
// Testbench for branch comparator (equal / not_equal)
// Applies directed cases and self-checks outputs
`timescale 1ns/1ps
module tb_branch_comparator;
    localparam WIDTH = 64;

    reg  [WIDTH-1:0] rs_val;
    reg  [WIDTH-1:0] rt_val;
    wire             equal;
    wire             not_equal;

    // Device under test
    branch_comparator #(.WIDTH(WIDTH)) DUT (
        .rs_val   (rs_val),
        .rt_val   (rt_val),
        .equal    (equal),
        .not_equal(not_equal)
    );

    integer fails;

    // Apply one compare case and verify flags
    task check(input [WIDTH-1:0] a, input [WIDTH-1:0] b);
        reg exp_eq, exp_neq;
    begin
        rs_val = a; rt_val = b; #1;               // combinational settle
        exp_eq  = (a == b);
        exp_neq = ~exp_eq;

        $display("CMP: a=%0d b=%0d | eq=%b neq=%b @ t=%0t", a, b, equal, not_equal, $time);

        if (equal !== exp_eq || not_equal !== exp_neq) begin
            $display("FAIL exp_eq=%b exp_neq=%b got_eq=%b got_neq=%b", exp_eq, exp_neq, equal, not_equal);
            fails = fails + 1;
        end
    end
    endtask

    initial begin
        fails = 0;
        check(64'd10,  64'd10);
        check(64'd5,   64'd20);
        check(64'd100, 64'd7);
        check(64'd0,   64'd0);

        if (fails==0) $display("PASS tb_branch_comparator");
        else begin
            $display("FAIL tb_branch_comparator (%0d fails)", fails);
            $fatal(1);
        end
        $finish;
    end
endmodule
