
module random_num_gen #(
  parameter  NBITS = 256 )(
  input  wire               clk,
  input  wire               rst_n,
  input  wire               enable_p,
  input  wire               bypass,
  input  wire [11:0]        maxbits,
  output wire               done_p,
  output wire [NBITS-1 :0]  y
);

wire [4:0]  y_loc;

reg        vn_din;
reg        wait4_done;
reg [2:0]  cnt;
reg [4:0]  en_loc;


trng_wrap trng_wrap_inst0 (
  .clk      (clk),          //input   wire 
  .rst_n    (rst_n),        //input   wire 
  .en       (en_loc[0]),    //input   wire 
  .y        (y_loc[0])      //output  wire 
);

trng_wrap trng_wrap_inst1 (
  .clk      (clk),          //input   wire 
  .rst_n    (rst_n),        //input   wire 
  .en       (en_loc[1]),    //input   wire 
  .y        (y_loc[1])      //output  wire 
);

trng_wrap trng_wrap_inst2 (
  .clk      (clk),          //input   wire 
  .rst_n    (rst_n),        //input   wire 
  .en       (en_loc[2]),    //input   wire 
  .y        (y_loc[2])      //output  wire 
);

trng_wrap trng_wrap_inst3 (
  .clk      (clk),          //input   wire 
  .rst_n    (rst_n),        //input   wire 
  .en       (en_loc[3]),    //input   wire 
  .y        (y_loc[3])      //output  wire 
);

trng_wrap trng_wrap_inst4 (
  .clk      (clk),          //input   wire 
  .rst_n    (rst_n),        //input   wire 
  .en       (en_loc[4]),    //input   wire 
  .y        (y_loc[4])      //output  wire 
);



