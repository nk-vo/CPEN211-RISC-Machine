module ALU(Ain,Bin,ALUop,out,Z);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output [15:0] out;
    output [2:0] Z;

    reg [15:0] out;
    wire [15:0] sum = Ain + Bin;
    wire [15:0] diff = Ain - Bin;
    assign Z[0] = (out == 16'b0);   //zero status - Z
    assign Z[1] = ((ALUop == 2'b00) & ((Ain[15] == Bin[15]) & (Ain[15]!= sum[15])))|		//overflow status - V
	              ((ALUop == 2'b01) & ((Ain[15] != Bin[15]) & (Ain[15]!= diff[15])));
    assign Z[2] = (out[15] == 1'b1); //negative status - N
    
    always @(Ain, Bin, ALUop, sum, diff) begin
        case(ALUop)
            2'b00: out = sum;     // Addition
            2'b01: out = diff;     // Substraction
            2'b10: out = Ain & Bin;     // AND-ed
            2'b11: out = ~Bin;          // Complement Bin
            default: out = {16{1'bx}};
        endcase
    end
endmodule