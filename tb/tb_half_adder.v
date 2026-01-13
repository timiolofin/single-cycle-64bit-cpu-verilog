// tb_half_adder.v
// Testbench for 1-bit half adder
`timescale 1ns/1ps
module tb_half_adder;
    reg  a, b;
    wire sum, carry;

    half_adder DUT (.a(a), .b(b), .sum(sum), .carry(carry));

    initial begin
        $display("t a b | sum carry");
        a=0; b=0; #1 $display("%0t %b %b |  %b    %b", $time, a, b, sum, carry);
        a=0; b=1; #1 $display("%0t %b %b |  %b    %b", $time, a, b, sum, carry);
        a=1; b=0; #1 $display("%0t %b %b |  %b    %b", $time, a, b, sum, carry);
        a=1; b=1; #1 $display("%0t %b %b |  %b    %b", $time, a, b, sum, carry);
        $finish;
    end
endmodule
