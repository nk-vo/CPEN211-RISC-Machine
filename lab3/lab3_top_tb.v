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
`define hx      7'bx_xxx_xxx
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

    task my_checker_valid;
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
    task my_checker_invalid;
        input [4:0] expected_state;
    begin
        if (lab3_top_tb.dut.present_state !== expected_state) begin
            $display("ERROR ** state is %b, expected %b", lab3_top_tb.dut.present_state, expected_state);
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
        my_checker_valid(`valid_1, `h3);
        KEY[3] = 1'b1;  // release reset

        $display("checking valid_1->valid_2");
        SW[3:0] = `b3; #10;
        my_checker_valid(`valid_2, `h0);
        
        $display("chekcing valid_2->valid_3");
        SW[3:0] = `b0; #10;
        my_checker_valid(`valid_3, `h5);
        
        $display("checking valid_3->valid_4");
        SW[3:0] = `b5; #10;
        my_checker_valid(`valid_4, `h4);
        
        $display("checking valid_4->valid_5");
        SW[3:0] = `b4; #10;
        my_checker_valid(`valid_5, `h6);

        $display("checking valid_5->valid_6");
        SW[3:0] = `b6; #10;
        my_checker_valid(`valid_6, `h4);
        
        $display("checking valid_6->open");
        SW[3:0] = `b4; #10;
        if (dut.present_state !== `open) begin
            $display("ERROR ** state is %b, expected %b", dut.present_state, `open);
            err = 1'b1;
        end
        if ({HEX3,HEX2,HEX1,HEX0} !== `OPEn) begin
            $display("ERROR ** HEX0 is %b, expected %b", {HEX3,HEX2,HEX1,HEX0}, `OPEn);
            err = 1'b1;
        end
        
        KEY[3] = 1'b0; #10; 
        {dut.HEX5,dut.HEX4,dut.HEX3,dut.HEX2,dut.HEX1,dut.HEX0} = {6{`hx}}; KEY[3] = 1'b1;
        $display("checking valid_1->invalid_1");
        SW[3:0] = `b1; #10;
        my_checker_invalid(`invalid_1);

        KEY[3] = 1'b0; #10; KEY[3] = 1'b1;
        $display("checking valid_2->invalid_2");
        SW[3:0] = `b3; #10; SW[3:0] = `b2; #10;
        my_checker_invalid(`invalid_2);
        
        KEY[3] = 1'b0; #10; KEY[3] = 1'b1;
        $display("checking valid_3->invalid_3");
        SW[3:0] = `b3; #10; SW[3:0] = `b0; #10; SW[3:0] = `b2; #10;
        my_checker_invalid(`invalid_3);

        KEY[3] = 1'b0; #10; KEY[3] = 1'b1;
        $display("checking valid_4->invalid_4");
        SW[3:0] = `b3; #10; SW[3:0] = `b0; #10; SW[3:0] = `b5; #10;
        SW[3:0] = `b2; #10;
        my_checker_invalid(`invalid_4);

        KEY[3] = 1'b0; #10; KEY[3] = 1'b1;
        $display("checking valid_5->invalid_5");
        SW[3:0] = `b3; #10; SW[3:0] = `b0; #10; SW[3:0] = `b5; #10;
        SW[3:0] = `b4; #10; SW[3:0] = `b2; #10;
        my_checker_invalid(`invalid_5);

        KEY[3] = 1'b0; #10; KEY[3] = 1'b1;
        $display("checking valid_6->close");
        SW[3:0] = `b3; #10; SW[3:0] = `b0; #10; SW[3:0] = `b5; #10;
        SW[3:0] = `b4; #10; SW[3:0] = `b6; #10; SW[3:0] = `b2; #10;
        my_checker_invalid(`close);
        if ({HEX5,HEX4,HEX3,HEX2,HEX1,HEX0} !== `CLOSEd) begin
            $display("ERROR ** HEX0 is %b, expected %b", {HEX5,HEX4,HEX3,HEX2,HEX1,HEX0}, `CLOSEd);
            err = 1'b1;
        end

        KEY[3] = 1'b0; #10;
        {dut.HEX5,dut.HEX4,dut.HEX3,dut.HEX2,dut.HEX1,dut.HEX0} = {6{`hx}}; KEY[3] = 1'b1;
        $display("checking error");
        SW[3:0] = 4'b1111; #10;
        if ({HEX4,HEX3,HEX2,HEX1,HEX0} !== `ErrOr) begin
            $display("ERROR ** HEX0 is %b, expected %b", {HEX4,HEX3,HEX2,HEX1,HEX0}, `ErrOr);
            err = 1'b1;
        end

        if (~err) $display("PASSED");
        else $display("FAILED");
        $stop;
    end
endmodule