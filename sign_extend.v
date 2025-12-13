// sign_extend.v
// Sign-extends a 16-bit immediate to 64 bits (two’s complement)
module sign_extend(
    input  wire [15:0] imm16,
    output wire [63:0] imm64
);
    assign imm64 = {{48{imm16[15]}}, imm16};
endmodule