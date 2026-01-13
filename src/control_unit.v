// control_unit.v
// Single-cycle control unit for a MIPS-like CPU
// Decodes opcode/funct and generates datapath control signals
// Supports: R-type (ADD, SUB, AND, OR, MULT, DIV), LW, SW, BEQ, BNE.
module control_unit(
    input  wire [5:0] opcode,   // instr[31:26]
    input  wire [5:0] funct,    // instr[5:0] (valid for R-type)
    output reg        RegDst,   // 1 -> rd, 0 -> rt
    output reg        ALUSrc,   // 1 -> immediate (I-type), 0 -> register
    output reg        MemToReg, // 1 -> write-back from memory, 0 -> from ALU
    output reg        RegWrite, // enable register write
    output reg        MemRead,  // enable memory read
    output reg        MemWrite, // enable memory write
    output reg        BranchEQ, // BEQ branch enable
    output reg        BranchNE, // BNE branch enable
    output reg [3:0]  ALUCtrl   // ALU operation select
);
    // Opcodes (MIPS-like)
    localparam OP_RTYPE = 6'b000000;
    localparam OP_LW    = 6'b100011; // 0x23
    localparam OP_SW    = 6'b101011; // 0x2B
    localparam OP_BEQ   = 6'b000100; // 0x04
    localparam OP_BNE   = 6'b000101; // 0x05

    // Funct codes (for R-type)
    localparam F_ADD = 6'b100000; // 0x20
    localparam F_SUB = 6'b100010; // 0x22
    localparam F_AND = 6'b100100; // 0x24
    localparam F_OR  = 6'b100101; // 0x25
    localparam F_MULT= 6'b011000; // 0x18
    localparam F_DIV = 6'b011010; // 0x1A

    // ALU control encodings
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_MUL = 4'b0100;
    localparam ALU_DIV = 4'b0101;
    localparam ALU_NOP = 4'b1111;

    always @* begin
        // Defaults
        RegDst   = 1'b0;
        ALUSrc   = 1'b0;
        MemToReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        BranchEQ = 1'b0;
        BranchNE = 1'b0;
        ALUCtrl  = ALU_NOP;

        case (opcode)
            OP_RTYPE: begin
                RegDst   = 1'b1;
                ALUSrc   = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b1;
                case (funct)
                    F_ADD:  ALUCtrl = ALU_ADD;
                    F_SUB:  ALUCtrl = ALU_SUB;
                    F_AND:  ALUCtrl = ALU_AND;
                    F_OR:   ALUCtrl = ALU_OR;
                    F_MULT: ALUCtrl = ALU_MUL;
                    F_DIV:  ALUCtrl = ALU_DIV;
                    default:ALUCtrl = ALU_NOP;
                endcase
            end

            OP_LW: begin
                RegDst   = 1'b0;      // write to rt
                ALUSrc   = 1'b1;      // base + signext(imm)
                MemToReg = 1'b1;      // write-back from memory
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUCtrl  = ALU_ADD;   // address calc
            end

            OP_SW: begin
                ALUSrc   = 1'b1;      // base + signext(imm)
                MemWrite = 1'b1;
                ALUCtrl  = ALU_ADD;   // address calc
            end

            OP_BEQ: begin
                BranchEQ = 1'b1;
                ALUCtrl  = ALU_SUB;   // compare via subtraction
            end

            OP_BNE: begin
                BranchNE = 1'b1;
                ALUCtrl  = ALU_SUB;   // compare via subtraction
            end

            default: begin
                // keep defaults
            end
        endcase
    end
endmodule