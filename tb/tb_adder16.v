// tb_adder16.v
// Self-checking testbench for 16-bit structural adder
`timescale 1ns/1ps
module tb_adder16;
  reg  [15:0] a, b;
  reg         cin;
  wire [15:0] sum;
  wire        cout;

  adder16 DUT(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  task vec16(input [15:0] ta, input [15:0] tb, input tcin);
    reg [16:0] exp;
    begin
      a=ta; b=tb; cin=tcin; #50;
      exp = {1'b0,ta} + {1'b0,tb} + tcin;
      $display("%0t a=%h b=%h cin=%b -> sum=%h cout=%b | exp=%h %b",
               $time, a,b,cin,sum,cout,exp[15:0],exp[16]);
      if ({cout,sum} !== exp) begin
        $display("FAIL exp={cout,sum}=%b_%h", exp[16], exp[15:0]);
        $fatal(1);
      end
    end
  endtask

  initial begin
    $display("---- tb_adder16 ----");
    vec16(16'hFFFF, 16'h0001, 1'b0);
    vec16(16'h1234, 16'h4321, 1'b0);
    vec16(16'hAAAA, 16'h5555, 1'b1);
    $display("PASS tb_adder16");
    $finish;
  end
endmodule
