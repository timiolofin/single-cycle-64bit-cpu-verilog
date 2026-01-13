// tb_logicunit.v
// Testbench for 64-bit logic unit (AND/OR/XOR/NOR)
// Applies directed vectors and self-checks output against expected result
`timescale 1ns/1ps
module tb_logicunit;
    reg  [63:0] a, b;
    reg  [1:0]  op;
    wire [63:0] y;

    // Device under test
    logicunit DUT (
        .a (a),
        .b (b),
        .op(op),
        .y (y)
    );

    localparam OP_AND = 2'b00;
    localparam OP_OR  = 2'b01;
    localparam OP_XOR = 2'b10;
    localparam OP_NOR = 2'b11;

    // Apply one logic operation and verify output
    task run_case(input [63:0] a_in, input [63:0] b_in, input [1:0] op_in);
        reg [63:0] expected;
    begin
        a  = a_in;
        b  = b_in;
        op = op_in;
        #5;  // allow propagation

        case (op_in)
            OP_AND: expected = a_in & b_in;
            OP_OR:  expected = a_in | b_in;
            OP_XOR: expected = a_in ^ b_in;
            OP_NOR: expected = ~(a_in | b_in);
            default: expected = 64'hX;
        endcase

        $display("LOGIC: op=%b a=0x%h b=0x%h | y=0x%h (exp=0x%h) @ t=%0t",
                 op, a, b, y, expected, $time);

        if (y !== expected) begin
            $display("FAIL op=%b exp=0x%h got=0x%h", op_in, expected, y);
            $fatal(1);
        end
    end
    endtask

    initial begin
        $display("==== tb_logicunit start ====");
        a = 0; b = 0; op = 0; #5;

        run_case(64'hFFFF_0000_F0F0_1234, 64'h0F0F_FFFF_0000_5678, OP_AND);
        run_case(64'hFFFF_0000_F0F0_1234, 64'h0F0F_FFFF_0000_5678, OP_OR);
        run_case(64'hAAAA_AAAA_AAAA_AAAA, 64'h5555_5555_5555_5555, OP_XOR);
        run_case(64'h0000_0000_0000_0000, 64'hFFFF_FFFF_FFFF_FFFF, OP_NOR);

        $display("PASS tb_logicunit");
        $finish;
    end
endmodule
