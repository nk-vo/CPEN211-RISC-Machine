module fun(clk, reset, s, in, op, out, done);
  input clk, reset, s;
  input [7:0] in;
  input [1:0] op;
  output [15:0] out;
  output done;


endmodule

module vDFF(clk, in, out);
  parameter n = 1;
  input clk;
  input [n-1:0] in;
  output reg [n-1:0] out;
  always @(posedge clk) begin
    out <= in;
  end
endmodule