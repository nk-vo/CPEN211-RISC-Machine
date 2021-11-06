`define Sa 2'b00
`define Sb 2'b01
`define Sc 2'b10
`define Sd 2'b11

module MealyDec(state,in,out);
    input [1:0] state;
    input in;
    output [2:0] out;

    reg [2:0] out;
    
    always @(*) begin
        case(state)
            `Sa: out = in ? 3'b101 : 3'b111;
            `Sb: out = in ? 3'b011 : 3'b001;
            `Sc: out = in ? 3'b100 : 3'b000;
            `Sd: out = 3'b110;
            default: out = {3{1'bx}};
        endcase
    end
endmodule

/*module fsm(clk, reset, in, state);
    input clk, reset, in;
    output reg [1:0] state;
    
    wire [1:0] next_state_reset;
    reg [1:0] next_state, present_state;

    always @(posedge clk)
        present_state <= next_state_reset;

    assign next_state_reset = reset ? `Sa : next_state;

    always @(*) begin
        case(present_state)
            `Sa: {next_state, state} = {(in ? `Sc : `Sb), `Sa};
            `Sb: {next_state, state} = {(in ? `Sa : `Sd), `Sb};
            `Sc: {next_state, state} = {(in ? `Sd : `Sb), `Sc};
            `Sd: {next_state, state} = {`Sd, `Sd};
            default: {next_state, state} = {4{1'bx}};
        endcase
    end
endmodule*/
