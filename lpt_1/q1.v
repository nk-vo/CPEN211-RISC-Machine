`define Sa 3'b000
`define Sb 3'b001
`define Sc 3'b010
`define Sd 3'b011
`define Se 3'b100

module top_module(clk,reset,in,out);
  input clk, reset;
  input [1:0] in;
  output reg [2:0] out;

  reg [2:0] next_state;
  wire [2:0] present_state, next_state_reset;

  vDFF #(3) vdff(clk, next_state_reset, present_state);
  
  assign next_state_reset = reset ? `Sa : next_state;

  always @(*) begin
    case (present_state)
      `Sa:  if (in == 2'b01)      {next_state, out} = {`Sb, 3'b000};
            else if (in == 2'b10) {next_state, out} = {`Sd, 3'b000};
            else                  {next_state, out} = {`Sa, 3'b000};
            
      `Sb:                        {next_state, out} = {`Sa, 3'b001};

      `Sc:  if (in == 2'b10)      {next_state, out} = {`Sb, 3'b010};
            else if (in == 2'b11) {next_state, out} = {`Sd, 3'b010};
            else                  {next_state, out} = {`Sc, 3'b010};

      `Sd:                        {next_state, out} = {`Se, 3'b100};

      `Se:  if (in == 2'b01)      {next_state, out} = {`Sc, 3'b000};
            else                  {next_state, out} = {`Se, 3'b000};

      default:                    {next_state, out} = {6{1'bx}};
    endcase
  end
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