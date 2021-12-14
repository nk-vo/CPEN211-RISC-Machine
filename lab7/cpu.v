module cpu(clk,reset,s,load,in,mdata,out,N,V,Z,w,mem_addr,mem_cmd);
    input clk, reset, s, load;
    input [15:0] in, mdata;
    output [15:0] out;
    output N,V,Z,w;
    output [8:0] mem_addr;
    output [1:0] mem_cmd;
    // instruction register to decoder
    wire [15:0] curr_inst;

    // decoder to fsm
    wire [2:0] opcode;
    wire [1:0] op;

    // fsm to decoder
    wire [2:0] nsel;

    // decoder to datapath
    wire [15:0] sximm5, sximm8;
    wire [2:0] readnum, writenum;
    wire [1:0] ALUop, shift;
    
    // fsm to datapath
    wire [1:0] vsel;
    wire write, loada, loadb, asel, bsel, loadc, loads;

    // fsm to instruction register
    wire load_ir;

    // fsm to PC
    wire load_pc, reset_pc;

    // fsm to data address
    wire load_addr, addr_sel;

    // PC and data address multiplexer signals
    wire [8:0] PC, next_pc, da_out;

    // data output
    wire [2:0] Z_out;
    wire [15:0] C;
    
    // PC signal currently unused
    wire [15:0] dp_pc = 16'b0;

    instruction_register ins_reg(clk, load_ir, in, curr_inst);
    instruction_decoder ins_dec(curr_inst, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);
    datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, mdata, sximm8, dp_pc, sximm5, Z_out, C);
    FSM fsm(clk, s, reset, opcode, op, vsel, nsel, write, loada, loadb, asel, bsel, loadc, loads, w, load_pc, reset_pc, addr_sel, load_ir, load_addr, mem_cmd);
    
    RLE #(9) pc(next_pc, load_pc, clk, PC);
    RLE #(9) da(C[8:0], load_addr, clk, da_out);
    Mux2 #(9) pc_mux(9'b0, (PC + 1'b1), reset_pc, next_pc);
    Mux2 #(9) mem_addr_mux(PC, da_out, addr_sel, mem_addr);
    
    assign out = C;         // out is connected to C in datapath
    assign {N,V,Z} = Z_out; // Z_out[2] = N, Z_out[1] = V, Z_out[0] = Z
endmodule

