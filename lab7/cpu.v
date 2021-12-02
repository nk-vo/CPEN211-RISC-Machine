module cpu(clk,reset,s,load,in,out,N,V,Z,w);
    input clk, reset, s, load;
    input [15:0] in;
    output [15:0] out;
    output N,V,Z,w;

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

    // data output
    wire [2:0] Z_out;
    wire [15:0] C;

    // unused signals
    wire [15:0] mdata, PC;

    instruction_register ins_reg(clk, load, in, curr_inst);
    instruction_decoder ins_dec(curr_inst, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);
    datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, mdata, sximm8, PC, sximm5, Z_out, C);
    FSM fsm(clk, s, reset, opcode, op, vsel, nsel, write, loada, loadb, asel, bsel, loadc, loads, w);
    
    assign out = C;         // out is connected to C in datapath
    assign {N,V,Z} = Z_out; // Z_out[2] = N, Z_out[1] = V, Z_out[0] = Z

    assign mdata = 16'b0;   // mdata is 0 in lab 6
    assign PC = 16'b0;      // PC is 0 in lab 6
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
    assign shift = in[4:3]; // shift are bits 4 and 3
    assign readnum = (in[10:8] & {3{sel[0]}}) | (in[7:5] & {3{sel[1]}}) | (in[2:0] & {3{sel[2]}});  // select which of the 3 registers Rn, Rd, Rm should be used
    assign writenum = (in[10:8] & {3{sel[0]}}) | (in[7:5] & {3{sel[1]}}) | (in[2:0] & {3{sel[2]}}); // for both readnum and writenum
endmodule

module FSM(clk, s, reset, opcode, op, vsel, nsel, write, loada, loadb, asel, bsel, loadc, loads, w);
    input clk, s, reset;
    input [2:0] opcode;
    input [1:0] op;

    output reg [1:0] vsel;
    output reg [2:0] nsel;
    output reg write, loada, loadb, asel, bsel, loadc, loads, w;
    reg [2:0] state;
    
    `define Wait 3'b000		//w is 1, here until s turns on, reset will lead to this state
    `define GetA 3'b001		//read to register A, nsel=001
    `define GetB 3'b010		//read to register B, nsel=100
    `define Pass 3'b011		//asel/loadc are 1, bsel 0, passes shifted B to C
    `define Sub 3'b100		//loads is 1, load c is 0 so nothing is passed to C, asel/bsel are 0
    `define Operate 3'b101	//load c is 1, asel/bsel are 0; result of an ALU operation is passed to C
    `define WriteReg 3'b110	//write=1, nsel=010, vsel=00; writes C to a register
    `define WriteImm 3'b111	//vsel=10, write=1, nsel=001; writes immediate input to a register

    // state logic and actions within a state
    always @(posedge clk) begin
        if (reset)
            state = `Wait;  // go to Wait state of reset is on
        else begin
            case(state)     // current state logic
                `Wait: case(s)  // go to next state only if s = 1
                    1'b1: case(opcode)
                        3'b110: case(op)
                            2'b10: state = `WriteImm;   // MOV Rn,#<im8>
                            2'b00: state = `GetB;       // first state in MOV Rd, Rm{,<sh_op>}
                            default: state = 3'bxxx;
                        endcase
                        3'b101: case(op)
                            2'b11: state = `GetB;       // MVN Rd,Rm{,<sh_op>}, no need to load A register
                            2'b00, 2'b01, 2'b10: state = `GetA; // load A register
                            default: state = 3'bxxx;
                        endcase
                        default: state = 3'bxxx;
                    endcase
                    1'b0: state = `Wait;    // stay in wait state
                    default: state = 3'bxxx;
                endcase
                `GetA: state = `GetB;   //always go to GetB when in GetA
                `GetB: case(opcode)
                    3'b110: state = `Pass;  // MOV instruction state
                    3'b101: case(op)
                        2'b01: state = `Sub;    // CMP Rn,Rm{,<sh_op>}
                        2'b00, 2'b10, 2'b11: state = `Operate;  
                        default: state = 3'bxxx;
                    endcase
                    default: state = 3'bxxx;
                endcase
                `Pass, `Operate: state = `WriteReg; // Pass and Operate are followed by WriteReg
                `Sub, `WriteReg, `WriteImm: state = `Wait;  // go to Wait state after Sub, WriteReg and WriteImm
                default: state = 3'bxxx;
            endcase 
        end
        case(state)
            `Wait: begin    // wait state, all output are 0
                nsel = 3'b000;  asel = 1'b0;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b0;   loadc = 1'b0;
                loada = 1'b0;   loads = 1'b0;
                loadb = 1'b0;   w = 1'b1;
            end
            `GetA: begin    // read register Rn into A
                nsel = 3'b001;  asel = 1'b0;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b0;   loadc = 1'b0;
                loada = 1'b1;   loads = 1'b0;
                loadb = 1'b0;   w = 1'b0;
            end
            `GetB: begin    // read register Rm into B
                nsel = 3'b100;  asel = 1'b0;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b0;   loadc = 1'b0;
                loada = 1'b0;   loads = 1'b0;
                loadb = 1'b1;   w = 1'b0;
            end
            `Pass: begin    // pass shifted value of B into C by adding value 0 instead of A
                nsel = 3'b000;  asel = 1'b1;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b0;   loadc = 1'b1;
                loada = 1'b0;   loads = 1'b0;
                loadb = 1'b0;   w = 1'b0;
            end
            `Sub: begin     // does not update C, only update status register by setting loads = 1
                nsel = 3'b000;  asel = 1'b0;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b0;   loadc = 1'b0;
                loada = 1'b0;   loads = 1'b1;
                loadb = 1'b0;   w = 1'b0;
            end
            `Operate: begin // load C register with result from ALU
                nsel = 3'b000;  asel = 1'b0;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b0;   loadc = 1'b1;
                loada = 1'b0;   loads = 1'b0;
                loadb = 1'b0;   w = 1'b0;
            end
            `WriteReg: begin   // write data from C into Rd
                nsel = 3'b010;  asel = 1'b0;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b1;   loadc = 1'b0;
                loada = 1'b0;   loads = 1'b0;
                loadb = 1'b0;   w = 1'b0;
            end
            `WriteImm: begin    // write immediate input into Rn
                nsel = 3'b001;  asel = 1'b0;
                vsel = 2'b10;   bsel = 1'b0;
                write = 1'b1;   loadc = 1'b0;
                loada = 1'b0;   loads = 1'b0;
                loadb = 1'b0;   w = 1'b0;
            end
            default: begin
                nsel = 3'bx;  asel = 1'bx;
                vsel = 2'bx;   bsel = 1'bx;
                write = 1'bx;   loadc = 1'bx;
                loada = 1'bx;   loads = 1'bx;
                loadb = 1'bx;   w = 1'bx;
            end
        endcase
    end
endmodule