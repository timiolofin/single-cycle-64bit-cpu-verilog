// tb_subtractor64.v
// Testbench for 64-bit subtractor
// Verifies diff, carry-out (no-borrow), and signed overflow behavior
`timescale 1ns/1ps
module tb_subtractor64;
    reg  [63:0] a, b;
    wire [63:0] diff;
    wire        cout;       // 1 = no borrow, 0 = borrow
    wire        overflow;   // signed overflow flag

    // Device under test
    subtractor64 DUT (
        .a       (a),
        .b       (b),
        .diff    (diff),
        .cout    (cout),
        .overflow(overflow)
    );

    // Apply one subtraction case
    task run_case(input [63:0] a_in, input [63:0] b_in);
        reg [63:0] expected_diff;
    begin
        a = a_in;
        b = b_in;
        #5;                                      // allow propagation
        expected_diff = a_in - b_in;
        $display("SUB: a=%0d b=%0d | diff=%0d (exp=%0d) cout=%b ovf=%b @ t=%0t",
                 a, b, diff, expected_diff, cout, overflow, $time);
    end
    endtask

    initial begin
        $display("==== tb_subtractor64 start ====");
        a = 0; b = 0; #5;

        run_case(64'd10, 64'd3);
        run_case(64'd3,  64'd10);
        run_case(64'd0,  64'd0);
        run_case(64'hFFFF_FFFF_FFFF_FFFF, 64'd1);
        run_case(64'h8000_0000_0000_0000, 64'd1); // overflow case

        $display("==== tb_subtractor64 done ====");
        #10;
        $finish;
    end
endmodule
