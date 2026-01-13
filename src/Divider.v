// divider64.v
// 64-bit signed divider generating quotient and remainder with divide-by-zero detection
module divider64(
    input  [63:0] a,
    input  [63:0] b,
    output reg [63:0] q,
    output reg [63:0] r,
    output reg       div_by_zero
);
    wire signed [63:0] a_s = a;
    wire signed [63:0] b_s = b;
    reg  signed [63:0] q_s, r_s;

    always @* begin
        if (b_s == 0) begin
            div_by_zero = 1'b1;
            q_s = 0;
            r_s = 0;
        end else begin
            div_by_zero = 1'b0;
            q_s = a_s / b_s;
            r_s = a_s % b_s;
        end
        q = q_s;
        r = r_s;
    end
endmodule