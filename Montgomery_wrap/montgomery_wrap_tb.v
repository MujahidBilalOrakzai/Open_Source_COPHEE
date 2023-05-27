// Code your testbench here

`timescale 1 ns/1 ps

module montgomery_wrap_tb ();

//Local param reg/wire declaration


localparam  CLK_PERIOD   = 4.167;   //24 Mhz

localparam  NBITS    = 256;


reg              CLK; 
reg              nRESET; 
reg [NBITS-1 :0] a; 
reg [NBITS-1 :0] b; 
reg [NBITS-1 :0] m; 
reg [10      :0] m_size; 
reg [NBITS-1 :0] r_red; 
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
   m_size   = 11'd63;
   r_red    = 256'd0;
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
  m        = 256'd72;
  a        = 256'd57;
  b        = 256'd12;
  m_size   = 11'd17;
  r_red    = 256'd58;
  @(posedge CLK);
  #1
  enable_p = 1'b0;

end

//DUT

montgomery_wrap #(
  .NBITS (NBITS)
 ) u_dut_inst   (
  .clk           (CLK),
  .rst_n         (nRESET),
  .enable_p      (enable_p),
  .a             (a),
  .b             (b),
  .m             (m),
  .m_size        (m_size),
  .r_red         (r_red),
  .y             (y),
  .done_irq_p    (done_irq_p)
);

//Track number of clocks

initial begin
  no_of_clocks = 0; 
end
always@(posedge CLK)  begin
  no_of_clocks = no_of_clocks +1 ; 
  
end endmodule