// tb_regfile.v
// Self-checking testbench for 64-bit register file (2R1W)
// Verifies reset clear, basic write/read, x0 constant zero, dual reads, and random stress
`timescale 1ns/1ps
module tb_regfile;
    localparam DATA_W = 64;
    localparam ADDR_W = 5;
    localparam DEPTH  = 32;

    reg clk, rst, we;
    reg  [ADDR_W-1:0] ra1, ra2, wa;
    reg  [DATA_W-1:0] wd;
    wire [DATA_W-1:0] rd1, rd2;

    regfile #(.DATA_W(DATA_W), .ADDR_W(ADDR_W), .DEPTH(DEPTH)) DUT (
        .clk(clk), .rst(rst), .we(we),
        .ra1(ra1), .ra2(ra2), .wa(wa), .wd(wd),
        .rd1(rd1), .rd2(rd2)
    );

    reg [DATA_W-1:0] model [0:DEPTH-1];
    reg [ADDR_W-1:0] aW, a1r, a2r;
    reg [DATA_W-1:0] dW;

    initial clk = 0;
    always #5 clk = ~clk;

    function [ADDR_W-1:0] rand_addr(input dummy);
        integer r;
    begin
        r = $random;
        rand_addr = r & (DEPTH-1);
    end
    endfunction

    task write_reg(input [ADDR_W-1:0] a, input [DATA_W-1:0] d);
    begin
        @(negedge clk);
        we <= 1; wa <= a; wd <= d;
        @(posedge clk);
        if (a != 0) model[a] <= d; else model[0] <= {DATA_W{1'b0}};
        @(negedge clk);
        we <= 0; wa <= 'b0; wd <= 'b0;
    end
    endtask

    task set_reads(input [ADDR_W-1:0] a1, input [ADDR_W-1:0] a2);
    begin
        ra1 <= a1; ra2 <= a2; #1;
    end
    endtask

    integer i, errors;
    initial begin
        we=0; wa=0; wd=0; ra1=0; ra2=0; rst=1; errors=0;
        for (i=0;i<DEPTH;i=i+1) model[i]='b0;

        @(posedge clk);
        rst <= 0;
        @(negedge clk);

        // 1. reset clears all
        set_reads(0, 0);
        if (rd1===0 && rd2===0) $display("PASS: reset cleared registers");
        else begin $display("FAIL: reset failed"); errors=errors+1; end

        // 2. basic write/read
        write_reg(5, 64'hDEAD_BEEF_F00D_0001);
        set_reads(5, 0);
        if (rd1===model[5] && rd2===0) $display("PASS: basic write/read works");
        else begin $display("FAIL: basic write/read"); errors=errors+1; end

        // 3. register 0 stays zero
        write_reg(0, 64'hFFFF);
        set_reads(0, 0);
        if (rd1===0 && rd2===0) $display("PASS: x0 remains zero");
        else begin $display("FAIL: x0 changed"); errors=errors+1; end

        // 4. dual independent reads
        write_reg(10, 64'h1111_2222_3333_4444);
        write_reg(11, 64'hAAAA_BBBB_CCCC_DDDD);
        set_reads(10, 11);
        if (rd1===model[10] && rd2===model[11]) $display("PASS: dual reads independent");
        else begin $display("FAIL: dual reads"); errors=errors+1; end

        // 5. write-through
        @(negedge clk);
        ra1 <= 12; ra2 <= 13;
        we  <= 1;  wa  <= 12; wd  <= 64'h1234_5678_9ABC_DEF0;
        #1;
        if (rd1===64'h1234_5678_9ABC_DEF0 && rd2===model[13])
            $display("PASS: write-through behavior");
        else begin $display("FAIL: write-through"); errors=errors+1; end
        @(posedge clk);
        model[12] <= 64'h1234_5678_9ABC_DEF0;
        @(negedge clk);
        we <= 0; wa <= 'b0; wd <= 'b0;

        // 6. random stress
        errors = 0;
        for (i=0; i<50; i=i+1) begin
            aW = rand_addr(0); dW = {$random,$random};
            write_reg(aW, dW);
            a1r = rand_addr(0); a2r = rand_addr(0);
            set_reads(a1r, a2r);
            if (rd1 !== (a1r==0?0:model[a1r])) errors=errors+1;
            if (rd2 !== (a2r==0?0:model[a2r])) errors=errors+1;
        end
        if (errors==0) $display("PASS: random stress check");
        else $display("FAIL: random stress (%0d errors)", errors);

        $display("Simulation finished");
        $finish;
    end
endmodule
