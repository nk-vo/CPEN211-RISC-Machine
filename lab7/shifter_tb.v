module shifter_tb;
    reg [15:0] in;
    reg [1:0] shift;
    wire [15:0] sout;
    reg clk, err;

    shifter DUT(in, shift, sout);

    task my_checker;
        input [15:0] expected_sout;
    begin
        if (shifter_tb.DUT.sout !== expected_sout) begin
            $display("ERROR ** output is %b, expected %b", shifter_tb.DUT.sout, expected_sout);
            err = 1'b1;
        end
    end
    endtask

    initial begin
        clk = 0; #5;
        forever begin
            clk = 1; #5;
            clk = 0; #5;
        end
    end

    initial begin
        $display("checking do nothing");
        in = 16'd678; shift = 2'b00;
        err = 1'b0; #10;
        my_checker(in);

        $display("checking left shift");
        in = 16'd678; shift = 2'b01; #10;
        my_checker(in << 1);

        $display("checking right shift");
        in = 16'd678; shift = 2'b10; #10;
        my_checker(in >> 1);

        $display("checking right shift with MSB = in[15]");
        in = 16'd678; shift = 2'b11; #10;
        my_checker({in[15], in[15:1]});

    if (~err) $display("PASSED");
        else $display("FAILED");
        $stop;
    end
endmodule