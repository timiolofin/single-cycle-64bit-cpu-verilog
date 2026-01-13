// adder32.v
// 32-bit ripple-carry adder built from two adder16 blocks
module adder32(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire        cin,
    output wire [31:0] sum,
    output wire        cout
);
    wire c1;
    adder16 A0(.a(a[15:0]),  .b(b[15:0]),  .cin(cin), .sum(sum[15:0]),  .cout(c1));
    adder16 A1(.a(a[31:16]), .b(b[31:16]), .cin(c1),  .sum(sum[31:16]), .cout(cout));
endmodule