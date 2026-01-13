// tb_sign_extend.v
// Testbench for 16->64 sign extension
`timescale 1ns/1ps
module tb_sign_extend;
    reg  [15:0] imm16;
    wire [63:0] imm64;

    sign_extend DUT(.imm16(imm16), .imm64(imm64));

    integer fails;

    task check;
        input [15:0] in;
        input [63:0] exp;
        begin
            imm16 = in; #1;
            if (imm64 !== exp) begin
                $display("FAIL in=%h exp=%h got=%h", in, exp, imm64);
                fails = fails + 1;
            end
        end
    endtask

    initial begin
        fails = 0;
        check(16'h0001, 64'h0000_0000_0000_0001);
        check(16'h7FFF, 64'h0000_0000_0000_7FFF);
        check(16'h8000, 64'hFFFF_FFFF_FFFF_8000);
        check(16'hFFFF, 64'hFFFF_FFFF_FFFF_FFFF);
        if (fails==0) $display("PASS");
        else $display("FAILS=%0d", fails);
        $finish;
    end
endmodule
