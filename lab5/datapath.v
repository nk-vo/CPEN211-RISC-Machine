module datapath (clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, 
	            loadc, loads, writenum, write, datapath_in, Z_out, datapath_out );

    input clk, write, loada, loadb, loadc, loads, asel, bsel, vsel;
	input [1:0] shift, ALUop;
	input [2:0] readnum, writenum;
	input [15:0] datapath_in;

    output Z_out;
    output [15:0] datapath_out;

    wire [15:0] data_in = vsel ? datapath_in : datapath_out;

    wire [15:0] data_out;
    regfile REGFILE(data_in,writenum,write,readnum,clk,data_out);

    wire [15:0] A_reg, B_reg;
    register #(16) regA(clk, loada, data_out, A_reg);
    register #(16) regB(clk, loadb, data_out, B_reg);

    wire [15:0] sout;
    shifter shifter_out(B_reg, shift, sout);

    wire [15:0] Ain = asel ? {16{1'b0}} : A_reg;
    wire [15:0] Bin = bsel ? {{11{1'b0}}, datapath_in[4:0]} : sout;

    wire [15:0] out;
    wire Z;
    ALU alu_u2(Ain, Bin, ALUop, out, Z);

    register #(1) status(clk, loads, Z, Z_out);
    register #(16) regC(clk, loadc, out, datapath_out);
endmodule