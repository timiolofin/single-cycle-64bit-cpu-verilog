// half_adder.v
// Combinational half adder: sum = a ^ b; carry = a & b
module half_adder(
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule
