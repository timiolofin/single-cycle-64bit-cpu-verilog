// regfile.v
// 64-bit register file with two read ports and one write port
// Synchronous write, asynchronous read, x0 hardwired to zero
module regfile #(
    parameter DATA_W = 64,
    parameter ADDR_W = 5,
    parameter DEPTH  = 32
)(
    input                   clk,
    input                   rst,
    input                   we,
    input  [ADDR_W-1:0]     ra1,
    input  [ADDR_W-1:0]     ra2,
    input  [ADDR_W-1:0]     wa,
    input  [DATA_W-1:0]     wd,
    output [DATA_W-1:0]     rd1,
    output [DATA_W-1:0]     rd2
);
    reg [DATA_W-1:0] regs [0:DEPTH-1];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < DEPTH; i = i + 1)
                regs[i] <= {DATA_W{1'b0}};
        end else if (we && (wa != {ADDR_W{1'b0}})) begin
            regs[wa] <= wd;
        end
        // x0 is always zero
        regs[0] <= {DATA_W{1'b0}};
    end

    // NO forwarding from wd
    assign rd1 = (ra1 == {ADDR_W{1'b0}}) ? {DATA_W{1'b0}} : regs[ra1];
    assign rd2 = (ra2 == {ADDR_W{1'b0}}) ? {DATA_W{1'b0}} : regs[ra2];
endmodule