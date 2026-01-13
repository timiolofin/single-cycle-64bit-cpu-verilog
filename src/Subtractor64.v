// subtractor64.v
// 64-bit subtractor implemented using two’s complement (A + (~B + 1)) via the 64-bit adder
module subtractor64(
    input  [63:0] a,
    input  [63:0] b,
    output [63:0] diff,
    output        cout,
    output        overflow
);
    wire [63:0] b_neg = ~b;
    adder64 u_adder64 (
        .a   (a), .b   (b_neg), .cin (1'b1), .sum (diff), .cout(cout)
    );
    assign overflow = (a[63] ^ b[63]) & (a[63] ^ diff[63]);
endmodule