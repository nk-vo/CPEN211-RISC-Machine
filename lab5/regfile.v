module regfile(data_in,writenum,write,readnum,clk,data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;
    
    wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    wire [7:0] load_enable, read_enable;

    dec #(3,8) write_dec(writenum, load_enable);
    dec #(3,8) read_dec(readnum, read_enable);

    reg [15:0] data_out;
    always @(*) begin
        case(read_enable)
            8'b0000_0001: data_out = R0;
            8'b0000_0010: data_out = R1;
            8'b0000_0100: data_out = R2;
            8'b0000_1000: data_out = R3;
            8'b0001_0000: data_out = R4;
            8'b0010_0000: data_out = R5;
            8'b0100_0000: data_out = R6;
            8'b1000_0000: data_out = R7;
            default: data_out = {16{1'bx}};
        endcase
    end

    register #(16) r0(clk, load_enable[0] & write, data_in, R0);
    register #(16) r1(clk, load_enable[1] & write, data_in, R1);
    register #(16) r2(clk, load_enable[2] & write, data_in, R2);
    register #(16) r3(clk, load_enable[3] & write, data_in, R3);
    register #(16) r4(clk, load_enable[4] & write, data_in, R4);
    register #(16) r5(clk, load_enable[5] & write, data_in, R5);
    register #(16) r6(clk, load_enable[6] & write, data_in, R6);
    register #(16) r7(clk, load_enable[7] & write, data_in, R7);

endmodule

module dec(in, out);
    parameter n = 2, m = 4;
    input [n-1:0] in;
    output [m-1:0] out;

    assign out = 1 << in;
endmodule

module vDFF(clk, in, out);
    parameter n = 2;
    input clk;
    input [n-1:0] in;
    output reg [n-1:0] out;

    always @(posedge clk)
        out = in;
endmodule

module register(clk, load_enable, data_in, data_out);
    parameter n = 2;
    input clk, load_enable;
    input [n-1:0] data_in;
    output [n-1:0] data_out;

    wire [n-1:0] data = load_enable ? data_in : data_out;

    vDFF #(n) vdff(clk, data, data_out);
endmodule