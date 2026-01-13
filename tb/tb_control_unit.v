// tb_control_unit.v
// Self-checking testbench for control unit
// Verifies control outputs for R-type, LW, SW, BEQ, and BNE decode
`timescale 1ns/1ps
module tb_control_unit;
    // DUT I/O
    reg  [5:0] opcode, funct;
    wire RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, BranchEQ, BranchNE;
    wire [3:0] ALUCtrl;

    control_unit DUT (
        .opcode(opcode), .funct(funct),
        .RegDst(RegDst), .ALUSrc(ALUSrc), .MemToReg(MemToReg),
        .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite),
        .BranchEQ(BranchEQ), .BranchNE(BranchNE), .ALUCtrl(ALUCtrl)
    );

    // Localparams mirrored from DUT
    localparam OP_RTYPE = 6'b000000;
    localparam OP_LW    = 6'b100011;
    localparam OP_SW    = 6'b101011;
    localparam OP_BEQ   = 6'b000100;
    localparam OP_BNE   = 6'b000101;

    localparam F_ADD = 6'b100000;
    localparam F_SUB = 6'b100010;
    localparam F_AND = 6'b100100;
    localparam F_OR  = 6'b100101;
    localparam F_MULT= 6'b011000;
    localparam F_DIV = 6'b011010;

    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_MUL = 4'b0100;
    localparam ALU_DIV = 4'b0101;

    integer tests, fails;

    task expect;
        input eRegDst, eALUSrc, eMemToReg, eRegWrite, eMemRead, eMemWrite, eBranchEQ, eBranchNE;
        input [3:0] eALUCtrl;
        begin
            tests = tests + 1;
            #1;
            if ({RegDst,ALUSrc,MemToReg,RegWrite,MemRead,MemWrite,BranchEQ,BranchNE,ALUCtrl} !==
                {eRegDst,eALUSrc,eMemToReg,eRegWrite,eMemRead,eMemWrite,eBranchEQ,eBranchNE,eALUCtrl}) begin
                $display("FAIL t=%0t opcode=%b funct=%b -> got Rdst=%b Asrc=%b M2R=%b Rw=%b Mr=%b Mw=%b BEQ=%b BNE=%b ALU=%b",
                    $time, opcode, funct, RegDst,ALUSrc,MemToReg,RegWrite,MemRead,MemWrite,BranchEQ,BranchNE,ALUCtrl);
                fails = fails + 1;
            end
        end
    endtask

    initial begin
        tests=0; fails=0;

        // R-type ADD
        opcode=OP_RTYPE; funct=F_ADD; #1;
        expect(1,0,0,1,0,0,0,0,ALU_ADD);

        // R-type SUB
        opcode=OP_RTYPE; funct=F_SUB; #1;
        expect(1,0,0,1,0,0,0,0,ALU_SUB);

        // R-type AND
        opcode=OP_RTYPE; funct=F_AND; #1;
        expect(1,0,0,1,0,0,0,0,ALU_AND);

        // R-type OR
        opcode=OP_RTYPE; funct=F_OR; #1;
        expect(1,0,0,1,0,0,0,0,ALU_OR);

        // R-type MULT
        opcode=OP_RTYPE; funct=F_MULT; #1;
        expect(1,0,0,1,0,0,0,0,ALU_MUL);

        // R-type DIV
        opcode=OP_RTYPE; funct=F_DIV; #1;
        expect(1,0,0,1,0,0,0,0,ALU_DIV);

        // LW
        opcode=OP_LW; funct=6'bxxxxxx; #1;
        expect(0,1,1,1,1,0,0,0,ALU_ADD);

        // SW
        opcode=OP_SW; funct=6'bxxxxxx; #1;
        expect(0,1,0,0,0,1,0,0,ALU_ADD);

        // BEQ
        opcode=OP_BEQ; funct=6'bxxxxxx; #1;
        expect(0,0,0,0,0,0,1,0,ALU_SUB);

        // BNE
        opcode=OP_BNE; funct=6'bxxxxxx; #1;
        expect(0,0,0,0,0,0,0,1,ALU_SUB);

        $display("Tests=%0d Fails=%0d", tests, fails);
        if (fails==0) $display("PASS");
        else $display("SOME TESTS FAILED");
        $finish;
    end
endmodule
