module cpu_tb;
    reg clk, reset, s, load, err;
    reg [15:0] in;
    wire [15:0] out;
    wire N,V,Z,w;

    cpu DUT(clk,reset,s,load,in,out,N,V,Z,w);

    wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
	assign R0 = DUT.DP.REGFILE.R0; assign R1 = DUT.DP.REGFILE.R1;
	assign R2 = DUT.DP.REGFILE.R2; assign R3 = DUT.DP.REGFILE.R3;
	assign R4 = DUT.DP.REGFILE.R4; assign R5 = DUT.DP.REGFILE.R5;
	assign R6 = DUT.DP.REGFILE.R6; assign R7 = DUT.DP.REGFILE.R7;

    task check_reg;
        input [15:0] data, expected_data;
        begin
            if (data !== expected_data) begin
                $display("ERROR*** Register data is: %b, expected: %b", data, expected_data);
                err = 1'b1;
            end
        end
    endtask
    task check_out;
        input [15:0] out, expected_out;
        begin
            if (out !== expected_out) begin
                $display("ERROR*** Output is: %b, expected: %b", out, expected_out);
                err = 1'b1;
            end
        end
    endtask
    task check_status;
        input N, expected_N, V, expected_V, Z, expected_Z;
        begin
            if (N !== expected_N) begin
                $display("ERROR*** N is: %b, expected: %b", N, expected_N);
                err = 1'b1;
            end
            if (V !== expected_V) begin
                $display("ERROR*** V is: %b, expected: %b", V, expected_V);
                err = 1'b1;
            end
            if (N !== expected_N) begin
                $display("ERROR*** Z is: %b, expected: %b", Z, expected_Z);
                err = 1'b1;
            end
        end
    endtask
    task check_w;
        input w, expected_w;
        begin
            if (w !== expected_w) begin
                $display("ERROR*** w is: %b, expected: %b", w, expected_w);
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
        err = 0;
        $display("check reset");
        reset = 1; s = 0; load = 0; in = 16'b0; 
        #10; check_w(w, 1);

        $display("MOV R0, #6");
        reset = 0; load = 1; in = 16'b110_10_000_0000_0110; // WriteImm with opcode = 3'b110, op = 2'b10, Rm = 2'b110 or 2'd6
        #10; load = 0; s = 1; 
        #10; s = 0; check_w(w, 0);		//should not be in waiting state
        #10; check_w(w, 1); check_reg(R0, 16'b110); //check if R0 has correct value and if back to wait state

        $display("MOV R1, R0, LSL #1");
        load = 1; in = 16'b110_00_000_001_01_000;	//WriteReg with opcode = 3'b110, op = 2'b00, shift = 2'b01, Rd = 3'b001, Rn = 3'b000
        #10; load = 0; s = 1;
        #10; s = 0; check_w(w, 0);	//no longer waiting
        #30; //time needed to pass through all states for this instruction
        check_w(w, 1); check_reg(R1, 16'b1100);	//check if R1 has correct value
        
        $display("ADD R2, R0, R1");
        load = 1; in = 16'b101_00_000_010_00_001; //GetA, GetB, Operate, WriteReg with opcode = 3'b101, op = 2'b00, Rm = 2'b001, Rd = 3'b010, Rn = 3'b000 
        #10; load = 0; s = 1;
        #10; s = 0; check_w(w,0);
        #40; //4 more states to iterate through
        check_w(w, 1); check_reg(R2, 16'b10010);

        $display("CMP R0, R1");
        load = 1; in = 16'b101_01_000_000_00_001;	//GetA, Sub with opcode = 3'b101, op = 2'b01, Rd = 3'b000, Rm = 3'b001
        #10; load = 0; s = 1;
        #10; s = 0; check_w(w,0);
        #30; //3 more states to iterate through
        check_w(w,1); check_status(N,1,V,0,Z,0); //wait state, status should indicate negative ALU output

        $display("CMP R1, R0, LSL #1");
        load = 1; in = 16'b101_01_001_000_01_000;	//GetA, GetB, Sub with opcode = 3'b101, op = 2'b01, shift = 2'b01, Rd = 3'b001, Rm = 3'b000
        #10; load = 0; s = 1;
        #10; s = 0; check_w(w,0);
        #30; //3 more states to iterate through
        check_w(w,1); check_status(N,0,V,0,Z,1); //wait state, check for zero ALU output

        $display("AND R3, R0, R1");
        load = 1; in = 16'b101_10_000_011_00_001;   //GetA, GetB, Operate with opcode = 3'b101, op = 2'b10, Rm = 3'b001, Rd = 3'b011, Rn = 3'b000
        #10; load = 0; s = 1;
        #10; s = 1; check_w(w,0);
        #40; //iterate back to wait
        check_w(w,1); check_reg(R3, 16'b100);

        $display("MVN R4, R0, LSR #1");
        load = 1; in = 16'b101_11_000_100_10_000;   //GetB, Operate with opcode = 3'b101, op = 2'b11, Rm = 3'b000, Rd = 3'b100, shift = 2'b10
        #10; load = 0; s = 1;
        #10; s = 1; check_w(w,0);
        #30; //iterate back to wait
        check_w(w,1); check_reg(R4, 16'b1111_1111_1111_1100);
        #30;	//just so we can see the updated register 4 on the waveform

        //both move instructions and all 4 ALU instructions have been tested
        if( ~err ) $display("PASSED");
            else $display("FAILED");
        $stop;
    end
endmodule