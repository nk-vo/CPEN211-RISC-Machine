module lab7bonus_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  input CLOCK_50;

//clk
  wire clk;
  assign clk = CLOCK_50; //key 0 is clk
//reset
  wire reset;
  assign reset = ~KEY[1]; //key 1 is reset

//no longer needed
  wire N, V, Z, w;
  assign LEDR[8] = w;


//  assign LEDR[9] = V;

//CPU inputs/outputs
  wire [15:0] read_data, write_data;
  wire [8:0] mem_addr;
  wire [1:0] mem_cmd;

//tri-state buffer comparator signal
  wire msel;

//memory signals
  wire mem_write;
  wire [15:0] dout;

//memory input/output logic
  assign msel = ~mem_addr[8]; //MSB of address must be 0 for it to be within the address bounds
  assign mem_write = (mem_cmd[1] & msel); //mem_cmd must be MWRITE and msel must be true
  assign read_data = (mem_cmd[0] & msel) ? dout : 16'bzzzz_zzzz_zzzz_zzzz; //tri state driver, mem_cmd must be MREAD and msel must be true

//SW input logic
  wire switch_enable;
  assign switch_enable = ((mem_addr == 9'h140) & mem_cmd[0]); //9'h140 is the specific address that indicates we should be reading switch inputs
  assign read_data[15:8] = switch_enable ? 8'h00 : 8'bzzzz_zzzz; //tri state buffer for inputting zeros for 8 most significant bits of read_data
  assign read_data[7:0] = switch_enable ? SW[7:0] : 8'bzzzz_zzzz; //tri state for connecting read_data to switch inputs

//LEDR output logic
  wire load_led;
  assign load_led = ((mem_addr == 9'h100) & mem_cmd[1]); //9'h100 is the specific address for displaying str data to LEDs

  RLE #(8) led_reg(write_data[7:0], load_led, clk, LEDR[7:0]); //register w load enable for LEDs

//cpu and memory instantiation
  cpu CPU(clk, reset, read_data, read_data, write_data, N, V, Z, w, mem_addr, mem_cmd);
  RAM MEM(clk, mem_addr[7:0], mem_addr[7:0], mem_write, write_data, dout);

//  sseg H0(write_data[3:0],   HEX0);
//  sseg H1(write_data[7:4],   HEX1);
//  sseg H2(write_data[11:8],  HEX2);
 // sseg H3(write_data[15:12], HEX3);
 // sseg H4(mem_addr[3:0], HEX4);
//  sseg H5(mem_addr[7:4], HEX5);
endmodule


//Memory module (from ss7)
module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 16; 
  parameter addr_width = 8;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule

module sseg(in,segs);
  input [3:0] in;
  output [6:0] segs;

  reg[6:0] temp_segs;

always @(*) begin
	case(in)
	  4'b0: temp_segs = 7'b100_0000;	//0
	  4'b1: temp_segs = 7'b111_1001;	//1
	  4'b10: temp_segs = 7'b010_0100;	//2
	  4'b11: temp_segs = 7'b011_0000;	//3
	  4'b100: temp_segs = 7'b001_1001;	//4
	  4'b101: temp_segs = 7'b001_0010;	//5
	  4'b110: temp_segs = 7'b000_0010;	//6
	  4'b111: temp_segs = 7'b111_1000;	//7
 	  4'b1000: temp_segs = 7'b000_0000;	//8
 	  4'b1001: temp_segs = 7'b001_0000;	//9
	  4'b1010: temp_segs = 7'b000_1000;	//A
	  4'b1011: temp_segs = 7'b000_0011;	//b
	  4'b1100: temp_segs = 7'b100_0110;	//C
	  4'b1101: temp_segs = 7'b010_0001;	//d
	  4'b1110: temp_segs = 7'b000_0110;	//E
	  default: temp_segs = 7'b0001110;  // this will output "F" 
	endcase
end


  assign segs = temp_segs;

endmodule
