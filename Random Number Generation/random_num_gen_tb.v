`timescale 1 ns/1 ps

module random_num_gen_tb ();


//Local param reg/wire declaration

localparam  CLK_PERIOD   = 4.167;   //24 Mhz

localparam  NBITS    = 256;
  


reg              CLK; 
reg              nRESET; 
reg [NBITS-1 :0] a; 
reg [NBITS-1 :0] b; 
reg [NBITS-1 :0] m; 
reg              enable_p; 

wire [NBITS-1 :0] y; 

integer no_of_clocks; 

//Clock and Reset generation

initial begin
  CLK      = 1'b0; 
end

always begin
  #(CLK_PERIOD/2) CLK = ~CLK; 
end

initial begin
$dumpfile("dump.vcd");
$dumpvars(1);
end

initial begin
   nRESET   = 1'b1;
   enable_p = 1'b0;
   m        = 256'd0;
   a        = 256'd0;
   b        = 256'd0;
  repeat (2) begin
    @(posedge CLK);
  end
   nRESET    = 1'b0;

  repeat (2) begin
    @(posedge CLK);
  end
  nRESET   = 1'b1;


  repeat (2) begin
    @(posedge CLK);
  end
  #1
  enable_p = 1'b1;
  m        = 256'd13;
  a        = 256'd93;
  b        = 256'd99;
  @(posedge CLK);
  #1
  enable_p = 1'b0;

end 

//DUT

random_num_gen #(
  .NBITS (NBITS)
 ) u_dut_inst   (
  .clk           (CLK),
  .rst_n         (nRESET),
  .enable_p      (enable_p),
  .bypass        (1'b0),
  .y             (y),
  .done_p        (done_irq_p)
);


//Track number of clocks

initial begin
  no_of_clocks = 0; 
end
always@(posedge CLK)  begin
  no_of_clocks = no_of_clocks +1 ; 
end

endmodule