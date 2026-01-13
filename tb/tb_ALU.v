// tb_ALU.v
// Self-checking testbench for 64-bit ALU (ADD, SUB, AND, OR, XOR, MUL, DIV)
// Verifies primary outputs (Y, Y_hi, REM) and flags (ZERO, COUT, OVF, DIV0)
`timescale 1ns/1ps
module tb_ALU;
  reg  [63:0] A, B;
  reg  [2:0]  ALUop;
  wire [63:0] Y, Y_hi, REM;
  wire        ZERO, COUT, OVF, DIV0;

  // Device under test
  ALU DUT(
    .A(A), .B(B), .ALUop(ALUop),
    .Y(Y), .Y_hi(Y_hi), .REM(REM),
    .ZERO(ZERO), .COUT(COUT), .OVF(OVF), .DIV0(DIV0)
  );

  // Check one ALU operation against expected values
  task vecALU(
    input [2:0] op,
    input [63:0] a_in,
    input [63:0] b_in,
    input [255:0] op_name
  );
    reg [63:0] expY, expYhi, expREM;
    reg        expCOUT, expOVF, expDIV0, expZERO;
    reg [64:0] addexp;
    reg signed [63:0]  a_s, b_s;
    reg signed [127:0] mulexp_s;
    reg signed [63:0]  qexp_s, rexp_s;
  begin
    // drive inputs
    ALUop = op; A = a_in; B = b_in; #50;

    // defaults
    expY    = 64'd0;
    expYhi  = 64'd0;
    expREM  = 64'd0;
    expCOUT = 1'b0;
    expOVF  = 1'b0;
    expDIV0 = 1'b0;

    // expected results
    case (op)
      3'b000: begin // ADD
        addexp  = {1'b0,a_in} + {1'b0,b_in} + 1'b0;
        expY    = addexp[63:0];
        expCOUT = addexp[64];
        expOVF  = (a_in[63] == b_in[63]) && (expY[63] != a_in[63]);
      end
      3'b001: begin // SUB
        expY    = a_in - b_in;
        expCOUT = (a_in >= b_in);                        
        expOVF  = (a_in[63] ^ b_in[63]) & (a_in[63] ^ expY[63]);
      end
      3'b010: expY = a_in & b_in;                         // AND
      3'b011: expY = a_in | b_in;                         // OR
      3'b100: expY = a_in ^ b_in;                         // XOR
      3'b101: begin // MUL (signed)
        a_s = a_in; b_s = b_in;
        mulexp_s = a_s * b_s;
        expY   = mulexp_s[63:0];
        expYhi = mulexp_s[127:64];
      end
      3'b110: begin // DIV (signed)
        a_s = a_in; b_s = b_in;
        if (b_s == 0) begin
          expDIV0 = 1'b1;
          expY    = 64'd0;
          expREM  = 64'd0;
        end else begin
          qexp_s  = a_s / b_s;
          rexp_s  = a_s % b_s;
          expY    = qexp_s;
          expREM  = rexp_s;
        end
      end
      default: begin end
    endcase

    expZERO = (expY == 64'd0);

    // print
    $display("%s: A=%h B=%h -> Y=%h Y_hi=%h REM=%h | COUT=%b OVF=%b ZERO=%b DIV0=%b",
             op_name, A, B, Y, Y_hi, REM, COUT, OVF, ZERO, DIV0);

    // self-check
    if (Y    !== expY)    $fatal(1);
    if (Y_hi !== expYhi)  $fatal(1);
    if (REM  !== expREM)  $fatal(1);
    if (COUT !== expCOUT) $fatal(1);
    if (OVF  !== expOVF)  $fatal(1);
    if (DIV0 !== expDIV0) $fatal(1);
    if (ZERO !== expZERO) $fatal(1);
  end
  endtask

  initial begin
    $display("---- tb_ALU ----");
    vecALU(3'b000, 64'hAAAA_AAAA_AAAA_AAAA, 64'h5555_5555_5555_5555, "ADD");
    vecALU(3'b000, 64'hFFFF_FFFF_FFFF_FFFF, 64'h1,                   "ADD");
    vecALU(3'b001, 64'hAAAA_AAAA_AAAA_AAAA, 64'h5555_5555_5555_5555, "SUB");
    vecALU(3'b001, 64'h1,                   64'h2,                   "SUB");
    vecALU(3'b010, 64'hF0F0_F0F0_F0F0_F0F0, 64'h0F0F_0F0F_0F0F_0F0F, "AND");
    vecALU(3'b011, 64'h0123_4567_89AB_CDEF, 64'h1111_1111_1111_1111, "OR");
    vecALU(3'b100, 64'hF0F0_F0F0_F0F0_F0F0, 64'h0FF0_0FF0_0FF0_0FF0, "XOR");
    vecALU(3'b101, 64'd20000,               64'd20000,               "MUL");
    vecALU(3'b110, 64'd20,                  64'd6,                   "DIV");
    vecALU(3'b110, 64'd1234,                64'd0,                   "DIV0");
    $display("PASS tb_ALU");
    $finish;
  end
endmodule
