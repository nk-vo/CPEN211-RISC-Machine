`define MOV 2'b00
`define XOR 2'b01
`define ASL 2'b10
`define SWP 2'b11

module tb_check_q1;
  reg clk, w, lt;
  reg [7:0] in;
  reg [1:0] sr, Rn, aluop;
  reg [2:0] bsel, tsel;
  wire [7:0] out;

  datapath DUT(clk,in,sr,Rn,w,aluop,lt,tsel,bsel,out);

  // make sure you get no warnings for the the following lines!
  wire [7:0] R0 = DUT.R0;
  wire [7:0] R1 = DUT.R1;
  wire [7:0] R2 = DUT.R2;
  wire [7:0] R3 = DUT.R3;
  wire [7:0] tmp = DUT.tmp;
  wire [7:0] rin = DUT.rin;
  wire [7:0] Bin = DUT.Bin;
  wire [7:0] alu_out = DUT.alu_out;

  initial forever begin
    clk = 0; #5;
    clk = 1; #5;
  end

  initial begin
    // check writing into R0
    @(negedge clk);
    Rn = 2'b00;
    w = 1'b1;
    in = 8'b00001111;
    sr = 2'b00;
    @(negedge clk);
    if( R0 !== 8'b00001111 ) begin
      $display("ERROR ** R0 incorrect");
      #5; $stop;
    end
    if( out !== 8'b00001111 ) begin
      $display("ERROR ** out incorrect");
      #5; $stop;
    end

    // should NOT update R0 if w is 0
    w = 1'b0;
    in = 8'b11110000; 
    @(negedge clk);
    if( R0 !== 8'b00001111 ) begin
      $display("ERROR ** R0 incorrect");
      #5; $stop;
    end

    // put a value in R1
    in = 8'b00001001;
    Rn = 2'b01;
    w = 1'b1;
    @(negedge clk);
    if( R1 !== 8'b00001001 ) begin
      $display("ERROR ** R1 incorrect");
      #5; $stop;
    end

    // load R0 into tmp
    w = 1'b0;
    tsel = 3'b010;
    lt = 1'b1;
    @(negedge clk);
    if( tmp !== 8'b00001111 ) begin
      $display("ERROR ** tmp incorrect");
      #5; $stop;
    end

    // check ALU does something (does NOT check all operations!)
    lt = 1'b0;
    bsel = 3'b001;
    aluop = 2'b00;
    #2; // should not need next rising edge as ALU should be combinational
    if( Bin !== 8'b00001001 ) begin
      $display("ERROR ** Bin incorrect");
      #5; $stop;
    end
    if( alu_out !== 8'b00000110 ) begin
      $display("ERROR ** alu_out incorrect");
      #5; $stop;
    end
    @(negedge clk);
   
    $display("INTERFACE OK");
    $stop;
  end
endmodule

module tb_check_q2;
  reg clk, reset, s;
  reg [3:0] op;
  reg [7:0] in;
  wire [7:0] out;  
  wire done;

  bitwise DUT(clk,reset,s,op,in,out,done);

  initial forever begin
    clk = 0; #5;
    clk = 1; #5;
  end

  // make sure you get no warnings for the the following lines!
  wire [7:0] R0 = DUT.DP.R0;
  wire [7:0] R1 = DUT.DP.R1;
  wire [7:0] R2 = DUT.DP.R2;
  wire [7:0] R3 = DUT.DP.R3;
  wire [7:0] tmp = DUT.DP.tmp;
  wire [7:0] rin = DUT.DP.rin;
  wire [7:0] Bin = DUT.DP.Bin;
  wire [7:0] alu_out = DUT.DP.alu_out;

  initial begin
    s = 1'b0; 
    reset = 1'b1; 
    #10;
    reset = 1'b0; 
    #20;

    // MOV R1  42
    {s,op,in} = {1'b1,`MOV, 2'd1, 8'd42}; #10; s=1'b0;
    @(posedge done);
    @(negedge clk);

    if( R1 !== 8'd42 ) begin
      $display("ERROR ** R1 incorrect");
      #5; $stop;
    end

    $display("INTERFACE OK");
    $stop;
  end
endmodule

module tb_add;
  reg clk, reset, s;
  reg [3:0] op;
  reg [7:0] in;
  wire [7:0] out;  
  wire done;
  
  bitwise DUT(clk,reset,s,op,in,out,done);

  initial forever begin
    clk = 0; #5;
    clk = 1; #5;
  end

  initial begin
    s = 1'b0; 
    reset = 1'b1; 
    #10;
    reset = 1'b0; 
    #20;

    // MOV R1  42
    {s,op,in} = {1'b1,`MOV, 2'd1, 8'd42}; #10; s=1'b0;
    @(posedge done);
    @(negedge clk);

    // MOV R2  11
    {s,op,in} = {1'b1,`MOV, 2'd2, 8'd11}; #10; s=1'b0;
    @(posedge done);
    @(negedge clk);

    repeat (5) begin
      // XOR
      {s,op,in} = {1'b1,`XOR, 2'd0, 8'd0}; #10; s=1'b0;
      @(posedge done);
      @(negedge clk);

      // SWP R3
      {s,op,in} = {1'b1,`SWP, 2'd3, 8'd0}; #10; s=1'b0;
      @(posedge done);
      @(negedge clk);
      
      // ASL
      {s,op,in} = {1'b1,`ASL, 2'd0, 8'd0}; #10; s=1'b0;
      @(posedge done);
      @(negedge clk);
      
      // SWP R1
      {s,op,in} = {1'b1,`SWP, 2'd1, 8'd0}; #10; s=1'b0;
      @(posedge done);
      @(negedge clk);
      
      // SWP R3
      {s,op,in} = {1'b1,`SWP, 2'd3, 8'd0}; #10; s=1'b0;
      @(posedge done);
      @(negedge clk);
      
      // SWP R2
      {s,op,in} = {1'b1,`SWP, 2'd2, 8'd0}; #10; s=1'b0;
      @(posedge done);
      @(negedge clk);
    end
    if( out === 8'd53 ) begin
      $display("Output output is %d (expected 53).", out);
    end else begin
      $display("ERROR ** out is %d instead of 53", out);
      #5; $stop;
    end
    $stop;
  end
endmodule
