// tb_multiplier64.v
// Testbench for 64-bit signed multiplier (128-bit product)
// Uses signed math for expected value and self-checks DUT output
`timescale 1ns/1ps
module tb_multiplier64;
    reg  [63:0]  a, b;
    wire [127:0] prod;

    // Device under test
    multiplier64 DUT (
        .a   (a),
        .b   (b),
        .prod(prod)
    );

    // Apply one multiply case and verify output (signed)
    task run_case(input [63:0] a_in, input [63:0] b_in);
        reg signed [63:0]  a_s, b_s;
        reg signed [127:0] expected_s;
    begin
        a = a_in;
        b = b_in;
        #5;  // allow propagation

        a_s = a_in;
        b_s = b_in;
        expected_s = a_s * b_s;

        $display("MUL: a=%0d b=%0d | prod=0x%032h (exp=0x%032h) @ t=%0t",
                 $signed(a_in), $signed(b_in), prod, expected_s, $time);

        if (prod !== expected_s) begin
            $display("FAIL exp=0x%032h got=0x%032h", expected_s, prod);
            $fatal(1);
        end
    end
    endtask

    initial begin
        $display("==== tb_multiplier64 start ====");
        a = 0; b = 0; #5;

        run_case(64'd0,  64'd0);
        run_case(64'd2,  64'd3);
        run_case(64'd15, 64'd15);
        run_case(64'hFFFF_FFFF_FFFF_FFFF, 64'd2);          // -1 * 2 = -2
        run_case(64'h8000_0000_0000_0000, 64'd2);          // minneg * 2 (wrap in 128b)

        $display("PASS tb_multiplier64");
        $finish;
    end
endmodule
