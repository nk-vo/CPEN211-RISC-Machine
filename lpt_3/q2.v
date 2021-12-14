`define WAIT 3'b000
`define MOV 3'b001
`define XOR 3'b010
`define ASL 3'b011
`define SWP 3'b100

module bitwise(clk,reset,s,op,in,out,done);
    input clk, reset, s;
    input [7:0] in;
    input [3:0] op;
    output [7:0] out;
    output done;
    wire [1:0] sr, Rn, aluop;
    wire w, lt;
    wire [2:0] bsel, tsel;
    datapath DP(clk,in,sr,Rn,w,aluop,lt,tsel,bsel,out);
    // IMPLEMENT YOUR CONTROLLER HERE

    reg [2:0] next_state;
    wire [2:0] next_state_reset, present_state;
    assign next_state_reset = reset ? `WAIT : next_state;
    vDFF #(3) vdff(clk, next_state_reset, present_state);

    reg done;
    
    wire [1:0] i = Rn;
    reg [7:0] R0, R1, R2, R3;
    reg [7:0] Ri, tmp;
    
    always @(*) begin
        casex({present_state, s, op})
            {`WAIT, 1'b0, 4'bxxxx}: next_state = `WAIT;
            {`WAIT, 1'b1, {2'b00, i}}: next_state = `MOV;
            {`WAIT, 1'b1, {2'b01, 2'bxx}}: next_state = `XOR;
            {`WAIT, 1'b1, {2'b10, 2'bxx}}: next_state = `ASL;
            {`WAIT, 1'b1, {2'b11, i}}: next_state = `SWP;

            {`MOV, 1'bx, 4'bxxxx}: next_state = `WAIT;
            {`XOR, 1'bx, 4'bxxxx}: next_state = `WAIT;
            {`ASL, 1'bx, 4'bxxxx}: next_state = `WAIT;
            {`SWP, 1'bx, 4'bxxxx}: next_state = `WAIT;
            default: next_state = `WAIT;
        endcase
    end

    always @(posedge clk) begin
        case(present_state)
            `WAIT: done = 0;
            `MOV: begin
                Ri = in; done = 1;
            end
            `XOR: begin
                tmp = R1;
                tmp = tmp ^2;
                R0 = tmp;
                done = 1;
            end
            `ASL: begin
                tmp = R1;
                tmp = tmp & R2;
                tmp = tmp << 1;
                R0 = tmp;
                done = 1;
            end
            `SWP: begin
                tmp = R0;
                R0 = Ri;
                Ri = tmp;
                done = 1;
            end
        endcase
    end
endmodule