module cpu(clk,reset,in,mdata,out,N,V,Z,w, mem_addr, mem_cmd);
//in and mdata should have the same input bus when cpu is instantiated
//in lab 7, out should be connected to write_data
//may need to remove: load
  input clk, reset;
  input [15:0] in, mdata;

  output [15:0] out;
  output N, V, Z, w;

  output [8:0] mem_addr;
  output [1:0] mem_cmd;

//instruction register to decoder wires
  wire [15:0] curr_instruct;

//decoder to FSM
  wire [2:0] opcode;
  wire [1:0] op;

//decoder to datapath
  wire [15:0] sximm5, sximm8;
  wire [2:0] readnum, writenum;
  wire [1:0] ALUop, shift;

//FSM to instruction register
  wire load_ir;

//FSM to decoder
  wire [2:0] nsel;

//FSM to datapath
  wire [1:0] vsel;
  wire write, loada, loadb, asel, bsel, loadc, loads;

//FSM to PC
  wire load_pc, reset_pc;

//FSM to DA
  wire load_addr, addr_sel;

//Datapath outputs
  wire [2:0] Z_out;
  wire [15:0] C;

//PC/DA multiplexer signals
  wire [8:0] PC, next_pc, da_out;

//pc signal, unused until lab 8
  wire [15:0] dp_pc;
  assign dp_pc = {7'b0, {PC[8:0]}};


//lab8 signals
  wire [2:0] cond;
  wire [8:0] sxim8;

//combinational logic to determine whether or not PC should skip forward by sxim8
  wire pc_offsetsel; //instead of having this as a multiplexer input, have it as an input to FSM so the FSM can decide whether to add 0 or sxim8 to PC
  wire B, BEQ, BNE, BLT, BLE, BL;// not_branch_instruct;
  assign B = ((cond == 3'b000) & (opcode == 3'b001));					//condition for B
  assign BEQ = ((cond == 3'b001) & (Z == 1'b1) & (opcode == 3'b001));			//condition for BEQ
  assign BNE = ((cond == 3'b010) & (Z == 1'b0) & (opcode == 3'b001));			//condition for BNE
  assign BLT = ((cond == 3'b011) & (N ^ V) & (opcode == 3'b001));			//condition for BLT
  assign BLE = ((cond == 3'b100) & ((N ^ V) | (Z == 1'b1)) & (opcode == 3'b001));	//condition for BLE
  assign BL = (({opcode, op} == 5'b01011));						//condition for BL

//this signal is necessary to:
//prevent pc_offsetsel from being undefined before NVZ flags are set
//  assign not_branch_instruct = ~((opcode == 3'b001) | (opcode == 3'b010));
  assign pc_offsetsel = (B | BEQ | BNE | BLT | BLE | BL);		//condition for any branch

//signals between pc multiplexers
  wire [8:0] pc_offset, pc_ret;
//new fsm signal to pc
  wire [2:0] pc_addsel; //selects whether to add 1(default), 0 (loop condition not true) or sxim8(loop condition true) to PC
  wire pc_returnsel; //selects whether to add to PC like normal, or to set it to something specified by Rd

  wire manualadd;
  wire [1:0] manualALUop;
  assign manualALUop = ((ALUop & {2{~manualadd}}) | (2'b00 & {2{manualadd}}));	//when in BLX instruct, op is 10 so we ovverride it to be 00 so the ALU performs needed add operation

instruction_register instruct_reg(clk, load_ir, in, curr_instruct);
fsm FSM(clk, reset, opcode, op, pc_offsetsel, vsel, nsel, write, loada, loadb, asel, bsel, loadc, loads, w, load_pc, reset_pc, addr_sel, load_ir, load_addr, mem_cmd, pc_returnsel, pc_addsel);
instruction_decoder instruct_dec(curr_instruct, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum, cond, sxim8, manualadd);
datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, manualALUop, loadc, loads, writenum, write, mdata, sximm8, dp_pc, sximm5, Z_out, C);

//Multiplexer selecting whether or not to add sxim8
Mux3 #(9) pc_mux_add(sxim8, 9'b0, 9'b1, pc_addsel, pc_offset);
//Multiplexer selecting whether or not to return to a memory location specified by the link register (end of a loop)
Mux2 #(9) pc_mux_return( C[8:0], (pc_offset + PC), pc_returnsel, pc_ret);
//Multiplexer leading into PC register selecting whether or not to reset
Mux2 #(9) pc_reset_mux(9'b0, pc_ret, reset_pc, next_pc);
//PC register
RLE #(9) pc(next_pc, load_pc, clk, PC);

//RLE #(9) pc(next_pc, load_pc, clk, PC);
//Mux2 #(9) pc_mux(9'b0, (PC + 1'b1), reset_pc, next_pc);

RLE #(9) da(C[8:0], load_addr, clk, da_out);
Mux2 #(9) mem_addr_mux(PC, da_out, addr_sel, mem_addr);

assign out = C;			//out is connected to C in the datapath
assign {N,V,Z} = Z_out;		//each bit of Z_out represents one of N V and Z

//assign mdata = 16'b0;		//mdata set to 0 for lab 6
//assign PC = 16'b0;		//PC set to 0 for lab 6
endmodule

//INSTRUCTION
//REGISTER
//MODULE
module instruction_register(clk, load, in, instruction);
  input [15:0] in;
  input clk, load;

  output [15:0] instruction;

  reg [15:0] current_instruction;

  always @(posedge clk) begin			//register the input instruction if load is on
	if(load == 1'b1)
	  current_instruction = in;
  end

  assign instruction = current_instruction;	//assign the instruction to the output
endmodule

//FSM
//MODULE
module fsm(clk, reset, opcode, op, pc_offsetsel, vsel, nsel, write, loada, loadb, asel, bsel, loadc, loads, w, load_pc, reset_pc, addr_sel, load_ir, load_addr, mem_cmd, pc_returnsel, pc_addsel);
  input clk, reset;
  input [2:0] opcode;
  input [1:0] op;
  input pc_offsetsel; //whether to set pc_addsel

  output [2:0] nsel;
  output [1:0] vsel;
  output write, loada, loadb, asel, bsel, loadc, loads, w;
  output load_pc, reset_pc, addr_sel, load_ir, load_addr;
  output [1:0] mem_cmd;

  output pc_returnsel;
  output [2:0] pc_addsel;

  reg [4:0] present_state;
  reg [2:0] nsel;
  reg [1:0] vsel;
  reg write, loada, loadb, asel, bsel, loadc, loads, w;
  reg load_pc, reset_pc, addr_sel, load_ir, load_addr;
  reg [1:0] mem_cmd;

  reg pc_returnsel;
  reg [2:0] pc_addsel;

  `define RST 5'b00000		//w is 1, here until s turns on, reset will lead to this state
  `define GetA 5'b00001		//read to register A, nsel=001
  `define GetB 5'b00010		//read to register B, nsel=100
  `define Pass 5'b00011		//asel/load c are 1, bsel 0, passes shifted B to C
  `define Sub 5'b00100		//loads is 1, load c is 0 so nothing is passed to C, asel/bsel are 0
  `define Operate 5'b00101	//load c is 1, asel/bsel are 0; result of an ALU operation is passed to C
  `define WriteReg 5'b00110	//write=1, nsel=010, vsel=00; writes C to a register
  `define WriteImm 5'b00111	//vsel=10, write=1, nsel=001; writes immediate input to a register
  `define AddImm5 5'b01000	//adds imm5 input to Ain and load it to C
  `define LoadAD 5'b01001	//sets memory address to be updated
  `define ReadMem 5'b01010	//reads from memory
  `define GetRd 5'b01011	//reads data stored in register Rd
  `define MemtoReg 5'b01100	//writes memory read data to a register
  `define PassRd 5'b01101	//Passes data from Rd to C without adding anything or shifting
  `define WriteMem 5'b01110	//writes to memory
  `define IF1 5'b01111		//First of instruction fetch states
  `define IF2 5'b10000		//second instruction fetch state, where dout is available
  `define UpdatePC 5'b10001	//updates program counter
  `define HALT 5'b10010		//needs to be reset from here
  `define MovePC 5'b10011	//decided whether to move PC to sxim8 or do nothing
  `define SetLinkReg 5'b10100	//sets link register to address to return to
  `define ReturnBranch 5'b10101 //returns to address passed out by datapath

  `define MNONE 2'b00		//no memory operation in progress
  `define MREAD 2'b01		//reading from memory [LDR]
  `define MWRITE 2'b10		//writing to memory [STR]

  always @(posedge clk) begin
	if(reset)
	  present_state = `RST ;		//if reset is on, revert to reset state
	else begin
	  case(present_state)			//logic based on current state
		`RST : present_state = `IF1 ;
		`UpdatePC : case(opcode)	//first look at opcode to determine instruction category
				3'b110: case(op)
					  2'b10: present_state = `WriteImm ;	//corresponds to the MOV Rn,#<im8> instruction
					  2'b00: present_state = `GetB ;	//first state in MOV Rd,Rm{,<sh_op>} 
					  default: present_state = 5'bxxxxx;
					endcase
				3'b101: case(op)
					  2'b11: present_state = `GetB ;	//MVN Rd,Rm{,<sh_op>} is the only ALU instruction where register A is not needed
					  2'b00, 2'b01, 2'b10: present_state = `GetA ;	//all other ALU instructions A must first be loaded
					  default: present_state = 5'bxxxxx;
					endcase
				3'b011, 3'b100: present_state = `GetA ; //memory instructions go to GetA
				3'b111: present_state = `HALT ; //code for halt instruction
				3'b001: present_state = `MovePC ; //branch instruct
				3'b010: if(op[1]) begin present_state = `SetLinkReg ; end //links register
					else begin present_state = `GetRd ; end //
				default: present_state = 5'bxxxxx;
			      endcase
		`GetA : case(opcode)
			  3'b011, 3'b100: present_state = `AddImm5 ; //state transitions to AddImm5 for memory operations
			  3'b101, 3'b110: present_state = `GetB ; //for operations from lab6
			  default: present_state = 5'bxxxxx;
			endcase
		`GetB : case(opcode)	//GetB can be followed by various states, depending on instruction
			3'b110: present_state = `Pass ;	//if executing a move instruction, must be followed by the pass state
			
			3'b101: case(op)
				  2'b01: present_state = `Sub ;				//corresponds to status=f(R[Rn]-sh_Rm)
				  2'b00, 2'b10, 2'b11: present_state = `Operate ;	//in all other ALU instructions, GetB is followed by Operate
				  default: present_state = 5'bxxxxx;
				endcase
			default: present_state = 5'bxxxxx;
			endcase
		`Pass , `Operate : present_state = `WriteReg ;			//Pass and Operate are always followed by writing to register
		`Sub , `WriteReg , `WriteImm : present_state = `IF1 ;		//These are the final states to various instructions, and are always followed by wait
		`AddImm5 : present_state = `LoadAD ; //both memory instructions go to LoadAD
		`LoadAD : case(opcode)
				3'b011: present_state = `ReadMem ; //load instruction must read from memory
				3'b100: present_state = `GetRd ; //get information to store
				default: present_state = 5'bxxxxx;
			  endcase
		`ReadMem : present_state = `MemtoReg ; //writes memory data to register
		`MemtoReg : present_state = `IF1 ; //back to instruction fetch for next instruction
		`GetRd : present_state = `PassRd ; //passes Rd to C
		`PassRd : case(opcode)
				3'b010: present_state = `ReturnBranch ; //for BLX
				3'b100: present_state = `WriteMem ; //stores data in memory
				default: present_state = 5'bxxxxx;
			  endcase
		`WriteMem : present_state = `IF1; //store complete, back to instruction fetch
		`IF1 : present_state = `IF2 ; //transition to second instruction fetch state
		`IF2 : present_state = `UpdatePC ; //updates program counter
		`HALT : present_state = `HALT ; //stays in halt until reset
//lab 8 lets goooooo
		`MovePC : present_state = `IF1 ; //unconditional
		`SetLinkReg : if(op[0]) begin present_state = `MovePC ; end //goes to movepc
				else begin present_state = `GetRd ; end //goes to getRd
		`ReturnBranch : present_state = `IF1 ; //unconditional
		default: present_state = 5'bxxxxx;
	  endcase
	end

	case(present_state)
	  `RST : begin		//reset state
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b1;
		load_pc = 1'b1;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `GetA : begin		//reading from register Rn into register A
		nsel = 3'b001;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b1;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `GetB : begin		//reading from register Rm into register B
		nsel = 3'b100;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b1;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `Pass : begin		//Passes shifted value of Rm to C, by setting asel to 1 which adds 0 to it
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b1;
		bsel = 1'b0;
		loadc = 1'b1;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `Sub : begin		//Does not update C, rather takes the difference between 2 values and updates the status
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b1;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `Operate : begin	//Updates C with the combinational output of the ALU
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b1;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `WriteReg : begin	//Writes value of C to Rd
		nsel = 3'b010;
		vsel = 2'b00;
		write = 1'b1;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `WriteImm : begin	//Writes immediate input to Rn
		nsel = 3'b001;
		vsel = 2'b10;
		write = 1'b1;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
//new lab 7 states (except RST which is at the top)
	  `AddImm5 : begin	//adds imm5 to Ain, so bsel must be 1
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b1;
		loadc = 1'b1;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `LoadAD : begin	//Loads the address register
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b1;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `ReadMem : begin	//must indicate mem read command
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MREAD;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `GetRd : begin	//nsel is 010 to read from register Rd
		nsel = 3'b010;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b1;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `MemtoReg : begin	//indicated memory read operation to write mdata to a register
		nsel = 3'b010;
		vsel = 2'b11;
		write = 1'b1;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MREAD;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `PassRd : begin	//Passes contents of Rd to C, unmodified
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b1;
		bsel = 1'b0;
		loadc = 1'b1;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `WriteMem : begin	//Indicates memory write operation to store data
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MWRITE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `IF1 : begin	//Instruction fetch stage 1, dout not yet available
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b1;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MREAD;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `IF2 : begin	//Instruction fetch stage 2, dout is available so we updated instuction register
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b1;
		load_ir = 1'b1;
		load_addr = 1'b0;
		mem_cmd = `MREAD;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `UpdatePC : begin	//Loads PC so it can be updated
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b1;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `HALT : begin	//Halt state, does nothing, must be reset from here
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b1;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
//LAB 8
	  `MovePC : begin	//State after CMP instruct where we move based on loop condition
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b1;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		if(pc_offsetsel) begin pc_addsel = 3'b100; end //only add sxim8 to PC if loop condition is true, else don't
		else begin pc_addsel = 3'b010; end
		end
	  `SetLinkReg : begin	//Sets link register (R7)
		nsel = 3'b001;
		vsel = 2'b01;
		write = 1'b1;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b0;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b0;
		pc_addsel = 3'b001;
		end
	  `ReturnBranch : begin	//returnsel is 1 to select output of datapath to PC
		nsel = 3'b000;
		vsel = 2'b00;
		write = 1'b0;
		loada = 1'b0;
		loadb = 1'b0;
		asel = 1'b0;
		bsel = 1'b0;
		loadc = 1'b0;
		loads = 1'b0;
		w = 1'b0;
		reset_pc = 1'b0;
		load_pc = 1'b1;
		addr_sel = 1'b0;
		load_ir = 1'b0;
		load_addr = 1'b0;
		mem_cmd = `MNONE;
		pc_returnsel = 1'b1;
		pc_addsel = 3'b001;
		end
	endcase
  end
endmodule

//INSTRUCTION
//DECODER
//MODULE
module instruction_decoder(in, sel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum, cond, sxim8, manualadd);
  input [15:0] in;
  input [2:0] sel;

  output [15:0] sximm5, sximm8;
  output [2:0] readnum, writenum, opcode;
  output [1:0] ALUop, shift, op;

  output [2:0] cond;
  output [8:0] sxim8;
  output manualadd;

  reg [1:0] shift;

  assign manualadd = (in[15:11] == 5'b01010);
//  reg [1:0] op;

  assign opcode = in[15:13];	//opcode is first 3 bits of the instruction
  assign op = in[12:11];	//op is the next 2 bits of the instruction

  assign ALUop = in[12:11];	//ALUop is specified by bits 12 and 11
  assign sximm5 = { {11{in[4]}} , in[4:0] };	//sximm5 is specified by bits 4 to 0, with the first 11 bits being copies of bit 4 (the sign bit)
  assign sximm8 = { {8{in[7]}} , in[7:0] };	//sximm8 is specified by bits 7 to 0, with the first 8 bits being copies of bit 7 (the sign bit)
  
  always @(*) begin
	if((in[15:13] == 3'b110) || (in[15:13] == 3'b101)) begin
	  shift = in[4:3];	//shift is specified by bits 4 and 3 of the instruction
  	end else begin
	  shift = 2'b00;	//shift is 0 for memory instructions, need to pass Rd to write_data unshifted
	end
  end
  assign readnum = (in[10:8] & {3{sel[0]}}) | (in[7:5] & {3{sel[1]}}) | (in[2:0] & {3{sel[2]}});	//readnum and writenum are the same, and are specified by either Rn, Rd, or Rm
  assign writenum = (in[10:8] & {3{sel[0]}}) | (in[7:5] & {3{sel[1]}}) | (in[2:0] & {3{sel[2]}});	//the select input dictates which of the three should be passed to the datapath
  assign cond = in[10:8];	//condition for branches
  assign sxim8 = {in[7], in[7:0]};	//sxim8 to add to PC
endmodule
