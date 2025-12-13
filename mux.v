// mux.v
// Parameterized 2:1 combinational multiplexer
module mux #(
    parameter WIDTH = 64
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             sel,
    output wire [WIDTH-1:0] y
);
    assign y = sel ? b : a;
endmodule