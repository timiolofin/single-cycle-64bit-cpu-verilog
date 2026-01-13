// tb_shifter.v
// Testbench for 64-bit shifter (SLL, SRL, SRA)
`timescale 1ns/1ps
module tb_shifter;
    reg  [63:0] din;
    reg  [5:0]  shamt;
    reg  [1:0]  mode;
    wire [63:0] dout;

    shifter DUT(.din(din), .shamt(shamt), .mode(mode), .dout(dout));

    integer fails;

    task expect;
        input [63:0] e;
        begin
            #1;
            if (dout !== e) begin
                $display("FAIL mode=%b shamt=%0d din=%h exp=%h got=%h", mode, shamt, din, e, dout);
                fails = fails + 1;
            end
        end
    endtask

    initial begin
        fails=0;
        din = 64'h0000_0000_0000_0001;

        // SLL by 3
        mode=2'b00; shamt=6'd3; expect(64'h0000_0000_0000_0008);

        // SRL by 1 on a pattern
        din = 64'h8000_0000_0000_0000;
        mode=2'b01; shamt=6'd1; expect(64'h4000_0000_0000_0000);

        // SRA by 1 should keep sign
        din = 64'h8000_0000_0000_0000;
        mode=2'b10; shamt=6'd1; expect(64'hC000_0000_0000_0000);

        // No-op default
        din = 64'h1234_5678_9ABC_DEF0; mode=2'b11; shamt=6'd7; expect(64'h1234_5678_9ABC_DEF0);

        if (fails==0) $display("PASS");
        else $display("FAILS=%0d", fails);
        $finish;
    end
endmodule
