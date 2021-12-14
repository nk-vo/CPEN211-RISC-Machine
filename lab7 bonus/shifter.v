module shifter(in,shift,sout);
  input [15:0] in;
  input [1:0] shift;
  output [15:0] sout;

  reg [15:0] temps;

always @(*) begin
  case(shift)
	2'b00: temps = in;			//no shift
	2'b01: temps = {in[14:0],1'b0};		//left shift
	2'b10: temps = {1'b0, in[15:1]};	//right shift, 0 in MSB
	2'b11: temps = {in[15], in[15:1]};	//right shift, duplicating MSB
	default: temps = 16'bx;
  endcase
end
assign sout = temps;

endmodule
