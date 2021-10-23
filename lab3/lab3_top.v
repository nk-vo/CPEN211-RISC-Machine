module lab3_top(SW,KEY,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,LEDR);
  input [9:0] SW;
  input [3:0] KEY;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  output [9:0] LEDR; // optional: use these outputs for debugging on your DE1-SoC

  // put your solution code here!
  // Partner 1 ID: 77305464 - last 6: 305464
  always @(negedge KEY[0]) begin
    if (~KEY[3]) begin
      
    end
  end
endmodule