vn_corrector #(
  .NBITS (NBITS))
  vn_corrector_inst (
  .clk      (clk),         //input                wire 
  .rst_n    (rst_n),       //input                wire 
  .bypass   (bypass),      //input                wire 
  .enable_p (en_trig),     //input                wire 
  .din      (vn_din),      //input                wire 
  .maxbits  (maxbits),
  .done_p   (done_p),      //output               wire 
  .y        (y)            //output [NBITS-1 :0]  wire 
);


 always @* begin
   if (cnt == 3'b011) begin
     vn_din = y_loc[0];
   end
   else if (cnt == 3'b100) begin
     vn_din = y_loc[1];
   end
   else if (cnt == 3'b000) begin
     vn_din = y_loc[2];
   end
   else if (cnt == 3'b001) begin
     vn_din = y_loc[3];
   end
   else if (cnt == 3'b010) begin
     vn_din = y_loc[4];
   end
   else begin
     vn_din = 1'b0;
   end
 end
      
 always @ (posedge clk or negedge rst_n) begin
   if (rst_n == 1'b0) begin
     cnt        <= 3'b111;
     wait4_done <= 1'b0;
   end
   else begin
     if (enable_p == 1'b1) begin
       cnt        <= 3'b0;
       wait4_done <= 1'b1;
     end
     else if (done_p == 1'b1) begin
       cnt        <= 3'b111;
       wait4_done <= 1'b0;
     end
     else if (wait4_done == 1'b1) begin
       if (cnt[2] == 1'b1) begin
         cnt <= 3'b0;
       end
       else begin
         cnt <= cnt + 1'b1;
       end
     end
     else begin
       cnt        <= 3'b111;
       wait4_done <= 1'b0;
     end
   end
 end

 assign en_trig = (cnt < 3'b011) ? 1'b1 : 1'b0; 

 always @ (posedge clk or negedge rst_n) begin
   if (rst_n == 1'b0) begin
     en_loc <= 5'b0;
   end
   else if (done_p == 1'b1) begin
     en_loc <= 5'b0;
   end
   else begin
     en_loc[0] <= en_trig;
     en_loc[1] <= en_loc[0];
     en_loc[2] <= en_loc[1];
     en_loc[3] <= en_loc[2];
     en_loc[4] <= en_loc[3];
   end
 end


endmodule

//Von Neumann corrector
module vn_corrector #(
  parameter NBITS = 256)(
  input  wire               clk,
  input  wire               rst_n,
  input  wire               bypass,
  input  wire               enable_p,
  input  wire               din,
  input  wire [11:0]        maxbits,
  output reg                done_p,
  output reg [NBITS-1 :0]   y
);


reg        enable;
reg        sample_sp;
reg        sample_sp_d;
reg [1:0]  shftd_pair;
reg [11:0] cnt;
wire[11:0] maxbits_div2;

wire       enable_loc;

assign maxbits_div2 = {1'b0, maxbits[11:1]};

assign enable_loc = enable | enable_p;

always @ (posedge clk or negedge rst_n) begin
  if (rst_n == 1'b0) begin
    enable <= 1'b0;
    done_p <= 1'b0;
  end
  else begin
    if (enable_p == 1'b1) begin
      enable <=  1'b1;
    end
    else if (cnt < maxbits_div2) begin
      enable <= 1'b0;
      done_p <= 1'b1;
    end
    else begin
      done_p <= 1'b0;
    end
  end
end


always @ (posedge clk or negedge rst_n) begin
  if (rst_n == 1'b0) begin
    shftd_pair <= 2'b0;
  end
  else begin
    if (enable_loc == 1'b1) begin
      shftd_pair <= {din, shftd_pair[1]};
    end
    else begin
      shftd_pair <= 2'b0;
    end
  end
end

always @ (posedge clk or negedge rst_n) begin
  if (rst_n == 1'b0) begin
    sample_sp   <= 1'b0;
    sample_sp_d <= 1'b0;
  end
  else begin
    if (enable_loc == 1'b1) begin
      sample_sp   <= ~sample_sp;
      sample_sp_d <=  sample_sp;
    end
    else begin
      sample_sp   <= 1'b0;
      sample_sp_d <= 1'b0;
    end
  end
end



always @ (posedge clk or negedge rst_n) begin
  if (rst_n == 1'b0) begin
    cnt   <= 11'b0;
    y     <= {NBITS{1'b0}};
  end
  else begin
    if (enable_loc == 1'b1) begin
      if (bypass == 1'b1) begin
        cnt <= cnt + 1'b1;
        y   <= {din, y[NBITS-1 :1]};
      end
      else if ((sample_sp_d == 1'b1) && (^shftd_pair == 1'b1)) begin
        cnt <= cnt + 1'b1;
        y   <= {shftd_pair[0], y[NBITS-1 :1]};
      end
    end
    else begin
      cnt   <= 11'b0;
      y     <= {NBITS{1'b0}};
    end
  end
end

endmodule

//trng_wrap
module trng_wrap (
  input   wire clk,
  input   wire rst_n,
  input   wire en,
  output  wire y
);

wire [14:0] y_loc;

genvar i;

assign y = ^y_loc;

generate
  for (i = 0; i < 15; i= i + 1) begin : trng_inst
    trng #(
      .trng_delay (i))
      u_trng_inst (
      .clk    (clk),
      .rst_n  (rst_n),
      .en     (en),
      .y      (y_loc[i])
    );
  end
endgenerate

endmodule


//Sub Module of random_num_gen 
module trng #(  parameter trng_delay = 3)(
  input   wire clk,
  input   wire rst_n,
  input   wire en,
  output  wire y
);


  wire inv1_a;
  wire inv1_y;
  wire inv2_a;
  wire inv2_y;

  reg  trng_sync1;
  reg  trng_sync2;
  reg  trng_sync3;

`ifdef RANDSIM
  reg [31 :0] rand_sim;
  always @ (posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      rand_sim = 32'b0;
    end
    else begin
      rand_sim = $random;
    end
  end
`endif  
  
  
  assign #trng_delay inv1_y = ~inv1_a;
  //assign #trng_delay inv1_a = en ? inv2_y : inv1_y;
  chiplib_mux2 u_trng_mux1_inst (
    .a (inv1_y),
    .b (inv2_y),
    .s (en),
    .y (inv1_a)
  );

  assign #trng_delay inv2_y = ~inv2_a;
  //assign #trng_delay inv2_a = en ? inv1_y : inv2_y;
  chiplib_mux2 u_trng_mux2_inst (
      .a (inv2_y),
      .b (inv1_y),
      .s (en),
      .y (inv2_a)
    );


  always @ (posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      trng_sync1 <= 1'b0;
      trng_sync2 <= 1'b0;
      trng_sync3 <= 1'b0;
    end
    else begin
`ifdef RANDSIM
      trng_sync1 <= rand_sim[0];
`else
      trng_sync1 <= inv1_y;
`endif
      trng_sync2 <= trng_sync1;
      trng_sync3 <= trng_sync2;
    end
  end
     assign y = trng_sync3;

endmodule



module chiplib_mux2 ( 
  input  a,
  input  b,
  input  s,
  output y
  );

`ifdef FPGA_SYNTH
assign y = (s == 1'b1) ? b : a;
`else
  MX2_X4M_A9TH u_DONT_TOUCH_mux2_inst (     .A   (a),
     .B   (b),
     .Y   (y),
     .S0  (s)
  );
`endif


endmodule

module chiplib_mux3 ( 
  input        a,
  input        b,
  input        c,
  input  [1:0] s,
  output       y
  );

`ifdef FPGA_SYNTH
assign y = (s == 2'b10) ? c : ((s == 2'b01) ? b : a);
`else
  MX2_X4M_A9TH u_DONT_TOUCH_mux2_inst0 (
     .A   (a),
     .B   (b),
     .Y   (y_int),
     .S0  (s[0])
  );

  MX2_X4M_A9TH u_DONT_TOUCH_mux2_inst1 (
     .A   (y_int),
     .B   (c),
     .Y   (y),
     .S0  (s[1])
  );
`endif

endmodule


module chiplib_mux4 ( 
  input        a,
  input        b,
  input        c,
  input        d,
  input  [1:0] s,
  output       y
  );

`ifdef FPGA_SYNTH
assign y = (s == 2'b11) ? d : ((s == 2'b10) ? c : ((s == 2'b01) ? b : a));
`else
  MX2_X4M_A9TH u_DONT_TOUCH_mux2_inst0 (
     .A   (a),
     .B   (b),
     .Y   (y_int1),
     .S0  (s[0])
  );

  MX2_X4M_A9TH u_DONT_TOUCH_mux2_inst1 (
     .A   (c),
     .B   (d),
     .Y   (y_int2),
     .S0  (s[0])
  );

  MX2_X4M_A9TH u_DONT_TOUCH_mux2_inst2 ( .A(y_int1),     .B (y_int2), .Y   (y),.S0  (s[1]) );

`endif


endmodule

module MX2_X4M_A9TH (
  input  A,
  input  B,
  output Y,
  input  S0
);

  assign Y = (S0 == 1'b1) ? B : A;

endmodule
