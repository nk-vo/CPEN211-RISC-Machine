module datapath(clk,in,sr,Rn,w,aluop,lt,tsel,bsel,out);
    input clk, w, lt;
    input [7:0] in;
    input [1:0] sr, Rn, aluop;
    input [2:0] bsel, tsel;
    output [7:0] out;

    wire [7:0] R0, R1, R2, R3, tmp;
    reg [7:0] alu_out, rin;
    wire [7:0] Bin, tout, out;
    wire [3:0] writenum;

    always @(in, tmp, alu_out) begin
        case(sr)
            2'b00: rin = in;
            2'b01: rin = alu_out;
            2'b10: rin = tmp;
            default: rin =8'bx;
        endcase
    end

    Dec dec1(Rn, writenum);
    RLE r0(rin, {writenum[0] & w}, clk, R0);
    RLE r1(rin, {writenum[1] & w}, clk, R1);
    RLE r2(rin, {writenum[2] & w}, clk, R2);
    RLE r3(rin, {writenum[3] & w}, clk, R3);
    assign out = R0;

    Mux3 binMux(R3, R2, R1, bsel, Bin);
    Mux3 Tsel(Bin, R0, alu_out, tsel, tout);
    RLE Tout(tout, lt, clk, tmp);
    always @(aluop, tmp, Bin) begin
        case(aluop)
            2'b00: alu_out = tmp ^ Bin;
            2'b01: alu_out = tmp & Bin;
            2'b10: alu_out = tmp << 1;
            2'b11: alu_out = Bin;
            default: alu_out = 8'bx;
        endcase
    end
endmodule

module Dec(a, b) ;
  parameter n=2 ;
  parameter m=4 ;

  input  [n-1:0] a ;
  output [m-1:0] b ;

  assign b = 1 << a ;
endmodule

module RLE(in, load, clk, out);
  parameter n=8;

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
module Mux3(a2, a1, a0, sel, out);
    parameter k = 8;
    input [k-1:0] a2, a1, a0;
    input [2:0] sel;
    output [k-1:0] out;

    wire [k-1:0] out = ({k{sel[0]}} & a0) | ({k{sel[1]}} & a1) | ({k{sel[2]}} & a2);
endmodule

module Mux4(a3, a2, a1, a0, sel, out) ;
    parameter k = 8;
    input [k-1:0] a0, a1, a2, a3;
    input [1:0] sel;
    output reg [k-1:0] out;

    always @(*) begin
        case(sel)
        2'b00: out = a0;
        2'b01: out = a1;
        2'b10: out = a2;
        2'b11: out = a3;
        default: out = {k{1'bx}};	//even if bit size is not 16, will ensure no latches
        endcase
    end
endmodule

module vDFF(clk,Q, D);
    parameter n=5;
    input clk;
    input [n-1:0] Q;
    output reg [n-1:0] D;

    always @(posedge clk) begin
    D=Q;
    end
endmodule
