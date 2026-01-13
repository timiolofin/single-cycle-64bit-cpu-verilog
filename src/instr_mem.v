// instr_mem.v
// Read-only instruction memory
// Word-addressed, combinational read
// Optional hex preload via $readmemh
module instr_mem #(
  parameter ADDR_WIDTH = 12,
  parameter DATA_WIDTH = 32,
  parameter INIT_HEX   = ""   // empty = no preload
)(
  input  wire [ADDR_WIDTH-1:0] addr,
  output wire [DATA_WIDTH-1:0] instr
);
  localparam WORD_BYTES = DATA_WIDTH/8;
  localparam WORDS = (1<<ADDR_WIDTH)/WORD_BYTES;

  reg [DATA_WIDTH-1:0] rom [0:WORDS-1];

  generate if (INIT_HEX != "") begin : g_init
    initial $readmemh(INIT_HEX, rom);
  end endgenerate

  assign instr = rom[addr[ADDR_WIDTH-1:$clog2(WORD_BYTES)]];
endmodule