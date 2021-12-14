module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, mdata, sximm8, PC, sximm5, Z_out, C);
  input[15:0] mdata, sximm8, PC, sximm5;
  input[2:0] writenum, readnum;
  input[1:0] shift, ALUop, vsel;
  input write, clk, loada, loadb, loadc, loads, asel, bsel;

  output [2:0] Z_out;
  output[15:0] C;

  wire[15:0] data_in, data_out, aout, bout, sout, Ain, Bin, out;
  wire [2:0] Z;

Mux4 data_prereg(mdata, sximm8, PC, C, vsel, data_in);		//instantiate multiplexer, selecting either input data out output data to be re-written
regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);	//instantiate register file module
RLE rleA(data_out, loada, clk, aout);					//instantiate register file a
RLE rleB(data_out, loadb, clk, bout);					//instantiate register file b
shifter shifter(bout, shift, sout);					//instantiate shifter
Mux2 ainMux(16'b0, aout, asel, Ain);					//instantiate multiplexer a
Mux2 binMux(sximm5, sout, bsel, Bin);		//instantiate multiplexer b
ALU u2(Ain, Bin, ALUop, out, Z);					//instantiate ALU module
RLE #(3) status(Z, loads, clk, Z_out);					//instantiate status register file
RLE rlec(out, loadc, clk, C);				//instantiate register file c

endmodule

//4 input k bit multiplexer
module Mux4(a3, a2, a1, a0, sel, out) ;
  parameter k = 16;
  input [k-1:0] a0, a1, a2, a3;
  input [1:0] sel;
  output[k-1:0] out;

  reg [k-1:0] tempout;
  always @(*) begin
	case(sel)
	  2'b00: tempout = a0;
	  2'b01: tempout = a1;
	  2'b10: tempout = a2;
	  2'b11: tempout = a3;
	  default: tempout = 16'bxxxxxxxxxxxxxxxx;	//even if bit size is not 16, will ensure no latches
	endcase
  end
  assign out = tempout;
endmodule
//2 input k bit multiplexer
module Mux2(a1, a0, sel, out) ;
  parameter k = 16;
  input [k-1:0] a0, a1;
  input sel;
  output[k-1:0] out;

  reg [k-1:0] tempout;
  always @(*) begin
	case(sel)
	  1'b0: tempout = a0;
	  1'b1: tempout = a1;
	  default: tempout = {k{1'bx}};	//even if bit size is not 16, will ensure no latches
	endcase
  end
  assign out = tempout;
endmodule
