// tb_adder4.v
// Testbench for 4-bit ripple-carry adder
`timescale 1ns/1ps
module tb_adder4;
  reg  [3:0] a, b;
  reg        cin;
  wire [3:0] sum;
  wire       cout;

  adder4 DUT(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  initial begin
    $display("a b cin | sum cout");

    a=4'hA; b=4'h5; cin=0; #50;
    a=4'hF; b=4'h1; cin=0; #50;
    a=4'hF; b=4'hF; cin=1; #50;
    a=4'h7; b=4'h8; cin=1; #50;

    $display("done");
    $finish;
  end
endmodule
