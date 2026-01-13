// data_mem.v
// Data memory with synchronous write and asynchronous read
// Word-addressed with optional hex preload
module data_mem #(
  parameter ADDR_WIDTH = 12,
  parameter DATA_WIDTH = 64,
  parameter INIT_HEX   = ""   // empty = no preload
)(
  input  wire                   clk,
  input  wire                   we,
  input  wire [ADDR_WIDTH-1:0]  addr,
  input  wire [DATA_WIDTH-1:0]  wdata,
  output reg  [DATA_WIDTH-1:0]  rdata
);
  localparam WORD_BYTES = DATA_WIDTH/8;
  localparam WORDS = (1<<ADDR_WIDTH)/WORD_BYTES;
  localparam WADDR_W = ADDR_WIDTH - $clog2(WORD_BYTES);

  reg [DATA_WIDTH-1:0] ram [0:WORDS-1];

  generate if (INIT_HEX != "") begin : g_init
    initial $readmemh(INIT_HEX, ram);
  end endgenerate

  wire [WADDR_W-1:0] waddr = addr[ADDR_WIDTH-1:$clog2(WORD_BYTES)];

  always @(*)      rdata = ram[waddr];
  always @(posedge clk) if (we) ram[waddr] <= wdata;
endmodule