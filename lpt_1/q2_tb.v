`define Sa 2'b00
`define Sb 2'b01
`define Sc 2'b10
`define Sd 2'b11

module q2_tb;
    reg in, clk, reset, err;
    reg [1:0] state;
    wire [2:0] out;

    MealyDec dut(state, in, out);

    task my_checker;
        input [2:0] expected_out;
        begin
            if (q2_tb.dut.out !== expected_out) begin
                $display("ERROR ** out is %b, expected %b", q2_tb.dut.out, expected_out);
                err = 1'b1;
            end
        end
    endtask

    initial begin
        clk = 1'b0; #5;
        forever begin
            clk = 1'b1; #5;
            clk = 1'b0; #5;
        end
    end

    initial begin
        err = 1'b0;
        state = `Sa; 
        in = 1'b0; #10;
        my_checker(3'b111);
        in = 1'b1; #10;
        my_checker(3'b101);

        state = `Sb;
        in = 1'b0; #10;
        my_checker(3'b001);
        in = 1'b1; #10;
        my_checker(3'b011);

        state = `Sc;
        in = 1'b0; #10;
        my_checker(3'b000);
        in = 1'b1; #10;
        my_checker(3'b100);

        state = `Sd;
        in = 1'b0; #10;
        my_checker(3'b110);
        in = 1'b1; #10;
        my_checker(3'b110);

        if (~err) $display("PASSED");
        else $display("FAILED");
        $stop;
    end
endmodule
