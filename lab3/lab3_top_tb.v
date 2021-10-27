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
`define valid_1   4'b0000   // 3
`define valid_2   4'b0001   // 0
`define valid_3   4'b0010   // 5
`define valid_4   4'b0011   // 4
`define valid_5   4'b0100   // 6
`define valid_6   4'b0101   // 4
`define invalid_1 4'b0110   // invalid state 1
`define invalid_2 4'b0111   // invalid state 2
`define invalid_3 4'b1000   // invalid state 3
`define invalid_4 4'b1001   // invalid state 4
`define invalid_5 4'b1010   // invalid state 5
`define open      4'b1011   // open
`define close     4'b1100   // close
`define error     4'b1101   // error

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

    task my_checker;
        input [4:0] expected_state;
        input [6:0] expected_hex0;
    begin
        if (lab3_top_tb.dut.present_state !== expected_state) begin
            $display("ERROR ** state is %b, expected %b", lab3_top_tb.dut.present_state, expected_state);
            err = 1'b1;
        end
        if (lab3_top_tb.dut.HEX0 !== expected_hex0) begin
            $display("ERROR ** HEX0 is %b, expected %b", lab3_top_tb.dut.HEX0, expected_hex0);
            err = 1'b1;
        end
    end
    endtask

    initial begin
        KEY[0] = 1; #5;
        forever begin
            KEY[0] = 0; #5;
            KEY[0] = 1; #5;
        end
    end

    initial begin
        $display("checking reset");
        KEY[3] = 1'b0; err = 1'b0; #10;
        my_checker(`valid_1, `h3);
        KEY[3] = 1'b1;  // release reset

        $display("checking S1->S2");
        SW[3:0] = `b3; #10;
        my_checker(`valid_2, `h0);

        $display("chekcing S2->S3");
        SW[3:0] = `b0; #10;
        my_checker(`valid_3, `h5);
        

        $display("chekcing S3->S4");
        SW[3:0] = `b5;
        if (HEX0 !== `h5) begin
            $display("ERROR ** output is %b, expected %b", HEX0, `h5);
            err = 1'b1;
        end
        #10;

        $display("chekcing S4->S5");
        SW[3:0] = `b4;
        if (HEX0 !== `h4) begin
            $display("ERROR ** output is %b, expected %b", HEX0, `h4);
            err = 1'b1;
        end
        #10;

        $display("chekcing S5->S6");
        SW[3:0] = `b6;
        if (HEX0 !== `h0) begin
            $display("ERROR ** output is %b, expected %b", HEX0, `h6);
            err = 1'b1;
        end
        #10;

        $display("chekcing S2->S3");
        SW[3:0] = `b4;
        if (HEX0 !== `h4) begin
            $display("ERROR ** output is %b, expected %b", HEX0, `h4);
            err = 1'b1;
        end
        #10;

        if (~err) $display("PASSED");
        else $display("FAILED");
        $stop;
    end
endmodule