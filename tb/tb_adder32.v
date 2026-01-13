// tb_adder32.v
// Self-checking testbench for 32-bit structural adder
`timescale 1ns/1ps
module tb_adder32;
  reg  [31:0] a, b;
  reg         cin;
  wire [31:0] sum;
  wire        cout;

  adder32 DUT(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  task vec32(input [31:0] ta, input [31:0] tb, input tcin);
    reg [32:0] exp;
    begin
      a=ta; b=tb; cin=tcin; #50;
      exp = {1'b0,ta} + {1'b0,tb} + tcin;
      $display("%0t a=%h b=%h cin=%b -> sum=%h cout=%b | exp_sum=%h exp_cout=%b",
               $time, a,b,cin,sum,cout,exp[31:0],exp[32]);
      if ({cout,sum} !== exp) begin
        $display("FAIL exp={cout,sum}=%b_%h", exp[32], exp[31:0]);
        $fatal(1);
      end
    end
  endtask

  initial begin
    $display("---- tb_adder32 ----");
    vec32(32'h0000_0000, 32'h0000_0000, 1'b0);
    vec32(32'hFFFF_FFFF, 32'h0000_0001, 1'b0);
    vec32(32'h1234_5678, 32'h1111_1111, 1'b0);
    vec32(32'h8000_0000, 32'h8000_0000, 1'b0);
    vec32(32'hAAAA_AAAA, 32'h5555_5555, 1'b1);
    $display("PASS tb_adder32");
    $finish;
  end
endmodule
