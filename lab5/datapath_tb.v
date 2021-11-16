`define WORD_SIZE 16
`define DELAY 10

//****************************REGISTER ADDRESSES****************************//
`define R0_ADDR 3'd0
`define R1_ADDR 3'd1
`define R2_ADDR 3'd2
`define R3_ADDR 3'd3
`define R4_ADDR 3'd4
`define R5_ADDR 3'd5
`define R6_ADDR 3'd6
`define R7_ADDR 3'd7

//****************************SHIFT OP CODES****************************//
`define NO_SHIFT 2'b00
`define SHIFT_LEFT 2'b01
`define SHIFT_RIGHT 2'b10
`define SHIFT_RIGHT_AND_COPY_MSB_15 2'b11

//****************************ALU OP CODES****************************//
`define ADD 2'b00
`define SUBTRACT 2'b01
`define AND 2'b10
`define COMPLEMENT_B 2'b11

// datapath test bench
module datapath_tb ();
	
	// I/O Declarations
	reg clk, write, loada, loadb, loadc, loads, asel, bsel, vsel, err;
	reg [1:0] shift, ALUop;
	reg [2:0] readnum, writenum;
	reg [`WORD_SIZE-1:0] datapath_in;

	wire Z_out;
	wire [`WORD_SIZE-1:0] datapath_out;

	datapath DUT ( clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, 
	loadc, loads, writenum, write, datapath_in, Z_out, datapath_out );

	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
	assign R0 = DUT.REGFILE.R0; assign R1 = DUT.REGFILE.R1;
	assign R2 = DUT.REGFILE.R2; assign R3 = DUT.REGFILE.R3;
	assign R4 = DUT.REGFILE.R4; assign R5 = DUT.REGFILE.R5;
	assign R6 = DUT.REGFILE.R6; assign R7 = DUT.REGFILE.R7;

	//***************************CLOCK*****************************//
	initial begin
		// clock is intially low
		clk = 0; #(`DELAY);
		forever begin
			clk = 1; #(`DELAY);
			clk = 0; #(`DELAY);
		end
	end

	//***************************ASSERT TASK*****************************//
	task assert;
		input [15:0] data;
		input [15:0] expected_data;
		begin
			if (data !== expected_data) begin
				$display("^^^[FAIL_ASSERT] data: %b, expected_data: %b", data, expected_data);
				err = 1'b1;
			end
			else
				$display("***[PASS_ASSERT] data: %b, expected_data: %b", data, expected_data);
		end
	endtask

	//***************************INSTRUCTIONS*****************************//
	task MOV;
		input [2:0] register_addr;
		input [`WORD_SIZE-1:0] data;
		input write_back;
		begin
			vsel = ~write_back;
			if (vsel == 1) datapath_in = data; // only write to datapath_in when vsel is 1
			writenum = register_addr; write = 1; 
			#(`DELAY*2);
			write = 0; vsel = 0;
		end
	endtask

	task ADD;
		input [2:0] dest_addr; // destination address
		input [2:0] oprand_1_addr;
		input [2:0] oprand_2_addr; // connected to shifter
		input [1:0] shift_op_code;
		begin
			// we must first load both A & B registers (B connected to shifter)
			loada = 1; readnum = oprand_1_addr; #(`DELAY*2); // wait 1 clock cycle
			loada = 0; 
			loadb = 1; readnum = oprand_2_addr; #(`DELAY*2); // wait 1 clock cycle
			loadb = 0; 
			shift = shift_op_code; // compute shift (assume no delay)
			asel = 0; bsel = 0; ALUop = `ADD; // at this point the ALU has computed the addition
			loadc = 1; #(`DELAY*2); // store the result in the register and wait 1 cycle;
			loadc = 0;
			MOV(dest_addr, datapath_out, 1); // store the contents in the destination address - 1 CYCLE
		end
	endtask

	task SUB;
		input [2:0] dest_addr; // destination address
		input [2:0] oprand_1_addr;
		input [2:0] oprand_2_addr; // connected to shifter
		input [1:0] shift_op_code;
		begin
			// we must first load both A & B registers (B connected to shifter)
			loada = 1; readnum = oprand_1_addr; #(`DELAY*2); // wait 1 clock cycle
			loada = 0; 
			loadb = 1; readnum = oprand_2_addr; #(`DELAY*2); // wait 1 clock cycle
			loadb = 0; 
			shift = shift_op_code; // compute shift (assume no delay)
			asel = 0; bsel = 0; ALUop = `SUBTRACT; // at this point the ALU has computed the addition
			loadc = 1; #(`DELAY*2); // store the result in the register and wait 1 cycle;
			loadc = 0;
			MOV(dest_addr, datapath_out, 1); // store the contents in the destination address - 1 CYCLE
		end
	endtask

	task COMPLEMENT;
		input [2:0] dest_addr; // destination address
		input [2:0] oprand_1_addr;
		begin
			// we must first load register B
			loadb = 1; readnum = oprand_1_addr; #(`DELAY*2); // wait 1 clock cycle
			loadb = 0; 
			shift = `NO_SHIFT; // compute shift (assume no delay)
			asel = 1; bsel = 0; ALUop = `COMPLEMENT_B; // at this point the ALU has computed complement
			loadc = 1; #(`DELAY*2); // store the result in the register and wait 1 cycle;
			loadc = 0;
			MOV(dest_addr, datapath_out, 1); // store the contents in the destination address - 1 CYCLE
		end
	endtask


	//***************************TEST CASES*****************************//

	//*********************RISING EDGE TEST CASE***********************//
	always @({R0, R1, R2, R3, R4, R5, R6, R7}) begin
		if(clk != 1) begin
			$display("^^^[ERROR_RIS_EDGE] - A Register was updated on the during a low cycle.");
			err = 1;
		end
	end
	
	initial begin
		// error is intially zero
		err = 0;

		// initial delay before clock goes high
		// This means any instruction run below will happen just before a clk rising edge
		#(`DELAY * 0.5); 

		// TEST 1: MOV R0, #7 - 1 CYCLE
		// Expected Behaviour: Take the number 7, and store in R0
		MOV(`R0_ADDR, 16'd7, 0);
		assert(R0, 16'd7);

		// TEST 2: MOV R1, #2 - 1 CYCLE
		// Expected Behaviour: Take the number 2, and store in R1
		MOV(`R1_ADDR, 16'd2, 0);
		assert(R1, 16'd2);

		// TEST 3: ADD R2, R1, R0, LSL#1 - 4 CYCLES
		// Expected Behaviour: Add R1 and R0 (shifted by 1).  store in R2
		// Expected Output: R2 == (2 + 14 = 16)
		ADD(`R2_ADDR, `R1_ADDR, `R0_ADDR, `SHIFT_LEFT);
		assert(R2, 16'd16);

		// TEST 4: MOV R3, #27000 - 1 CYCLE
		// Expected Behaviour: Take the number 27000, and store in R3
		MOV(`R3_ADDR, 16'd27000, 0);
		assert(R3, 16'd27000);

		// TEST 5: MOV R4, #20000 - 1 CYCLE
		// Expected Behaviour: Take the number 20000, and store in R4
		MOV(`R4_ADDR, 16'd20000, 0);
		assert(R4, 16'd20000);

		// TEST 6: SUB R5, R3, R4 -  4 CYCLES
		// Expected Behaviour: Subtract R3 - R4 = 7000.  store in R5
		// Expected Output: R5 == (27000 - 20000 = 7000)
		SUB(`R5_ADDR, `R3_ADDR, `R4_ADDR, `NO_SHIFT);
		assert(R5, 16'd7000);

		// TEST 7: MOV R6, #0 - 1 CYCLE
		// Expected Behaviour: Take the number 0, and store in R6
		MOV(`R6_ADDR, 16'd0, 0);
		assert(R6, 16'd0);

		// TEST 8: COMPLEMENT R6, Store R7 - 4 CYCLE
		// Expected Behaviour: Complement 0, and store in R7
		COMPLEMENT(`R7_ADDR, `R6_ADDR);
		assert(R7, ~(R6));


		if (~err) $display("\nPASSED ALL TESTS :)\n");
		else $display("\nFAILED A TEST :(\n");
		//$stop; // --> NOTE: comment out stop when running lab checks 3 and 4
	end


endmodule