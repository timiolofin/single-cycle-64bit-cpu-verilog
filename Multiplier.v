// multiplier64.v
// 64-bit signed multiplier producing a 128-bit product (behavioral)
module multiplier64(
    input  [63:0] a,
    input  [63:0] b,
    output [127:0] prod
);
    wire signed [63:0]  a_s = a;
    wire signed [63:0]  b_s = b;
    wire signed [127:0] p_s = a_s * b_s;

    assign prod = p_s;
endmodule