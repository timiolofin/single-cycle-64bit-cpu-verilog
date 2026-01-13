// adder64.v
// 64-bit ripple-carry adder built from two adder32 blocks
module adder64(
    input  wire [63:0] a,
    input  wire [63:0] b,
    input  wire        cin,
    output wire [63:0] sum,
    output wire        cout
);
    wire c1;
    adder32 A0(.a(a[31:0]),  .b(b[31:0]),  .cin(cin), .sum(sum[31:0]),  .cout(c1));
    adder32 A1(.a(a[63:32]), .b(b[63:32]), .cin(c1),  .sum(sum[63:32]), .cout(cout));
endmodule