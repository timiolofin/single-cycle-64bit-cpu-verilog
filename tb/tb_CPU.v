// tb_CPU.v
// Top-level CPU system test
// Loads a small program directly into instruction ROM and initializes data RAM
// Runs for N cycles and checks stored result in memory
`timescale 1ns/1ps
module tb_CPU;
    reg clk;
    reg reset;

    // DUT
    CPU dut (
        .clk  (clk),
        .reset(reset)
    );

    // 10 ns clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Stimulus + memory init
    initial begin
        // ===== Instruction memory (ROM) =====
        // 0: lw   $t0, 0($zero)       # a
        // 1: lw   $t1, 8($zero)       # b
        // 2: lw   $t2, 16($zero)      # c
        // 3: lw   $t3, 24($zero)      # d
        // 4: lw   $t4, 32($zero)      # e
        // 5: lw   $t5, 40($zero)      # f
        // 6: sub  $t6, $t1, $t2       # t6 = b - c
        // 7: add  $t7, $t3, $t0       # t7 = d + a
        // 8: mult $t7, $t7, $t4       # t7 = (d + a)*e
        // 9: add  $t6, $t6, $t7       # t6 = (b - c) + (d + a)*e
        //10: div  $t7, $t6, $t5       # y = t6 / f
        //11: sw   $t7, 48($zero)      # y -> mem[48]
        //12: beq  $zero,$zero,-1      # infinite loop

        dut.u_imem.rom[0]  = 32'h8C080000;
        dut.u_imem.rom[1]  = 32'h8C090008;
        dut.u_imem.rom[2]  = 32'h8C0A0010;
        dut.u_imem.rom[3]  = 32'h8C0B0018;
        dut.u_imem.rom[4]  = 32'h8C0C0020;
        dut.u_imem.rom[5]  = 32'h8C0D0028;
        dut.u_imem.rom[6]  = 32'h012A7022;
        dut.u_imem.rom[7]  = 32'h01687820;
        dut.u_imem.rom[8]  = 32'h01EC7818;
        dut.u_imem.rom[9]  = 32'h01CF7020;
        dut.u_imem.rom[10] = 32'h01CD781A;
        dut.u_imem.rom[11] = 32'hAC0F0030;
        dut.u_imem.rom[12] = 32'h1000FFFF;

        // ===== Data memory (RAM) =====
        // byte addrs: a@0, b@8, c@16, d@24, e@32, f@40, y@48
        dut.u_dmem.ram[0] = -64'sd1000; // a
        dut.u_dmem.ram[1] =  64'sd200;  // b
        dut.u_dmem.ram[2] =  64'sd300;  // c
        dut.u_dmem.ram[3] = -64'sd400;  // d
        dut.u_dmem.ram[4] =  64'sd40;   // e
        dut.u_dmem.ram[5] =  64'sd3;    // f
        dut.u_dmem.ram[6] =  64'sd0;    // y

        // ===== Reset and run =====
        reset = 1'b1;
        #20;
        reset = 1'b0;

        #140;  // run long enough

        // ===== Print result =====
        $display("a = %0d", $signed(dut.u_dmem.ram[0]));
        $display("b = %0d", $signed(dut.u_dmem.ram[1]));
        $display("c = %0d", $signed(dut.u_dmem.ram[2]));
        $display("d = %0d", $signed(dut.u_dmem.ram[3]));
        $display("e = %0d", $signed(dut.u_dmem.ram[4]));
        $display("f = %0d", $signed(dut.u_dmem.ram[5]));
        $display("y = %0d", $signed(dut.u_dmem.ram[6]));

        $finish;
    end
endmodule
