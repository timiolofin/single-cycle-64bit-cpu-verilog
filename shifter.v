// shifter.v
// 64-bit shifter: logical left, logical right, arithmetic right
module shifter(
    input  wire [63:0] din,
    input  wire [5:0]  shamt,  // 0..63
    input  wire [1:0]  mode,   // 00=SLL, 01=SRL, 10=SRA
    output reg  [63:0] dout
);
    always @* begin
        case (mode)
            2'b00: dout = din << shamt;                // SLL (logical Left)
            2'b01: dout = din >> shamt;                // SRL (logical Right)
            2'b10: dout = $signed(din) >>> shamt;      // SRA (arithmetic)
            default: dout = din;
        endcase
    end
endmodule