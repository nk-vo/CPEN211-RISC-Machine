// Partner 1 ID: 77305464 - last 6: 305464
// BINARY code 0-9
`define b0  4'b0000
`define b1  4'b0001
`define b2  4'b0010
`define b3  4'b0011
`define b4  4'b0100
`define b5  4'b0101
`define b6  4'b0110
`define b7  4'b0111
`define b8  4'b1000
`define b9  4'b1001

// states corresponds to 6 last ID digits and open/close/error
`define valid_1   4'b0000   // 3
`define valid_2   4'b0001   // 0
`define valid_3   4'b0010   // 5
`define valid_4   4'b0011   // 4
`define valid_5   4'b0100   // 6
`define valid_6   4'b0101   // 4
`define invalid_1 4'b0110   // invalid state 1
`define invalid_2 4'b0111   // invalid state 2
`define invalid_3 4'b1000   // invalid state 3
`define invalid_4 4'b1001   // invalid state 4
`define invalid_5 4'b1010   // invalid state 5
`define open      4'b1011   // open
`define close     4'b1100   // close
`define error     4'b1101   // error



// HEXCODE 0-9
`define h_blank 7'b1_111_111
`define h0      7'b1_000_000
`define h1      7'b0_000_110
`define h2      7'b0_100_100
`define h3      7'b0_110_000
`define h4      7'b0_011_001
`define h5      7'b0_010_010
`define h6      7'b0_000_010
`define h7      7'b1_111_000
`define h8      7'b0_000_000
`define h9      7'b0_010_000
`define OPEn    {7'b1_000_000,7'b0_001_100,7'b0_000_110,7'b0_101_011}                           // 28 bits HEX3 -> HEX0
`define CLOSEd  {7'b1_000_110,7'b1_000_111,7'b1_000_000,7'b0_010_010,7'b0_000_110,7'b0_100_001} // 42 bits HEX5 -> HEX0
`define ErrOr   {7'b0_000_110,7'b0_101_111,7'b0_101_111,7'b1_000_000,7'b0_101_111}              // 35 bits HEX4 -> HEX0

module lab3_top(SW,KEY,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,LEDR);
  input [9:0] SW;
  input [3:0] KEY;
  output reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  output [9:0] LEDR; // optional: use these outputs for debugging on your DE1-SoC

  // put your solution code here!
  reg [3:0]  next_state, state;
  wire [3:0] present_state, next_state_reset;
  
  vDFF #(4) vdff_1(~KEY[0], next_state_reset, present_state);
  assign next_state_reset = ~KEY[3] ? `valid_1 : next_state;

  always @(*) begin
    if (SW[3:0] < `b0 | SW[3:0] > `b9)  {HEX4,HEX3,HEX2,HEX1,HEX0} = `ErrOr;
    else begin
      case (present_state)
        `valid_1:   {next_state, state} = {(SW[3:0] == `b3) ? `valid_2 : `invalid_1, `valid_1};
        `valid_2:   {next_state, state} = {(SW[3:0] == `b0) ? `valid_3 : `invalid_2, `valid_2};
        `valid_3:   {next_state, state} = {(SW[3:0] == `b5) ? `valid_4 : `invalid_3, `valid_3};
        `valid_4:   {next_state, state} = {(SW[3:0] == `b4) ? `valid_5 : `invalid_4, `valid_4};
        `valid_5:   {next_state, state} = {(SW[3:0] == `b6) ? `valid_6 : `invalid_5, `valid_5};
        `valid_6:   {next_state, state} = {(SW[3:0] == `b4) ? `open    : `close,     `valid_6};
        `invalid_1: {next_state, state} = {`invalid_2, `invalid_1};
        `invalid_2: {next_state, state} = {`invalid_3, `invalid_2};
        `invalid_3: {next_state, state} = {`invalid_4, `invalid_3};
        `invalid_4: {next_state, state} = {`invalid_5, `invalid_4};
        `invalid_5: {next_state, state} = {`close, `invalid_5};
        `close:     {next_state, state} = {`close, `close};
        `open:      {next_state, state} = {`open, `open};
        default:    {next_state, state} = {8{1'bx}};
      endcase
    end
  end
  always @(*) begin
    
  end
  always @(*) begin
    case(state)
      `valid_1: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
      `valid_2: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
      `valid_3: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
      `valid_4: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
      `valid_5: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
      `valid_6: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
      `open: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = {{2{`h_blank}},`OPEn};
      `invalid_1: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
      `invalid_2: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
      `invalid_3: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
      `invalid_4: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
      `invalid_5: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = temp;
      `close: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = {7'b1000110,7'b1000111,7'b1000000,7'b0010010,7'b0000110,7'b0100001}; // Closed
      default: {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = {7'b1111111,7'b0000110,7'b0101111,7'b0101111,7'b1000000,7'b0101111}; // Closed
    endcase
  end
endmodule

module vDFF(clk, in, out);
  parameter n = 1;
  input clk;
  input [n-1:0] in;
  output reg [n-1:0] out;
  always @(posedge clk) begin
    out <= in;
  end
endmodule
