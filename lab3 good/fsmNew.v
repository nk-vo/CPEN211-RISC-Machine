// Impementation of the moore fsm

/*
            STATE ENCODINGS
    SW  - 4
    Sa - 0000        DCa - 0111
    Sb - 0001        DCb - 1000
    Sc - 0010        DCc - 1001
    Sd - 0011        DCd - 1010
    Se - 0100        DCe - 1011
    Sf - 0101        DCf - 1100
    Sg - 0110        
*/

// here we are are defining the states of the lock depending 
// on whether the input was correct or not

`define SW 4
`define Sa 4'b0000
`define Sb 4'b0001
`define Sc 4'b0010
`define Sd 4'b0011
`define Se 4'b0100
`define Sf 4'b0101
`define Sg 4'b0110
`define DCa 4'b0111
`define DCb 4'b1000
`define DCc 4'b1001
`define DCd 4'b1010
`define DCe 4'b1011
`define DCf 4'b1100


// creating a module for the FSM that takes in a reset, clock, binary number (lock input) and outputs state
module fsmNew(clk, reset, digit, state);
    input clk, reset;
    input [3:0] digit;
    output reg [3:0] state; 

    wire [`SW-1:0] nextStateReset;
    reg[`SW-1:0] nextState, presentState;
    
    // to handle state change with respect to the rising edge of the clock
    always @(posedge clk)
        presentState <= nextStateReset;

    // to handle the resetting of state depending on the reset input being high or low
    assign nextStateReset = reset ? `Sa : nextState;

    // combinational logic block to handle state change when input changes on switches
    always @(*) begin
        case(presentState)
            `Sa: {nextState, state} = {digit == 4'd8 ? `Sb : `DCa, `Sa};
            `Sb: {nextState, state} = {digit == 4'd7 ? `Sc : `DCb, `Sb};
            `Sc: {nextState, state} = {digit == 4'd5 ? `Sd : `DCc, `Sc};
            `Sd: {nextState, state} = {digit == 4'd8 ? `Se : `DCd, `Sd};
            `Se: {nextState, state} = {digit == 4'd2 ? `Sf : `DCe, `Se};
            `Sf: {nextState, state} = {digit == 4'd8 ? `Sg : `DCf, `Sf};
            `Sg: {nextState, state} = {`Sg, `Sg};
            `DCa: {nextState, state} = {`DCb, `DCa};
            `DCb: {nextState, state} = {`DCc, `DCb};
            `DCc: {nextState, state} = {`DCd, `DCc};
            `DCd: {nextState, state} = {`DCe, `DCd};
            `DCe: {nextState, state} = {`DCf, `DCe};
            `DCf: {nextState, state} = {`DCf, `DCf};
            default: {nextState, state} = {8'bxxxx_xxxx};
        endcase
    end
endmodule

