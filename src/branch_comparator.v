// branch_comparator.v
// Compares two register values for BEQ/BNE branch decisions
module branch_comparator #(
    parameter WIDTH = 64
)(
    input  wire [WIDTH-1:0] rs_val,
    input  wire [WIDTH-1:0] rt_val,
    output wire             equal,
    output wire             not_equal
);
    assign equal     = (rs_val == rt_val);
    assign not_equal = ~equal;
endmodule
