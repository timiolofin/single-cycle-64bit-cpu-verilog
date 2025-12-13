// pc.v
// Program counter register with synchronous update and asynchronous reset
module pc #(parameter WIDTH = 64) (
    input  wire             clk,
    input  wire             reset,
    input  wire [WIDTH-1:0] pc_in,
    output reg  [WIDTH-1:0] pc_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= {WIDTH{1'b0}};
        else
            pc_out <= pc_in;
    end
endmodule