

`timescale 1 ns/1 ps

module montgomery_mul_tb ();

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
reg [NBITS-1 :0] m_size; 
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
   nRESET   = 1'b1;
   enable_p = 1'b0;
   m        = 0;
   a        = 0;
   b        = 0;
   m_size   = 11;
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
    a = 123;
    b = 456;
    m = 625;
    m_size = 10;
  @(posedge CLK);
  #1
  enable_p = 1'b0;

end



//------------------------------
//DUT
//------------------------------
montgomery_mul #(
  .NBITS (NBITS)
 ) u_dut_inst   (
  .clk           (CLK),
  .rst_n         (nRESET),
  .enable_p      (enable_p),
  .a             (a),
  .b             (b),
  .m             (m),
  .m_size        (m_size),
  .y             (y),
  .done_irq_p    (done_irq_p)
);

initial begin
$dumpfile("dump.vcd");
$dumpvars(1);
end
  
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