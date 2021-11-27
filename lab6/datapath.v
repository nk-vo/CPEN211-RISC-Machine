module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, 
                loadc, loads, writenum, write, mdata, sximm8, PC, sximm5, Z_out, C);
    input[15:0] mdata, sximm8, PC, sximm5;
    input[2:0] writenum, readnum;
    input[1:0] shift, ALUop, vsel;
    input write, clk, loada, loadb, loadc, loads, asel, bsel;

    output [2:0] Z_out;
    output[15:0] C;

    wire[15:0] data_in, data_out, aout, bout, sout, Ain, Bin, out;
    wire [2:0] Z;

    Mux4 data_input(mdata, sximm8, PC, C, vsel, data_in);		        //select between 4 different inputs
    regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);	//write/read register data
    RLE rleA(data_out, loada, clk, aout);					            //load register A
    RLE rleB(data_out, loadb, clk, bout);					            //load register B
    shifter shifter(bout, shift, sout);					                //shift data from register B
    Mux2 ainMux(16'b0, aout, asel, Ain);					            //select between register A data and 16'b0
    Mux2 binMux(sximm5, sout, bsel, Bin);		                        //select between shifted data from register B and sximm5
    ALU u2(Ain, Bin, ALUop, out, Z);					                //perform ALU
    RLE #(3) status(Z, loads, clk, Z_out);					            //load status register file
    RLE rlec(out, loadc, clk, C);				                        //load register C

endmodule

//4 input k bit multiplexer
module Mux4(a3, a2, a1, a0, sel, out) ;
    parameter k = 16;
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
//2 input k bit multiplexer
module Mux2(a1, a0, sel, out) ;
    parameter k = 16;
    input [k-1:0] a0, a1;
    input sel;
    output reg [k-1:0] out;

    always @(*) begin
        case(sel)
            1'b0: out = a0;
            1'b1: out = a1;
            default: out = {k{1'bx}};	//even if bit size is not 16, will ensure no latches
        endcase
    end
endmodule
