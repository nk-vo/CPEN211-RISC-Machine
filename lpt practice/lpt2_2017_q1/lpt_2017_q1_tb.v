`define Sa 3'b000
`define Sb 3'b001
`define Sc 3'b010
`define Sd 3'b011
`define Se 3'b100
module q1_tb;
    reg [1:0] in;
    wire [1:0] out;

    reg clk, reset, err;

    top_module dut(clk, reset, in, out);
    task my_checker;
        input [2:0] expected_state;
        input [1:0] expected_out;
        begin
            if (q1_tb.dut.present_state !== expected_state) begin
                $display("ERROR ** state is %b, expected %b", q1_tb.dut.present_state, expected_state);
                err = 1'b1;
            end
            if (q1_tb.dut.out !== expected_out) begin
                $display("ERROR ** out is %b, expected %b", q1_tb.dut.out, expected_out);
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
        $display("checking reset");
        reset = 1'b1; in = 2'b10; err = 1'b0; #10;
        my_checker(`Sa, 2'b01);
        reset = 1'b0;  // release reset

        $display("Sa->Sb");
        in = 2'b11; #10;
        my_checker(`Sb, 2'b11);

        $display("Sb->Se");
        in = 2'b01; #10;
        my_checker(`Se, 2'b00);

        $display("Se->Sd");
        in = 2'b00; #10;
        my_checker(`Sd, 2'b11);

        $display("Sd->Sc");
        #10;
        my_checker(`Sc, 2'b10);

        $display("Sc->Sd");
        in = 2'b10; #10;
        my_checker(`Sd, 2'b11);

        reset = 1'b1; #10; reset = 1'b0;
        $display("Sa->Sc->Sb"); 
        in = 2'b00; #10; in = 2'b01; #10;
        my_checker(`Sb, 2'b11);
        
        reset = 1'b1; #10; reset = 1'b0;
        $display("Sa->Sc->Se");
        in = 2'b00; #10; in = 2'b11; #10;
        my_checker(`Se, 2'b00);

        if (~err) $display("PASSED");
        else $display("FAILED");
        $stop;
    end
endmodule