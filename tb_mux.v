// tb_mux.v
// Testbench for parameterized 2:1 mux (WIDTH=64)
// Verifies correct selection for sel=0 and sel=1
`timescale 1ns/1ps
module tb_mux;
    reg  [63:0] a, b;
    reg         sel;
    wire [63:0] y;

    mux #(.WIDTH(64)) DUT(.a(a), .b(b), .sel(sel), .y(y));

    integer fails;

    task expect;
        input [63:0] e;
        begin
            #1;
            if (y !== e) begin
                $display("FAIL sel=%b a=%h b=%h exp=%h got=%h", sel, a, b, e, y);
                fails = fails + 1;
            end
        end
    endtask

    initial begin
        fails = 0;
        a = 64'hAAAA_AAAA_AAAA_AAAA;
        b = 64'h5555_5555_5555_5555;

        sel=0; expect(a);
        sel=1; expect(b);
        sel=0; a=64'hDEAD_BEEF_CAFE_1234; expect(a);

        if (fails==0) $display("PASS");
        else $display("FAILS=%0d", fails);
        $finish;
    end
endmodule
