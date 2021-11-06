`timescale 1 ps/ 1  ps

// State definitions
`define SW 4
`define Sa 4'b0000
`define Sb 4'b0001
`define Sc 4'b0010
`define Sd 4'b0011
`define Se 4'b0100
`define Sf 4'b0101
`define Sg 4'b0110
`define DCa 4'b0111
`define DCb 4'b1000
`define DCc 4'b1001
`define DCd 4'b1010
`define DCe 4'b1011
`define DCf 4'b1100

// module instationation for lab 3 test bench
module lab3_top_tb;
    reg [3:0] SW;
    reg [3:0] KEY;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [9:0] LEDR;

    wire [3:0] state;
    reg [41:0] temp;
    reg err;            // to keep track of errors

    // module instantiation for the FSM
    fsmNew FSMDUT(~KEY[0], ~KEY[3], SW[3:0], state[3:0]);

    // module instantiation for the decoder
    decoder DECDUT(state[3:0], SW[3:0], HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

    // module instantiation for the top level module
    lab3_top DUT(SW, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);

    
    // created a task to check if there is error
    task stateErrorCheck;
    input [3:0] result, expected;
    begin
        if(result != expected) begin
            $display("ERROR: The output is %b, expected is %b", result, expected);
            err = 1'b1;
        end
    end
    endtask

    // clock being initialised (in this case the clock will be high @ 0 because the top level function
    // inverts the Key inputs because of the DE1)
    initial begin
        KEY[0] = 0;
        #5;
        forever begin
            KEY[0] = 1;
            #5;
            KEY[0] = 0;
            #5;
        end
    end

    // TEST CASES
    //******************************************
    // Test Case 1: All combinations are correct
    //******************************************
    initial begin
        err = 1'b0;         // setting error to 0 at the start
        SW[3:0] = 4'b0000;
        #3;

        $display("TEST CASE 1: Correct Combinations");
        // Reset
        KEY[3] = 1'b0;      // reset is inverted (0 is high, 1 is low)
        #10;
        $display("Reset hit, go to State A");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sa);
        KEY[3] = 1'b1;
        
        // Enter 8
        SW[3:0] = 4'b1000;
        #10;
        $display("8 entered, go to State B");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sb);

        // Enter 7
        SW[3:0] = 4'b0111;
        #10;
        $display("7 entered, go to State C");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sc);

        // Enter 5
        SW[3:0] = 4'b0101;
        #10;
        $display("5 entered, go to State D");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sd);

        // Enter 8
        SW[3:0] = 4'b1000;
        #10;
        $display("8 entered, go to State E");
        stateErrorCheck(lab3_top_tb.DUT.state, `Se);

        // Enter 2
        SW[3:0] = 4'b0010;
        #10;
        $display("2 entered, go to State F");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sf);

        // Enter 8
        SW[3:0] = 4'b1000;
        #10;
        $display("8 entered, go to State G");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sg);
        #10;
        
        // check to see if there is an error at the end, if so, display an error message
        if(err == 1) begin
            $display("Test case 1: FAIL");
        end else begin
            $display("Test case 1: PASS");
        end
        

        //********************************************************
        // Test Case 2: 1 combination in between will be incorrect.
        //********************************************************

        $display("TEST CASE 2: Incorrect Combinations");
        // Reset
        SW[3:0] = 4'b0000;
        KEY[3] = 1'b0;
        #10;
        $display("Reset hit, go to State A");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sa);
        KEY[3] = 1'b1;
        
        // Enter 8
        SW[3:0] = 4'b1000;
        #10;
        $display("8 entered, go to State B");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sb);

        // Enter 7
        SW[3:0] = 4'b0111;
        #10;
        $display("7 entered, go to State C");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sc);

        // Enter 5
        SW[3:0] = 4'b0101;
        #10;
        $display("5 entered, go to State D");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sd);

        // Enter 8
        SW[3:0] = 4'b1000;
        #10;
        $display("8 entered, go to State E");
        stateErrorCheck(lab3_top_tb.DUT.state, `Se);

        // Enter 3 (WRONG COMBINATION)
        SW[3:0] = 4'b0011;
        #10;
        $display("3 entered, go to State DCe");
        stateErrorCheck(lab3_top_tb.DUT.state, `DCe);

        // Enter 8 (We don't care anymore)
        SW[3:0] = 4'b1000;
        #10;
        $display("8 entered, go to State DCf");
        stateErrorCheck(lab3_top_tb.DUT.state, `DCf);
        #10;
        
        // check to see if there is an error at the end, if so, display an error message
        if(err == 1) begin
            $display("Test case 2: FAIL");
        end else begin
            $display("Test case 2: PASS");
        end


        // ******************************************
        // Test Case 3: Remain in State G until reset.
        // ******************************************

        $display("TEST CASE 3: Remain in State G until reset");
        // Reset
        SW[3:0] = 4'b0000;
        KEY[3] = 1'b0;
        #10;
        $display("Reset hit, go to State A");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sa);
        KEY[3] = 1'b1;
        
        // Enter 8
        SW[3:0] = 4'b1000;
        #10;
        $display("8 entered, go to State B");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sb);

        // Enter 7
        SW[3:0] = 4'b0111;
        #10;
        $display("7 entered, go to State C");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sc);

        // Enter 5
        SW[3:0] = 4'b0101;
        #10;
        $display("5 entered, go to State D");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sd);

        // Enter 8
        SW[3:0] = 4'b1000;
        #10;
        $display("8 entered, go to State E");
        stateErrorCheck(lab3_top_tb.DUT.state, `Se);

        // Enter 2
        SW[3:0] = 4'b0010;
        #10;
        $display("2 entered, go to State F");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sf);

        // Enter 8
        SW[3:0] = 4'b1000;
        #10;
        $display("8 entered, go to State G");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sg);
        #10;

        // Enter 8
        SW[3:0] = 4'b1000;
        #10;
        $display("In Stage G, 8 entered, remain in State G");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sg);
        #10;

        // Enter 5
        SW[3:0] = 4'b0101;
        #10;
        $display("In Stage G, 5 entered, remain in State G");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sg);
        #10;

        // Reset
        SW[3:0] = 4'b0000;
        KEY[3] = 1'b0;
        #10;
        $display("Reset hit, go to State A");
        stateErrorCheck(lab3_top_tb.DUT.state, `Sa);
        KEY[3] = 1'b1;

        // check to see if there is an error at the end, if so, display an error message
        if(err == 1) begin
            $display("Test case 3: FAIL");
        end else begin
            $display("Test case 3: PASS");
        end
        $stop;

    end
endmodule