module instruction_register(clk, load, in, inst);
    input clk, load;
    input [15:0] in;
    output reg [15:0] inst;

    always @(posedge clk) begin
        if (load == 1'b1) inst = in; // load in into inst when load is high
    end
endmodule

module instruction_decoder(in, sel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);
    input [15:0] in;
    input [2:0] sel;

    output [15:0] sximm5, sximm8;
    output [2:0] readnum, writenum, opcode;
    output [1:0] ALUop, shift, op;

    assign opcode = in[15:13];  // first 3 bits of instruction
    assign op = in[12:11]; // next 2 bits of instruction

    assign ALUop = in[12:11];   // ALUop are bits 12 and 11
    assign sximm5 = {{11{in[4]}}, in[4:0]}; // bits 4 to 0, with the rest bits are copies of bit 4
    assign sximm8 = {{8{in[7]}}, in[7:0]}; // bits 7 to 0, with the rest bits are copies of bit 7
    assign shift = ( (in[15:13] == 3'b110) || (in[15:13] == 3'b101) )? in[4:3] : 2'b00; // shift are bits 4 and 3 but will be 0 for memory instructions because Rd needed to be passed to write_data unshifted
    assign readnum = (in[10:8] & {3{sel[0]}}) | (in[7:5] & {3{sel[1]}}) | (in[2:0] & {3{sel[2]}});  // select which of the 3 registers Rn, Rd, Rm should be used
    assign writenum = (in[10:8] & {3{sel[0]}}) | (in[7:5] & {3{sel[1]}}) | (in[2:0] & {3{sel[2]}}); // for both readnum and writenum
endmodule

module FSM(clk, s, reset, opcode, op, vsel, nsel, write, loada, loadb, asel, bsel, loadc, loads, w, load_pc, reset_pc, addr_sel, load_ir, load_addr, mem_cmd);
    input clk, s, reset;
    input [2:0] opcode;
    input [1:0] op;

    output [2:0] nsel;
    output [1:0] vsel;
    output write, loada, loadb, asel, bsel, loadc, loads, w;
    output load_pc, reset_pc, addr_sel, load_ir, load_addr;
    output [1:0] mem_cmd;

    reg [4:0] state;
    reg [2:0] nsel;
    reg [1:0] vsel;
    reg write, loada, loadb, asel, bsel, loadc, loads, w;
    reg load_pc, reset_pc, addr_sel, load_ir, load_addr;
    reg [1:0] mem_cmd;
    
    `define RST 5'b00000		//w is 1, here until s turns on, reset will lead to this state
    `define GetA 5'b00001		//read to register A, nsel=001
    `define GetB 5'b00010		//read to register B, nsel=100
    `define Pass 5'b00011		//asel/load c are 1, bsel 0, passes shifted B to C
    `define Sub 5'b00100		//loads is 1, load c is 0 so nothing is passed to C, asel/bsel are 0
    `define Operate 5'b00101	//load c is 1, asel/bsel are 0; result of an ALU operation is passed to C
    `define WriteReg 5'b00110	//write=1, nsel=010, vsel=00; writes C to a register
    `define WriteImm 5'b00111	//vsel=10, write=1, nsel=001; writes immediate input to a register
    `define AddImm5 5'b01000	//adds imm5 input to Ain and load it to C
    `define LoadAD 5'b01001	    //sets memory address to be updated
    `define ReadMem 5'b01010	//reads from memory
    `define GetRd 5'b01011	    //reads data stored in register Rd
    `define MemtoReg 5'b01100	//writes memory read data to a register
    `define PassRd 5'b01101	    //Passes data from Rd to C without adding anything or shifting
    `define WriteMem 5'b01110	//writes to memory
    `define IF1 5'b01111		//First of instruction fetch states
    `define IF2 5'b10000		//second instruction fetch state, where dout is available
    `define UpdatePC 5'b10001	//updates program counter
    `define HALT 5'b10010		//needs to be reset from here

    `define MNONE 2'b00		    //no memory operation in progress
    `define MREAD 2'b01		    //reading from memory [LDR]
    `define MWRITE 2'b10		//writing to memory [STR]

    // state logic and actions within a state
    always @(posedge clk) begin
        if (reset)
            state = `RST;  // go to reset state
        else begin
            case(state)     // current state logic
                `RST: state = `IF1;
                `UpdatePC: case(s)  // go to next state only if s = 1
                    1'b1: case(opcode)
                        3'b110: case(op)
                            2'b10: state = `WriteImm;   // MOV Rn,#<im8>
                            2'b00: state = `GetB;       // first state in MOV Rd, Rm{,<sh_op>}
                            default: state = 5'bxxxxx;
                        endcase
                        3'b101: case(op)
                            2'b11: state = `GetB;       // MVN Rd,Rm{,<sh_op>}, no need to load A register
                            2'b00, 2'b01, 2'b10: state = `GetA; // load A register
                            default: state = 5'bxxxxx;
                        endcase
                        3'b011, 3'b100: state = `GetA;  // memory instructions to GetA state
                        3'b111: state = `HALT; // halt instruction
                        default: state = 5'bxxxxx;
                    endcase
                    1'b0: state = `UpdatePC;  // stay in wait state
                    default: state = 5'bxxxxx;
                endcase
                `GetA: case(opcode)
                    3'b011, 3'b100: state = `AddImm5; // state transition to AddImm5 for memory operations
                    3'b101, 3'b110: state = `GetB; // for operation from lab6
                    default: state = 5'bxxxxx;
                endcase
                `GetB: case(opcode)
                    3'b110: state = `Pass;  // MOV instruction state
                    3'b101: case(op)
                        2'b01: state = `Sub;    // CMP Rn,Rm{,<sh_op>}
                        2'b00, 2'b10, 2'b11: state = `Operate;  
                        default: state = 5'bxxxxx;
                    endcase
                    default: state = 5'bxxxxx;
                endcase
                `Pass, `Operate: state = `WriteReg; // Pass and Operate are followed by WriteReg
                `Sub, `WriteReg, `WriteImm: state = `IF1;  // go to Wait state after Sub, WriteReg and WriteImm
                `AddImm5: state = `LoadAD;
                `LoadAD: case(opcode)
                    3'b011: state = `ReadMem; // load instruction read from memory
                    3'b100: state = `GetRd; // get info to store
                    default: state = 5'bxxxxx;
                endcase
                `ReadMem: state = `MemtoReg;  // writes memory data to register
                `MemtoReg: state = `IF1;  // back to instruction fetch for next instruction
                `GetRd: state = `PassRd;  // passes Rd to C
                `PassRd: state = `WriteMem;  // stores data in memory
                `WriteMem: state = `IF1;  // store complete, back to instruction fetch
                `IF1: state = `IF2;  // transition to second instruction fetch state
                `IF2: state = `UpdatePC; // updates program counter
                `HALT: state = `HALT; // stays in halt until reset
                default: state = 5'bxxxxx;
            endcase 
        end
        case(state)
            `RST : begin		//wait state, all outputs 0
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
                reset_pc = 1'b1;
                load_pc = 1'b1;
                addr_sel = 1'b0;
                load_ir = 1'b0;
                load_addr = 1'b0;
                mem_cmd = `MNONE;
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
                w = 1'b0;
                reset_pc = 1'b0;
                load_pc = 1'b0;
                addr_sel = 1'b0;
                load_ir = 1'b0;
                load_addr = 1'b0;
                mem_cmd = `MNONE;
            end
        endcase
    end
endmodule