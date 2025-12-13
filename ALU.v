// alu.v
// 64-bit ALU supporting add, sub, logic ops, multiply, and divide
// Outputs low/high product, remainder, zero flag, and divide-by-zero flag
module ALU(
    input  [63:0] A,
    input  [63:0] B,
    input  [2:0]  ALUop,
    output reg [63:0] Y,
    output reg [63:0] Y_hi,
    output reg [63:0] REM,
    output        ZERO,
    output reg    COUT,
    output reg    OVF,
    output        DIV0
);
    wire [63:0] add_sum;
    wire add_cout;
    adder64 u_add(.a(A), .b(B), .cin(1'b0), .sum(add_sum), .cout(add_cout));

    wire [63:0] sub_diff;
    wire sub_cout, sub_ovf;
    subtractor64 u_sub(.a(A), .b(B), .diff(sub_diff), .cout(sub_cout), .overflow(sub_ovf));

    wire [63:0] and_y, or_y, xor_y, nor_y;
    logicunit u_and(.a(A), .b(B), .op(2'b00), .y(and_y));
    logicunit u_or (.a(A), .b(B), .op(2'b01), .y(or_y));
    logicunit u_xor(.a(A), .b(B), .op(2'b10), .y(xor_y));
    logicunit u_nor(.a(A), .b(B), .op(2'b11), .y(nor_y));

    wire [127:0] prod;
    multiplier64 u_mul(.a(A), .b(B), .prod(prod));

    wire [63:0] q, r;
    wire div0;
    divider64 u_div(.a(A), .b(B), .q(q), .r(r), .div_by_zero(div0));

    assign ZERO = (Y == 64'd0);
    assign DIV0 = div0;

    always @* begin
        Y    = 64'd0;
        Y_hi = 64'd0;
        REM  = 64'd0;
        COUT = 1'b0;
        OVF  = 1'b0;

        case (ALUop)
            3'b000: begin
                Y    = add_sum;
                COUT = add_cout;
                OVF  = (A[63] == B[63]) && (Y[63] != A[63]);
            end
            3'b001: begin
                Y    = sub_diff;
                COUT = sub_cout;
                OVF  = sub_ovf;
            end
            3'b010: Y = and_y;
            3'b011: Y = or_y;
            3'b100: Y = xor_y;
            3'b101: begin
                Y    = prod[63:0];
                Y_hi = prod[127:64];
            end
            3'b110: begin
                Y    = q;
                REM  = r;
            end
            default: Y = 64'd0;
        endcase
    end
endmodule
