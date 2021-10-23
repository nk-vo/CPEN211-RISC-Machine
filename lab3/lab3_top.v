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
`define S0    4'b0000   // start state
`define S1    4'b0001   // 3
`define S2    4'b0010   // 0
`define S3    4'b0011   // 5
`define S4    4'b0100   // 4
`define S5    4'b0101   // 6
`define S6    4'b0110   // 4
`define open  4'b0111   // open
`define close 4'b1000   // close
`define error 4'b1001   // error
`define base  4'bxxxx   // base case

// HEXCODE 0-9
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


  reg [3:0] present_state;
  // put your solution code here!
  
  always @(posedge ~KEY[0]) begin
    if (~KEY[3]) begin
      present_state = `S1;
      HEX0 = 7'bx_xxx_xxx;
    end

    else begin
      case (present_state)
        `S1:  if (SW[3:0] == `b3)
                present_state = `S2;
              else
                present_state = `error;
        `S2:  if (SW[3:0] == `b0)
                present_state = `S3;
              else
                present_state = `error;
        `S3:  if (SW[3:0] == `b5)
                present_state = `S4;
              else
                present_state = `error;
        `S4:  if (SW[3:0] == `b4)
                present_state = `S5;
              else
                present_state = `error;
        `S5:  if (SW[3:0] == `b6)
                present_state = `S6;
              else
                present_state = `error;
        `S6:  if (SW[3:0] == `b4)
                present_state = `open;
              else
                present_state = `error;
        `error: begin 
                  present_state = `close;
                end
        `close: begin
                  present_state = `close;               
                end
        `open:  begin
                  present_state = `open;
                end
        default: present_state = 4'bxxxx;
      endcase
    end
    if (SW[3:0] < `b0 | SW[3:0] > `b9) begin
      present_state = `error;
    end
    case ({SW[3:0],present_state})
      {`b3,`S1}: HEX0 = `h3;
      {`b0,`S2}: HEX0 = `h0;
      {`b5,`S3}: HEX0 = `h5;
      {`b4,`S4}: HEX0 = `h4;
      {`b5,`S5}: HEX0 = `h6;
      {`b4,`S6}: HEX0 = `h4;
      {`base,`error}: {HEX4,HEX3,HEX2,HEX1,HEX0} = `ErrOr;
      {`base,`close}: {HEX5,HEX4,HEX3,HEX2,HEX1,HEX0} = `CLOSEd;
      {`base,`open}:  {HEX3,HEX2,HEX1,HEX0} = `OPEn;
      default: {HEX0, HEX1, HEX2, HEX3, HEX4, HEX5} ={6{7'bx}};
    endcase
    
    
  end
endmodule
