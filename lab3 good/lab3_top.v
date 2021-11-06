/*    LAB NOTES
    - Last 6 digits of student no (Partner 1): 875828
*/

module lab3_top(SW,KEY,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,LEDR);
  input [9:0] SW;
  input [3:0] KEY;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  output [9:0] LEDR; // optional: use these outputs for debugging on your DE1-SoC

  wire [3:0] state;


  // connecting the finite state machine and decoder 
  
  // module instantiation for fsm
  fsmNew FSM(~KEY[0], ~KEY[3], SW[3:0], state);

  // module instantiation for the decoder module
  decoder DEC(state, SW[3:0], HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);


endmodule