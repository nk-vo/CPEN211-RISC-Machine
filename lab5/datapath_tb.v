`define DELAY 10
// ALU command
`define ADD 2'b00
`define SUB 2'b01
`define AND 2'b10
`define COMPLEMENT_B 2'b11

// shifter command
`define NO_SHIFT    2'b00
`define SHIFT_LEFT  2'b01
`define SHIFT_RIGHT 2'b10
`define SHIFT_RIGHT_MSB_15 2'b11

// register addresses
`define R0_addr 3'd0
`define R1_addr 3'd1
`define R2_addr 3'd2
`define R3_addr 3'd3
`define R4_addr 3'd4
`define R5_addr 3'd5
`define R6_addr 3'd6
`define R7_addr 3'd7

module datapath_tb;
	reg clk, write, loada, loadb, loadc, loads, asel, bsel, vsel, err;
	reg [1:0] shift, ALUop;
	reg [2:0] readnum, writenum;
	reg [15:0] datapath_in;

	wire Z_out;
	wire [15:0] datapath_out;

	datapath DUT(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, 
	            loadc, loads, writenum, write, datapath_in, Z_out, datapath_out );

	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
	assign R0 = DUT.REGFILE.R0; assign R1 = DUT.REGFILE.R1;
	assign R2 = DUT.REGFILE.R2; assign R3 = DUT.REGFILE.R3;
	assign R4 = DUT.REGFILE.R4; assign R5 = DUT.REGFILE.R5;
	assign R6 = DUT.REGFILE.R6; assign R7 = DUT.REGFILE.R7;

    initial begin
		clk = 0; #(`DELAY);
		forever begin
			clk = 1; #(`DELAY);
			clk = 0; #(`DELAY);
		end
	end

    task my_checker;
        input [15:0] data, expected_data;
        begin
            if (data !== expected_data) begin
                $display("ERROR*** %b do not match %b", data, expected_data);
                err = 1'b1;
            end
        end
    endtask

    task MOV;
        input [2:0] addr;
        input [15:0] data;
        input write_back;
        begin
            vsel = ~write_back;
            if (vsel == 1) datapath_in = data;
            writenum = addr; write = 1;
            #(`DELAY * 2);
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
        input [2:0] dest_addr, first_addr, second_addr;
        input [1:0] shift_code;
        begin
            // load A and B registers
            loada = 1; readnum = first_addr; #(`DELAY * 2);
            loada = 0;
            loadb = 1; readnum = second_addr; #(`DELAY * 2);
            loadb = 0;
            shift = shift_code;
            asel = 0; bsel = 0; ALUop = `SUB; // adding 2 values
            loadc = 1; #(`DELAY * 2);
            loadc = 0;
            MOV(dest_addr, datapath_out, 1);
        end
    endtask

    task AND;
        input [2:0] dest_addr, first_addr, second_addr;
        input [1:0] shift_code;
        begin
            // load A and B registers
            loada = 1; readnum = first_addr; #10; loada = 0; // load A_reg
            loadb = 1; readnum = second_addr; #10; loadb = 0; // load B_reg
            shift = shift_code;
            asel = 0; bsel = 0; ALUop = `AND; // AND-ing 2 values
            loadc = 1; #10; loadc = 0; // store result in register
            MOV(dest_addr, datapath_out, 1);
        end
    endtask

    task COMPLEMENT;
        input [2:0] dest_addr, oprand_1_addr;
        begin
            // load B registers
            loadb = 1; readnum = oprand_1_addr; #(`DELAY*2); // wait 1 clock cycle
			loadb = 0; 
			shift = `NO_SHIFT; // compute shift (assume no delay)
			asel = 1; bsel = 0; ALUop = `COMPLEMENT_B; // at this point the ALU has computed complement
			loadc = 1; #(`DELAY*2); // store the result in the register and wait 1 cycle;
			loadc = 0;
			MOV(dest_addr, datapath_out, 1); // store the contents in the destination address - 1 CYCLE
        end
    endtask

    initial begin
		err = 0; #5;
    
        $display("MOV R0, #7");
        MOV(`R0_addr, 16'd7, 0);
        my_checker(R0, 16'd7);

        $display("MOV R1, #2");
        MOV(`R1_addr, 16'd2, 0);
        my_checker(R1, 16'd2);

        $display("ADD R2, R1, R0, LSL#1");
        ADD(`R2_addr, `R1_addr, `R0_addr, `SHIFT_LEFT);
        my_checker(R2, 16'd16);
        my_checker(Z_out, 2'b0);
        
        $display("MOV R3, #72");
        MOV(`R3_addr, 16'd72, 0);
        my_checker(R3, 16'd72);

        $display("MOV R4, #22");
        MOV(`R4_addr, 16'd22, 0);
        my_checker(R4, 16'd22);

        $display("SUB R5, R4, R3, LSR#1");
        SUB(`R5_addr, `R4_addr, `R3_addr, `SHIFT_RIGHT);
        my_checker(R5, 16'd61);

        $display("MOV R6, #0");
        MOV(`R6_addr, 16'd0, 0);
        my_checker(R6, 16'd0);

        $display("COMPLEMENT R6");
        COMPLEMENT(`R7_addr, `R6_addr);
        my_checker(R7, ~R6);

        if (~err) $display("PASSED");
        else $display("FAILED");
        $stop;
    end
endmodule