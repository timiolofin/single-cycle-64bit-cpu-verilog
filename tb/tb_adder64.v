// tb_adder64.v
// Self-checking testbench for 64-bit structural ripple-carry adder
`timescale 1ns/1ps
module tb_adder64;
  reg  [63:0] a, b;
  reg         cin;
  wire [63:0] sum;
  wire        cout;

  adder64 DUT(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  task vec64(input [63:0] ta, input [63:0] tb, input tcin);
    reg [64:0] exp;
    begin
      a=ta; b=tb; cin=tcin; #50;                   
      exp = ta + tb + tcin;                         // 65-bit expected
      $display("a=%h b=%h cin=%b -> sum=%h cout=%b | exp_sum=%h exp_cout=%b",
               a,b,cin,sum,cout,exp[63:0],exp[64]);
      if ({cout,sum} !== exp) begin
        $display("FAIL exp={cout,sum}=%b_%h", exp[64], exp[63:0]);
        $fatal(1);
      end
    end
  endtask

  initial begin
    $display("---- tb_adder64 ----");
    vec64(64'h0000_0000_0000_0000, 64'h0000_0000_0000_0000, 1'b0);
    vec64(64'hFFFF_FFFF_FFFF_FFFF, 64'h0000_0000_0000_0001, 1'b0);  
    vec64(64'h0123_4567_89AB_CDEF, 64'h1111_1111_1111_1111, 1'b0);
    vec64(64'h8000_0000_0000_0000, 64'h8000_0000_0000_0000, 1'b0); 
    vec64(64'hAAAA_AAAA_AAAA_AAAA, 64'h5555_5555_5555_5555, 1'b1);
    $display("PASS tb_adder64");
    $finish;
  end
endmodule
