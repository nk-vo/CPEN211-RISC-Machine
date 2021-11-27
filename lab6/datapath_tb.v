// registers
`define R0_addr 3'd0
`define R1_addr 3'd1
`define R2_addr 3'd2
`define R3_addr 3'd3
`define R4_addr 3'd4
`define R5_addr 3'd5
`define R6_addr 3'd6
`define R7_addr 3'd7

// shifter op codes
`define NO_SHIFT 2'b00
`define SHIFT_LEFT 2'b01
`define SHIFT_RIGHT 2'b10
`define SHIFT_RIGHT_MSB_15 2'b11

// ALU op codes
`define ADD          2'b00
`define SUBTRACT     2'b01
`define AND          2'b10
`define COMPLEMENT_B 2'b11

module datapath_tb;
	reg clk, write, loada, loadb, loadc, loads, asel, bsel, err;
	reg [1:0] shift, ALUop, vsel;
	reg [2:0] readnum, writenum;
	reg [15:0] mdata, sximm8, sximm5, PC;

	wire [2:0] Z_out;
	wire [15:0] C;

	datapath DUT(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, 
                loadc, loads, writenum, write, mdata, sximm8, PC, sximm5, Z_out, C);

	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
	assign R0 = DUT.REGFILE.R0; assign R1 = DUT.REGFILE.R1;
	assign R2 = DUT.REGFILE.R2; assign R3 = DUT.REGFILE.R3;
	assign R4 = DUT.REGFILE.R4; assign R5 = DUT.REGFILE.R5;
	assign R6 = DUT.REGFILE.R6; assign R7 = DUT.REGFILE.R7;

	task checker;
		input [15:0] data;
		input [15:0] expected_data;
		begin
			if (data !== expected_data) begin
				$display("ERROR*** data: %b, expected_data: %b", data, expected_data);
				err = 1'b1;
			end
            else $display("PASSED TEST");
		end
	endtask

	task MOV;
		input [2:0] dest_addr;
		input [15:0] data;
		input [1:0] sel;
		begin
			vsel = sel;
			if (vsel == 2'b10) sximm8 = data;  // only write to mdata when vsel is 2'b00
			
			writenum = dest_addr; write = 1; 
			#10;
			write = 0; vsel = 0;
		end
	endtask

	task ADD;
		input [2:0] dest_addr, first_addr, second_addr;
		input [1:0] shift_code;
		begin
			// load A and B registers
			loada = 1; readnum = first_addr; #10; // load A and wait 1 clock cycle
			loada = 0; 
			loadb = 1; readnum = second_addr; #10; // load B and wait 1 clock cycle
			loadb = 0; 
			shift = shift_code; // shift input
			asel = 0; bsel = 0; ALUop = `ADD;
			loadc = 1; #10; // store the result in the register and wait 1 cycle;
			loadc = 0;
			MOV(dest_addr, C, 2'b00); // store the contents in the destination address and wait 1 CYCLE
		end
	endtask

	task SUB;
		input [2:0] dest_addr, first_addr, second_addr;
		input [1:0] shift_code;
		begin
			// we must first load both A & B registers (B connected to shifter)
			loada = 1; readnum = first_addr; #10; // wait 1 clock cycle
			loada = 0; 
			loadb = 1; readnum = second_addr; #10; // wait 1 clock cycle
			loadb = 0; 
			shift = shift_code; // compute shift (assume no delay)
			asel = 0; bsel = 0; ALUop = `SUBTRACT; // at this point the ALU has computed the addition
			loadc = 1; #10; // store the result in the register and wait 1 cycle;
			loadc = 0;
			MOV(dest_addr, C, 2'b00); // store the contents in the destination address - 1 CYCLE
		end
	endtask

	task COMPLEMENT;
		input [2:0] dest_addr, first_addr;
        input [1:0] shift_code;
		begin
			// we must first load register B
			loadb = 1; readnum = first_addr; #10; // wait 1 clock cycle
			loadb = 0; 
			shift = shift_code; // compute shift (assume no delay)
			asel = 1; bsel = 0; ALUop = `COMPLEMENT_B; // at this point the ALU has computed complement
			loadc = 1; #10; // store the result in the register and wait 1 cycle;
			loadc = 0;
			MOV(dest_addr, C, 2'b00); // store the contents in the destination address - 1 CYCLE
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
		err = 0; #10; 

		$display("MOV R0, #7");
		MOV(`R0_addr, 16'd7, 2'b10);
		checker(R0, 16'd7);

		$display("MOV R1, #2");
		MOV(`R1_addr, 16'd2, 2'b10);
		checker(R1, 16'd2);

		$display("ADD R2, R1, R0, LSL#1");
		ADD(`R2_addr, `R1_addr, `R0_addr, `SHIFT_LEFT);
		checker(R2, 16'd16);

		$display("MOV R3, #27653");
		MOV(`R3_addr, 16'd27653, 2'b10);
		checker(R3, 16'd27653);

		$display("MOV R4, #7653");
		MOV(`R4_addr, 16'd7653, 2'b10);
		checker(R4, 16'd7653);

		$display("SUB R5, R3, R4");
		SUB(`R5_addr, `R3_addr, `R4_addr, `NO_SHIFT);
		checker(R5, 16'd20000);

		$display("MOV R6, #0");
		MOV(`R6_addr, 16'd0, 2'b10);
		checker(R6, 16'd0);

		$display("COMPLEMENT R6, Store R7");
		COMPLEMENT(`R7_addr, `R6_addr, `NO_SHIFT);
		checker(R7, ~(R6));

		if (~err) $display("PASSED ALL TESTS");
		else $display("FAILED");
		$stop;
    end
endmodule