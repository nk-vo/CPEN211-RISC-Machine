// test data
`define test_data0 16'd64382
`define test_data1 16'd34797
`define test_data2 16'd41685
`define test_data3 16'd49587
`define test_data4 16'd53663
`define test_data5 16'd61338
`define test_data6 16'd26990
`define test_data7 16'd23849
// register addresses
`define R0_addr 3'd0
`define R1_addr 3'd1
`define R2_addr 3'd2
`define R3_addr 3'd3
`define R4_addr 3'd4
`define R5_addr 3'd5
`define R6_addr 3'd6
`define R7_addr 3'd7

module regfile_tb;
    reg [15:0] data_in;
    reg [2:0] writenum, readnum;
    wire [15:0] data_out;
    reg clk, err, write;

    regfile DUT(data_in,writenum,write,readnum,clk,data_out);

    wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
	assign R0 = DUT.R0; assign R1 = DUT.R1;
	assign R2 = DUT.R2; assign R3 = DUT.R3;
	assign R4 = DUT.R4; assign R5 = DUT.R5;
	assign R6 = DUT.R6; assign R7 = DUT.R7;

    // check if register has the correct data at the correct stage
    task checker_true;
        input [15:0] data1, data2;
        begin
            if (data1 !== data2) begin
                $display("ERROR ** %b shouldn be equal to %b at this stage", data1, data2);
                err = 1'b1;
            end
        end
    endtask
    task checker_false;
        input [15:0] data1, data2;
        begin
            if (data1 == data2) begin
                $display("ERROR ** %b shouldn't be equal to %b at this stage", data1, data2);
                err = 1'b1;
            end
        end
    endtask

    // write data into register with write = 1
    task write_true;
        input [2:0] addr;
        input [15:0] in;
        begin
            data_in = in; writenum = addr; write = 1'b1; #10; write = 1'b0;
        end
    endtask

    // try to write data into register without setting write = 1
    task write_false;
        input [2:0] addr;
        input [15:0] in;
        begin
            data_in = in; writenum = addr; #10;
        end
    endtask

    // check register read
    task reg_read;
        input [2:0] addr;
        input [15:0] expected_data;
        begin
            readnum = addr; #1;
            if (data_out !== expected_data) begin
                $display("ERROR*** - R%d doesn't update on time", addr);
                err = 1'b1;
            end
            #9; checker_true(data_out, expected_data);
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
        err = 1'b0; #10;

        $display("False write test");
        write_false(`R0_addr, `test_data0); write_false(`R1_addr, `test_data1);
        write_false(`R2_addr, `test_data2); write_false(`R3_addr, `test_data3);
        write_false(`R4_addr, `test_data4); write_false(`R5_addr, `test_data5);
        write_false(`R6_addr, `test_data6); write_false(`R7_addr, `test_data7);

        checker_false(R0, `test_data0); checker_false(R1, `test_data1);
        checker_false(R2, `test_data2); checker_false(R3, `test_data3);
        checker_false(R4, `test_data4); checker_false(R5, `test_data5);
        checker_false(R6, `test_data6); checker_false(R7, `test_data7);

        $display("Correct write test");
        write_true(`R0_addr, `test_data0); write_true(`R1_addr, `test_data1);
        write_true(`R2_addr, `test_data2); write_true(`R3_addr, `test_data3);
        write_true(`R4_addr, `test_data4); write_true(`R5_addr, `test_data5);
        write_true(`R6_addr, `test_data6); write_true(`R7_addr, `test_data7);

        checker_true(R0, `test_data0); checker_true(R1, `test_data1);
        checker_true(R2, `test_data2); checker_true(R3, `test_data3);
        checker_true(R4, `test_data4); checker_true(R5, `test_data5);
        checker_true(R6, `test_data6); checker_true(R7, `test_data7);

        $display("Read register");
        reg_read(`R0_addr, `test_data0); reg_read(`R1_addr, `test_data1);
        reg_read(`R2_addr, `test_data2); reg_read(`R3_addr, `test_data3);
        reg_read(`R4_addr, `test_data4); reg_read(`R5_addr, `test_data5);
        reg_read(`R6_addr, `test_data6); reg_read(`R7_addr, `test_data7);

        $display("Overwrite test");
        write_true(`R0_addr, `test_data6); write_true(`R1_addr, `test_data7);
        write_true(`R2_addr, `test_data4); write_true(`R3_addr, `test_data5);
        write_true(`R4_addr, `test_data2); write_true(`R5_addr, `test_data3);
        write_true(`R6_addr, `test_data0); write_true(`R7_addr, `test_data1);

        checker_true(R0, `test_data6); checker_true(R1, `test_data7);
        checker_true(R2, `test_data4); checker_true(R3, `test_data5);
        checker_true(R4, `test_data2); checker_true(R5, `test_data3);
        checker_true(R6, `test_data0); checker_true(R7, `test_data1);

        reg_read(`R0_addr, `test_data6); reg_read(`R1_addr, `test_data7);
        reg_read(`R2_addr, `test_data4); reg_read(`R3_addr, `test_data5);
        reg_read(`R4_addr, `test_data2); reg_read(`R5_addr, `test_data3);
        reg_read(`R6_addr, `test_data0); reg_read(`R7_addr, `test_data1);

        #90; // keep running time to 500ms
    if (~err) $display("PASSED");
        else $display("FAILED");
        $stop;
    end
endmodule