// tb_instr_mem.v
// Testbench for instruction memory with hex preload
// Verifies word addressing: addr increments by 4 bytes per instruction
`timescale 1ns/1ps
module tb_instr_mem;
  localparam ADDR_WIDTH = 12;
  reg  [ADDR_WIDTH-1:0] addr;
  wire [31:0] instr;

  instr_mem #(.ADDR_WIDTH(12), .INIT_HEX("instr_mem.hex")) DUT(.addr(addr), .instr(instr));

  task expect(input [ADDR_WIDTH-1:0] a, input [31:0] exp);
    begin
      addr = a; #1;
      if (instr !== exp) begin
        $display("FAIL @addr=0x%0h got=0x%08h exp=0x%08h", a, instr, exp);
        $fatal;
      end
    end
  endtask

  initial begin
    expect(12'h000, 32'h00000013);
    expect(12'h004, 32'h00100093);
    expect(12'h008, 32'h00200113);
    expect(12'h00C, 32'h00308193);
    $display("PASS: instr_mem");
    $finish;
  end
endmodule
