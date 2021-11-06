// Impementation of the decoder


// states being defined for lock depending on correct or incorrect input
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

// creating a module for the decoder that takes inputs of state and reset and outputs of HEX displays
module decoder(state, digit, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
    input [3:0] state, digit;
    output reg [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    
    reg [41:0] temp;
                        
    always@(*) begin
        case(digit)     // temp 42 bit register being used to hold the correct binary information for the hex display
            4'b0000: temp = {35'b1111111111_1111111111_1111111111_11111,7'b1000000}; //0
            4'b0001: temp = {35'b1111111111_1111111111_1111111111_11111,7'b1111001}; //1
            4'b0010: temp = {35'b1111111111_1111111111_1111111111_11111,7'b0100100}; //2
            4'b0011: temp = {35'b1111111111_1111111111_1111111111_11111,7'b0110000}; //3
            4'b0100: temp = {35'b1111111111_1111111111_1111111111_11111,7'b0011001}; //4
            4'b0101: temp = {35'b1111111111_1111111111_1111111111_11111,7'b0010010}; //5
            4'b0110: temp = {35'b1111111111_1111111111_1111111111_11111,7'b0000010}; //6
            4'b0111: temp = {35'b1111111111_1111111111_1111111111_11111,7'b1111000}; //7
            4'b1000: temp = {35'b1111111111_1111111111_1111111111_11111,7'b0000000}; //8
            4'b1001: temp = {35'b1111111111_1111111111_1111111111_11111,7'b0011000}; //9
            default: temp = {7'b1111111,7'b0000110,7'b0101111,7'b0101111,7'b1000000,7'b0101111};  //Error
        endcase
    end


    always @(*) begin
        case(state)     // depending on what the state is; defining what the hex display will be based on the temp reigster & input digits
            `Sa: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
            `Sb: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
            `Sc: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
            `Sd: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
            `Se: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
            `Sf: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
            `Sg: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = {14'b11111111111111, 7'b1000000, 7'b0001100, 7'b0000110, 7'b0101011};
            `DCa: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
            `DCb: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
            `DCc: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
            `DCd: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
            `DCe: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
            `DCf: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = {7'b1000110,7'b1000111,7'b1000000,7'b0010010,7'b0000110,7'b0100001}; // Closed
            default: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = {7'b1111111,7'b0000110,7'b0101111,7'b0101111,7'b1000000,7'b0101111}; // Closed
        endcase
    end
endmodule

