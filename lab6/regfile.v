module regfile(data_in,writenum,write,readnum,clk,data_out);
  input [15:0] data_in;
  input [2:0] writenum, readnum;
  input write, clk;
  output [15:0] data_out;

  wire [7:0] writepos, readpos;
  wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

//decoder for which one of 8 registers to write to
Dec #(3,8) dec1(writenum, writepos);

//instantiate 8 register files with load enable
RLE r0(data_in, (writepos[0] & write), clk, R0);
RLE r1(data_in, (writepos[1] & write), clk, R1);
RLE r2(data_in, (writepos[2] & write), clk, R2);
RLE r3(data_in, (writepos[3] & write), clk, R3);
RLE r4(data_in, (writepos[4] & write), clk, R4);
RLE r5(data_in, (writepos[5] & write), clk, R5);
RLE r6(data_in, (writepos[6] & write), clk, R6);
RLE r7(data_in, (writepos[7] & write), clk, R7);

//decoder for which register to read from
Dec #(3,8) dec2(readnum, readpos);

//multiplexer to read from correct register
Mux8 mux1(R7, R6, R5, R4, R3, R2, R1, R0, readpos, data_out);

endmodule

//decoder module
module Dec(a, b) ;
  parameter n=2 ;
  parameter m=4 ;

  input  [n-1:0] a ;
  output [m-1:0] b ;

  assign b = 1 << a ;
endmodule

//register with load enable module
module RLE(in, load, clk, out);
  parameter n=16;

  input [n-1:0] in;
  input load, clk;
  output [n-1:0] out;

  reg [n-1:0] tempout;

  always @(posedge clk) begin
	if(load==1'b1)		//only pass input to output if load has logic value 1
	  tempout = in;
  end
  assign out = tempout;

endmodule

module Mux8(a7, a6, a5, a4, a3, a2, a1, a0, s, b) ;
  parameter k = 16 ;
  input [k-1:0] a0, a1, a2, a3, a4, a5, a6, a7 ;  // inputs
  input [7:0]   s ; // one-hot select
  output[k-1:0] b ;
  wire [k-1:0] b = ({k{s[0]}} & a0) | 
                   ({k{s[1]}} & a1) |
                   ({k{s[2]}} & a2) |
                   ({k{s[3]}} & a3) |
		           ({k{s[4]}} & a4) | 
                   ({k{s[5]}} & a5) |
                   ({k{s[6]}} & a6) |
                   ({k{s[7]}} & a7) ;
endmodule
