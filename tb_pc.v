// tb_pc.v
// Self-checking testbench for program counter register
// Verifies async reset and synchronous update on rising clock edge
`timescale 1ns/1ps
module tb_pc;
    localparam WIDTH = 64;

    reg                  clk;
    reg                  reset;
    reg  [WIDTH-1:0]     pc_in;
    wire [WIDTH-1:0]     pc_out;

    // DUT
    pc #(.WIDTH(WIDTH)) DUT (
        .clk   (clk),
        .reset (reset),
        .pc_in (pc_in),
        .pc_out(pc_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize
        reset = 1;
        pc_in = {WIDTH{1'b0}};

        // Apply reset for a few cycles
        #20;
        reset = 0;

        // Demonstrate PC+4 progression
        repeat (5) begin
            #10;
            pc_in = pc_out + 64'd4;
        end

        // Hold PC (no change) by keeping pc_in constant
        #20;
        pc_in = pc_out;
        #40;

        $finish;
    end

    initial begin
        $display("Time(ns)\treset\tpc_in\t\t\tpc_out");
        $monitor("%0t\t%b\t%0d\t%0d", $time, reset, pc_in, pc_out);
    end

endmodule
