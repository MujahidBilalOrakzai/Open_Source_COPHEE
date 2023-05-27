`timescale 1 ns/1 ps
module mod_exp_tb ();

//---------------------------------
//Local param reg/wire declaration
//---------------------------------

localparam  CLK_PERIOD   = 4.167;   //24 Mhz

localparam  NBITS    = 256;


reg              CLK; 
reg              nRESET; 
reg [NBITS-1 :0] a; 
reg [NBITS-1 :0] b; 
reg [NBITS-1 :0] m; 
reg [11      :0] m_size; 
reg [NBITS-1 :0] r_red; 
reg              enable_p; 

wire [NBITS-1 :0] y; 

integer no_of_clocks; 


//------------------------------
//Clock and Reset generation
//------------------------------

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
   m        = 0;
   a        = 0;
   b        = 0;
   m_size   = 12;
   r_red    = 0;
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
  m        = 5;
  a        = 11;
  b        = 8;

  m_size   = 12;
  r_red    = (1'b1 << m_size) - m;
  @(posedge CLK);
  #1
  enable_p = 1'b0;

end



//------------------------------
//DUT
//------------------------------
mod_exp #(
  .NBITS (NBITS)
 ) u_dut_inst   (
  .clk           (CLK),
  .rst_n         (nRESET),
  .enable_p      (enable_p),
  .a             (a),
  .exp           (b),
  .m             (m),
  .m_size        (m_size),
  .r_red         (r_red),
  .y             (y),
  .done_irq_p    (done_irq_p)
);


//------------------------------
//Track number of clocks
//------------------------------
initial begin
  no_of_clocks = 0; 
end
always@(posedge CLK)  begin
  no_of_clocks = no_of_clocks +1 ; 
   
end

endmodule