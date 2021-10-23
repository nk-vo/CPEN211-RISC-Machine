`timescale 1 ps/ 1 ps
// BINARY code 0-9
`define b0  4'b0000
`define b1  4'b0001
`define b2  4'b0010
`define b3  4'b0011
`define b4  4'b0100
`define b5  4'b0101
`define b6  4'b0110
`define b7  4'b0111
`define b8  4'b1000
`define b9  4'b1001

// states corresponds to 6 last ID digits and open/close/error
`define S0    4'b0000   // start state
`define S1    4'b0001   // 3
`define S2    4'b0010   // 0
`define S3    4'b0011   // 5
`define S4    4'b0100   // 4
`define S5    4'b0101   // 6
`define S6    4'b0110   // 4
`define open  4'b0111   // open
`define close 4'b1000   // close
`define error 4'b1001   // error
`define base  4'bxxxx   // base case

// HEXCODE 0-9
`define h0      7'b1_000_000
`define h1      7'b0_000_110
`define h2      7'b0_100_100
`define h3      7'b0_110_000
`define h4      7'b0_011_001
`define h5      7'b0_010_010
`define h6      7'b0_000_010
`define h7      7'b1_111_000
`define h8      7'b0_000_000
`define h9      7'b0_010_000
`define OPEn    {7'b1_000_000,7'b0_001_100,7'b0_000_110,7'b0_101_011}                           // 28 bits HEX3 -> HEX0
`define CLOSEd  {7'b1_000_110,7'b1_000_111,7'b1_000_000,7'b0_010_010,7'b0_000_110,7'b0_100_001} // 42 bits HEX5 -> HEX0
`define ErrOr   {7'b0_000_110,7'b0_101_111,7'b0_101_111,7'b1_000_000,7'b0_101_111}              // 35 bits HEX4 -> HEX0


module lab3_top_tb;
    reg [9:0] SW;
    reg [3:0] KEY;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [9:0] LEDR;
    reg err;

    lab3_top dut(SW, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);

    initial begin
        KEY[0] = 1; #5;
        forever begin
            KEY[0] = 0; #5;
            KEY[0] = 1; #5;
        end
    end

    initial begin
        KEY[3] = 1'b0;
        SW[3:0] = 4'b0000;
        err = 1'b0;
        #10;
        if (HEX0 !== 7'bx_xxx_xxx) begin
            $display("ERROR ** output is %b, expected %b", HEX0, 7'bx_xxx_xxx);
            err = 1'b1;
        end

        KEY[3] = 1'b1;  // release reset
        $display("checking S1->S2");
        SW[3:0] = `b3;
        if (HEX0 !== `h3) begin
            $display("ERROR ** output is %b, expected %b", HEX0, `h3);
            err = 1'b1;
        end
    end
endmodule