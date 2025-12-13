// full_adder_1bit.v
// Structural full adder using two half adders and an OR gate
module full_adder_1bit(
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    wire s1, c1, c2;
    half_adder HA0(.a(a), .b(b), .sum(s1), .carry(c1));
    half_adder HA1(.a(s1), .b(cin), .sum(sum), .carry(c2));
    assign cout = c1 | c2;
endmodule