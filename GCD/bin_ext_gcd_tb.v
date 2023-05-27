// Code your testbench here

`timescale 1 ns/1 ps

module bin_ext_gcd_tb ();

//Local param reg/wire declaration


localparam  CLK_PERIOD   = 4.167;   //24 Mhz

//localparam  NBITS        = 10;
localparam  NBITS        = 256;

wire [NBITS/2-1:0]   N       = 2**(NBITS/2)-1;
wire [NBITS-1  :0]   nsq     = N*N;
reg  [NBITS-1  :0]   arga    = 256'd319;
reg  [NBITS-1  :0]   argb    = 256'd 177;
//reg  [NBITS-1  :0]   arga    = 10'd220;
//reg  [NBITS-1  :0]   argb    = 10'd961;

integer        j;
integer        seed;

reg              CLK; 
reg              nRESET; 
reg [NBITS-1 :0] a; 
reg [NBITS-1 :0] b; 
reg [NBITS-1 :0] gcd; 
reg              enable_p; 

wire [NBITS+2  :0] x; 
wire [NBITS+2  :0] y; 

integer no_of_clocks; 
reg [NBITS-1 :0] a_loc; 
reg [NBITS-1 :0] b_loc; 

wire                 done_irq_p;
reg [NBITS+2 :0] inv; 
reg [NBITS+2 :0] inv_other; 
reg [NBITS*2-1:0] check; 

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
  $display($time, " << Waiting 1");
   nRESET   = 1'b1;
   enable_p = 1'b0;
   a        = {NBITS{1'b0}};
   b        = {NBITS{1'b0}};
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
  $display($time, " << Waiting 2");

  //for (j=1; j < nsq; j = j+1) begin
    seed = j;

    $display($time, "---------------Iteration %d SEED %d-----------------", j,j);
    //arga           = j;
    //argb           = nsq;

    enable_p = 1'b1;
    @(posedge CLK);
    #1
    enable_p = 1'b0;

    $display($time, " << Value of ARGA  %d", arga);
    $display($time, " << Value of ARGB  %d", argb);
    $display($time, " << Waiting");
    @(posedge done_irq_p);
    @(posedge CLK);
    $display($time, " << Value of GCD  %d", gcd);
    $display($time, " << Inverse Value %d", x);
    inv = x;
    inv_other = y;
    check = inv*arga%argb;
    $display($time, " << FINAL INV %d", inv);
    $display($time, " << FINAL INV OTHER %d", inv_other);
    $display($time, " << FINAL ARGA %d", arga);
    $display($time, " << CHECK %d", check);
    if (gcd == 1) begin
      if(check == 1) begin
      $display($time, " << INFO: PASSED");
      end
      else begin
      $display($time, " << ERROR: FAILED");
      end
    end
    else begin
      $display($time, " << WARNGIN: GCD is not 1");
    end
    @(posedge CLK);
    @(posedge CLK);
    @(posedge CLK);
  //end
  $finish; 
end

//DUT

bin_ext_gcd #(
  .NBITS (NBITS)
 ) u_dut_inst   (
  .clk           (CLK),
  .rst_n         (nRESET),
  .enable_p      (enable_p),
  .x             (arga),
  .y             (argb),
  .a             (x),
  .b             (y),
  .gcd           (gcd),
  .done_irq_p    (done_irq_p)
);



//Track number of clocks
initial begin
  no_of_clocks = 0; 
  a_loc        = 256'b0; 
  b_loc        = 256'b0; 
end


always@(posedge CLK)  begin
  if (enable_p == 1'b1) begin
    a_loc        = a; 
    b_loc        = b; 
  end
  if (a_loc > b_loc) begin
     a_loc = a_loc - b_loc ; 
  end
  else if (b_loc > a_loc) begin
    b_loc  = b_loc - a_loc;
  end
end
    
always@(posedge CLK)  begin
  no_of_clocks = no_of_clocks +1 ; 
 
end

endmodule