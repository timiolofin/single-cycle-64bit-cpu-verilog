// CPU.v
// Top-level 64-bit single-cycle CPU
// Datapath: pc, instr_mem, control_unit, regfile, sign_extend,
//           ALU, data_mem, branch_comparator, mux, shifter.
module CPU(
    input  wire clk,
    input  wire reset
);
    //========================
    // Program Counter
    //========================
    wire [63:0] pc_curr;
    wire [63:0] pc_next;
    wire [63:0] pc_plus4;
    wire [63:0] pc_branch;

    pc #(.WIDTH(64)) u_pc (
        .clk   (clk),
        .reset (reset),
        .pc_in (pc_next),
        .pc_out(pc_curr)
    );

    assign pc_plus4 = pc_curr + 64'd4;

    //========================
    // Instruction Memory
    //========================
    wire [31:0] instr;

    instr_mem #(
        .ADDR_WIDTH(12),
        .DATA_WIDTH(32),
        .INIT_HEX("")   // program file name
    ) u_imem (
        .addr (pc_curr[11:0]),     // byte address, lower 12 bits
        .instr(instr)
    );

    // Decode fields (MIPS-like)
    wire [5:0] opcode = instr[31:26];
    wire [4:0] rs     = instr[25:21];
    wire [4:0] rt     = instr[20:16];
    wire [4:0] rd     = instr[15:11];
    wire [15:0] imm16 = instr[15:0];
    wire [5:0] funct  = instr[5:0];

    //========================
    // Control Unit
    //========================
    wire RegDst;
    wire ALUSrc;
    wire MemToReg;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire BranchEQ;
    wire BranchNE;
    wire [3:0] ALUCtrl;

    control_unit u_ctrl (
        .opcode  (opcode),
        .funct   (funct),
        .RegDst  (RegDst),
        .ALUSrc  (ALUSrc),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite),
        .MemRead (MemRead),
        .MemWrite(MemWrite),
        .BranchEQ(BranchEQ),
        .BranchNE(BranchNE),
        .ALUCtrl (ALUCtrl)
    );

    //========================
    // Register File
    //========================
    wire [63:0] rd1;
    wire [63:0] rd2;
    wire [4:0]  write_addr;
    wire [63:0] write_data;

    regfile u_regfile (
        .clk (clk),
        .rst (reset),
        .we  (RegWrite),
        .ra1 (rs),
        .ra2 (rt),
        .wa  (write_addr),
        .wd  (write_data),
        .rd1 (rd1),
        .rd2 (rd2)
    );

    // RegDst mux: choose rd (R-type) or rt (I-type) as write address
    mux #(.WIDTH(5)) u_regdst_mux (
        .a   (rt),
        .b   (rd),
        .sel (RegDst),
        .y   (write_addr)
    );

    //========================
    // Immediate + branch offset
    //========================
    wire [63:0] imm64;
    sign_extend u_signext (
        .imm16(imm16),
        .imm64(imm64)
    );

    // Branch offset = imm64 << 2 using shifter (mode 00 = SLL)
    wire [63:0] imm_shift2;
    shifter u_shifter (
        .din  (imm64),
        .shamt(6'd2),
        .mode (2'b00),   // logical left shift
        .dout (imm_shift2)
    );

    assign pc_branch = pc_plus4 + imm_shift2;

    //========================
    // ALU and branch comparator
    //========================
    // Map 4-bit ALUCtrl to 3-bit ALUop used by ALU.v
    reg [2:0] alu_op;
    always @* begin
        case (ALUCtrl)
            4'b0000: alu_op = 3'b000; // ADD
            4'b0001: alu_op = 3'b001; // SUB
            4'b0010: alu_op = 3'b010; // AND
            4'b0011: alu_op = 3'b011; // OR
            4'b0100: alu_op = 3'b101; // MULT
            4'b0101: alu_op = 3'b110; // DIV
            default: alu_op = 3'b000;
        endcase
    end

    // ALU second operand mux: register vs immediate
    wire [63:0] alu_in2;
    mux #(.WIDTH(64)) u_alusrc_mux (
        .a   (rd2),
        .b   (imm64),
        .sel (ALUSrc),
        .y   (alu_in2)
    );

    wire [63:0] alu_y;
    wire [63:0] alu_y_hi;
    wire [63:0] alu_rem;
    wire        alu_zero;
    wire        alu_div0;
    wire        alu_cout;
    wire        alu_ovf;

    ALU u_alu (
        .A    (rd1),
        .B    (alu_in2),
        .ALUop(alu_op),
        .Y    (alu_y),
        .Y_hi (alu_y_hi),
        .REM  (alu_rem),
        .ZERO (alu_zero),
        .COUT (alu_cout),
        .OVF  (alu_ovf),
        .DIV0 (alu_div0)
    );

    // Branch comparator
    wire equal;
    wire not_equal;
    branch_comparator #(.WIDTH(64)) u_bcmp (
        .rs_val   (rd1),
        .rt_val   (rd2),
        .equal    (equal),
        .not_equal(not_equal)
    );

    wire branch_taken = (BranchEQ & equal) | (BranchNE & not_equal);

    //========================
    // Data memory
    //========================
    wire [63:0] dmem_rdata;

    data_mem #(
        .ADDR_WIDTH(12),
        .DATA_WIDTH(64),
        .INIT_HEX("")
    ) u_dmem (
        .clk  (clk),
        .we   (MemWrite),
        .addr (alu_y[11:0]),   // byte address, lower 12 bits
        .wdata(rd2),
        .rdata(dmem_rdata)
    );

    //========================
    // Write-back mux (ALU vs MEM)
    //========================
    mux #(.WIDTH(64)) u_memtoreg_mux (
        .a   (alu_y),
        .b   (dmem_rdata),
        .sel (MemToReg),
        .y   (write_data)
    );

    //========================
    // Next PC mux
    //========================
    mux #(.WIDTH(64)) u_pc_mux (
        .a   (pc_plus4),
        .b   (pc_branch),
        .sel (branch_taken),
        .y   (pc_next)
    );

endmodule
