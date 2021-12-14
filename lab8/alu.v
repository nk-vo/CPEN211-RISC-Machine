module ALU(Ain,Bin,ALUop,out,Z);
  input [15:0] Ain, Bin;
  input [1:0] ALUop;
  output [15:0] out;
  output [2:0] Z;

  wire [15:0] sum, diff;
  assign sum = Ain + Bin;
  assign diff = Ain - Bin;

  reg[15:0] tempout;
  always @(ALUop, Ain, Bin, sum, diff) begin
	case(ALUop)
	  2'b00: tempout = sum;		//adding
	  2'b01: tempout = diff;		//subtracting
	  2'b10: tempout = Ain & Bin;		//bitwise and
	  2'b11: tempout = ~Bin;		//compliment of B
	  default: tempout = {16{1'bx}};
	endcase
  end
assign out = tempout;
assign Z[0] = (out == 16'b0);		//zero status
assign Z[1] = ((ALUop == 2'b00) & ((Ain[15] == Bin[15])&&(Ain[15]!= sum[15])))|		//overflow status
	      ((ALUop == 2'b01) & ((Ain[15] != Bin[15])&&(Ain[15]!= diff[15])));
assign Z[2] = (out[15] == 1'b1);	//negative status
endmodule
