module ALU(Ain,Bin,ALUop,out,Z);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output [15:0] out;
    output Z;

    reg [15:0] out;
    reg Z;
    always @(Ain, Bin, ALUop) begin
        case(ALUop)
            2'b00: out = Ain + Bin;     // Addition
            2'b01: out = Ain - Bin;     // Substraction
            2'b10: out = Ain & Bin;     // AND-ed
            2'b11: out = ~Bin;          // Complement Bin
            default: out = {16{1'bx}};
        endcase
        case(out)
            {16{1'b0}}: Z = 1'b1;       // out = 0 -> Z = 1
            {16{1'bx}}: Z = 1'bx;
            default: Z = 1'b0;          // out != 0 -> Z = 0
        endcase
    end
endmodule