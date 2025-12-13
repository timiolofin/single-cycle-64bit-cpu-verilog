// tb_data_mem.v
// Testbench for 64-bit data memory with hex preload
// Verifies async read, sync write, and word addressing
`timescale 1ns/1ps
module tb_data_mem;
  localparam ADDR_WIDTH = 12;
  reg                    clk;
  reg                    we;
  reg  [ADDR_WIDTH-1:0]  addr;
  reg  [63:0]            wdata;
  wire [63:0]            rdata;

  // tb/tb_data_mem.v
  data_mem  #(.ADDR_WIDTH(12), .INIT_HEX("data_mem_init.hex")) DUT(.clk(clk), .we(we), .addr(addr), .wdata(wdata), .rdata(rdata));


  initial clk = 0;
  always #5 clk = ~clk;

  task read_chk(input [ADDR_WIDTH-1:0] a, input [63:0] exp);
    begin
      addr = a; we = 0; wdata = 64'hX; #1;
      if (rdata !== exp) begin
        $display("FAIL READ @0x%0h got=0x%016h exp=0x%016h", a, rdata, exp);
        $fatal;
      end
    end
  endtask

  task write_do(input [ADDR_WIDTH-1:0] a, input [63:0] d);
    begin
      addr = a; wdata = d; we = 1; @(posedge clk); #1; we = 0;
    end
  endtask

  initial begin
    read_chk(12'h000, 64'h0000_0000_0000_0001);
    read_chk(12'h008, 64'h0000_0000_0000_0002);
    read_chk(12'h010, 64'hFFFF_FFFF_FFFF_FFFF);
    read_chk(12'h018, 64'h0123_4567_89AB_CDEF);
    write_do(12'h020, 64'hDEAD_BEEF_CAFE_F00D);
    read_chk (12'h020, 64'hDEAD_BEEF_CAFE_F00D);
    write_do(12'h008, 64'hA5A5_A5A5_A5A5_A5A5);
    read_chk (12'h008, 64'hA5A5_A5A5_A5A5_A5A5);
    $display("PASS: data_mem");
    $finish;
  end
endmodule
