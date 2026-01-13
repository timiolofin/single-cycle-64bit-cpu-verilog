// tb_divider64.v
// Testbench for 64-bit signed divider
// Verifies quotient, remainder, and divide-by-zero flag
`timescale 1ns/1ps
module tb_divider64;
    reg  [63:0] a, b;
    wire [63:0] q, r;
    wire        div_by_zero;

    // Device under test
    divider64 DUT (
        .a          (a),
        .b          (b),
        .q          (q),
        .r          (r),
        .div_by_zero(div_by_zero)
    );

    // Apply one divide case and verify outputs (signed)
    task run_case(input [63:0] a_in, input [63:0] b_in);
        reg signed [63:0] a_s, b_s;
        reg signed [63:0] exp_q_s, exp_r_s;
    begin
        a = a_in;
        b = b_in;
        #5;  // allow propagation

        a_s = a_in;
        b_s = b_in;

        if (b_s == 0) begin
            $display("DIV: a=%0d b=%0d | DIV0 q=%0d r=%0d div_by_zero=%b @ t=%0t",
                     $signed(a_in), $signed(b_in), $signed(q), $signed(r), div_by_zero, $time);

            if (div_by_zero !== 1'b1) $fatal(1);
            if (q !== 64'd0 || r !== 64'd0) $fatal(1);
        end else begin
            exp_q_s = a_s / b_s;
            exp_r_s = a_s % b_s;

            $display("DIV: a=%0d b=%0d | q=%0d (exp=%0d) r=%0d (exp=%0d) div_by_zero=%b @ t=%0t",
                     $signed(a_in), $signed(b_in),
                     $signed(q), exp_q_s, $signed(r), exp_r_s, div_by_zero, $time);

            if (div_by_zero !== 1'b0) $fatal(1);
            if (q !== exp_q_s || r !== exp_r_s) $fatal(1);
        end
    end
    endtask

    initial begin
        $display("==== tb_divider64 start ====");
        a = 0; b = 1; #5;

        run_case(64'd10, 64'd3);
        run_case(64'd100, 64'd10);
        run_case(64'd1,  64'd2);
        run_case(64'hFFFF_FFFF_FFFF_FFFF, 64'd2);         // -1 / 2 = 0, rem = -1 (signed)
        run_case(64'h8000_0000_0000_0000, 64'd2);
        run_case(64'd5,  64'd0);                          // div-by-zero

        $display("PASS tb_divider64");
        $finish;
    end
endmodule
