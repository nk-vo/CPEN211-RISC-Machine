`define ADD         2'b00
`define SUB         2'b01
`define AND         2'b10
`define COMPLEMENT  2'b11
`define undefine    {16{1'bx}}
`define zero        {16{1'b0}}


module ALU_tb;
    reg [15:0] Ain, Bin;
    reg [1:0] ALUop;
    wire [15:0] out;
    wire [2:0] Z;
    reg err, clk;

    ALU DUT(Ain, Bin, ALUop, out, Z);

    task my_checker;
        input [15:0] expected_out;
        input [2:0] expected_Z;
    begin
        if (ALU_tb.DUT.out !== expected_out) begin
            $display("ERROR ** output is %b, expected %b", ALU_tb.DUT.out, expected_out);
            err = 1'b1;
        end
        if (ALU_tb.DUT.Z !== expected_Z) begin
            $display("ERROR ** Z is %b, expected %b", ALU_tb.DUT.Z, expected_Z);
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
        $display("checking add");
        Ain = 16'd109; Bin = 16'd91; ALUop = `ADD;
        err = 1'b0; #10;
        my_checker(Ain + Bin, 3'b000);

        $display("checking substract > 0");
        Ain = 16'd109; Bin = 16'd9; ALUop = `SUB; #10;
        my_checker(Ain - Bin, 3'b000);
        
        $display("checking substract = 0");
        Ain = 16'd109; Bin = 16'd109; ALUop = `SUB; #10;
        my_checker(Ain - Bin, 3'b001);

        $display("checking substract < 0");
        Ain = 16'd9; Bin = 16'd10; ALUop = `SUB; #10;
        my_checker(Ain - Bin, 3'b100);

        // AND two same values
        $display("checking AND same values");
        Ain = 16'd109; Bin = 16'd109; ALUop = `AND; #10;
        my_checker(Ain & Bin, 3'b000);

        // AND two different values
        $display("checking AND different values");
        Ain = 16'd109; Bin = 16'd91; #10; ALUop = `AND; #10;
        my_checker(Ain & Bin, 3'b000);

        $display("checking AND opposite values");
        Ain = 16'd109; Bin = ~Ain; #10; ALUop = `AND; #10;
        my_checker(Ain & Bin, 3'b001);

        $display("checking complement Bin");
        Ain = 16'd109; Bin = 16'd91; #10; ALUop = `COMPLEMENT; #10;
        my_checker(~Bin, 3'b100);

        $display("checking complement Bin thats equal 0");
        Ain = 16'd109; Bin = 16'd65535; ALUop = `COMPLEMENT; #10;
        my_checker(~Bin, 3'b001);

    if (~err) $display("PASSED");
        else $display("FAILED");
        $stop;
    end
endmodule