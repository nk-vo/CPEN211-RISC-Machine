module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    //clk
    wire clk = ~KEY[0];

    //reset
    wire reset = ~KEY[1];

    // instead of pressing KEY[2] and KEY[3]
    // setting s and load to 1 so only need to press clk for next clock cycle
    wire s = 1'b1;
    wire load = 1'b1;
    wire N,V,Z,w;

    // CPU inputs/outputs
    wire [15:0] read_data, write_data;
    wire [8:0] mem_addr;
    wire [1:0] mem_cmd;

    // tri_state buffer
    wire msel;

    // memory signals
    wire mem_write;
    wire [15:0] dout;

    //memory input/output
    assign msel = ~mem_addr[8]; // MSB of address must be 0
    assign mem_write = (mem_cmd[1] & msel); // mem_cmd must be MWRITE and msel must be true
    assign read_data = (mem_cmd[0] & msel) ? dout : {16{1'bz}}; // tri state driver, mem_cmd must be MREAD and msel must be true

    //SW input logic
    wire switch_enable = ((mem_addr == 9'h140) & mem_cmd[0]); // 9'h140 is the specific address indicating switch inputs read
    assign read_data[15:8] = switch_enable ? 8'h00 : {8{1'bz}}; // tri state buffer for inputting zeros for 8 MSB of read_data
    assign read_data[7:0] = switch_enable ? SW[7:0] : {8{1'bz}}; // tri state for connecting read_data to switch inputs

    //LEDR output logic
    wire load_led = ((mem_addr == 9'h100) & mem_cmd[1]); // 9'h100 is the specific address for displaying str data to LEDs

    RLE #(8) led_reg(write_data[7:0], load_led, clk, LEDR[7:0]); 

    //cpu and memory instantiation
    cpu CPU(clk, reset, s, load, read_data, read_data, write_data, N, V, Z, w, mem_addr, mem_cmd);
    RAM MEM(clk, mem_addr[7:0], mem_addr[7:0], mem_write, write_data, dout);

    sseg H0(write_data[3:0], HEX0);
    sseg H1(write_data[7:4], HEX1);
    sseg H2(write_data[11:8], HEX2);
    sseg H3(write_data[15:12], HEX3);
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
    `define h_blank 7'b1_111_111
    `define h0      7'b1_000_000
    `define h1      7'b1_111_001
    `define h2      7'b0_100_100
    `define h3      7'b0_110_000
    `define h4      7'b0_011_001
    `define h5      7'b0_010_010
    `define h6      7'b0_000_010
    `define h7      7'b1_111_000
    `define h8      7'b0_000_000
    `define h9      7'b0_010_000
    `define ha      7'b0_001_000
    `define hb      7'b0_000_011
    `define hc      7'b1_000_110
    `define hd      7'b0_100_001
    `define he      7'b0_000_110
    `define hf      7'b0_001_110

    reg [6:0] segs;

  always @(*) begin
    case(in)
      4'b0000: segs = `h0;
      4'b0001: segs = `h1;
      4'b0010: segs = `h2;
      4'b0011: segs = `h3;
      4'b0100: segs = `h4;
      4'b0101: segs = `h5;
      4'b0110: segs = `h6;
      4'b0111: segs = `h7;
      4'b1000: segs = `h8;
      4'b1001: segs = `h9;
      4'b1010: segs = `ha;
      4'b1011: segs = `hb;
      4'b1100: segs = `hc;
      4'b1101: segs = `hd;
      4'b1110: segs = `he;
      4'b1111: segs = `hf;
      default: segs = `h_blank;
    endcase
  end
endmodule