//wrapper module that interfaces with four other sub-modules
module montgomery_wrap #(
  parameter NBITS = 256
 ) (
  input               clk,
  input               rst_n,
  input               enable_p,
  input  [NBITS-1 :0] a,
  input  [NBITS-1 :0] b,
  input  [NBITS-1 :0] m,
  input  [10      :0] m_size,
  input  [NBITS-1 :0] r_red,
  output [NBITS-1 :0] y,
  output              done_irq_p
);


wire [NBITS-1 :0] a_conv ;
wire [NBITS-1 :0] b_conv ;
wire [NBITS-1 :0] y_inter ;

montgomery_to_conv #(
  .NBITS (NBITS)
 ) u_montgomery_to_conv_a_inst (
  .clk               (clk),             //input               
  .rst_n             (rst_n),           //input               
  .enable_p          (enable_p),        //input               
  .a                 (a),               //input  [NBITS-1 :0] 
  .m                 (m),               //input  [NBITS-1 :0] 
  .r_red             (r_red),           //input  [NBITS-1 :0] 
  .y                 (a_conv),          //output [NBITS-1 :0] 
  .done_irq_p        (done_irq_p_a)     //output              
);

montgomery_to_conv #(
  .NBITS (NBITS)
 ) u_montgomery_to_conv_b_inst (
  .clk               (clk),             //input               
  .rst_n             (rst_n),           //input               
  .enable_p          (done_irq_p_a),    //input               
  .a                 (b),               //input  [NBITS-1 :0] 
  .m                 (m),               //input  [NBITS-1 :0] 
  .r_red             (r_red),           //input  [NBITS-1 :0] 
  .y                 (b_conv),          //output [NBITS-1 :0] 
  .done_irq_p        (done_irq_p_b)     //output              
);


montgomery_mul #(
  .NBITS (NBITS)
 ) u_montgomery_mul_inst (
  .clk               (clk),             //input               
  .rst_n             (rst_n),           //input               
  .enable_p          (done_irq_p_b),    //input               
  .a                 (a_conv),          //input  [NBITS-1 :0] 
  .b                 (b_conv),          //input  [NBITS-1 :0] 
  .m                 (m),               //input  [NBITS-1 :0] 
  .m_size            (m_size),          //input  [10      :0] 
  .y                 (y_inter),         //output [NBITS-1 :0] 
  .done_irq_p        (done_irq_p_mul)   //output              
);



montgomery_from_conv #(
   .NBITS (NBITS)
 ) u_montgomery_from_conv (
  .clk               (clk),                    //input               
  .rst_n             (rst_n),                  //input               
  .enable_p          (done_irq_p_mul),         //input               
  .a                 (y_inter),                //input  [NBITS-1 :0] 
  .m                 (m),                      //input  [NBITS-1 :0] 
  .m_size            (m_size),                 //input  [10      :0] 
  .y                 (y),                      //output [NBITS-1 :0] 
  .done_irq_p        (done_irq_p)              //output              
);

endmodule


module montgomery_to_conv #(
  parameter NBITS = 256
 ) (
  input               clk,
  input               rst_n,
  input               enable_p,
  input  [NBITS-1 :0] a,
  input  [NBITS-1 :0] m,
  input  [NBITS-1 :0] r_red,
  output [NBITS-1 :0] y,
  output              done_irq_p
);

 mod_mul_il #(
  .NBITS (NBITS)
 ) u_mod_mul_il_inst (
  .clk               (clk),                    //input               
  .rst_n             (rst_n),                  //input               
  .enable_p          (enable_p),               //input               
  .a                 (a),                      //input  [NBITS-1 :0] 
  .b                 (r_red),                  //input  [NBITS-1 :0] 
  .m                 (m),                      //input  [NBITS-1 :0] 
  .y                 (y),                      //output [NBITS-1 :0] 
  .done_irq_p        (done_irq_p)              //output              
);

endmodule


module montgomery_mul #(
  parameter NBITS = 256
 ) (
  input               clk,
  input               rst_n,
  input               enable_p,
  input  [NBITS-1 :0] a,
  input  [NBITS-1 :0] b,
  input  [NBITS-1 :0] m,
  input  [11      :0] m_size,
  output [NBITS-1 :0] y,
  output              done_irq_p
);


//reg/wire declaration


reg [NBITS   :0] y_loc;
reg [NBITS-1 :0] a_loc;
reg              done_irq_p_loc;
reg              done_irq_p_loc_d;
reg [11      :0] m_size_cnt;


wire [NBITS+1 :0] b_loc_mul_a_loc_i ;
wire [NBITS+1 :0] y_loc_for_red ;
  
//--------------------------------------
//a*b*(2^-n) mod m
//--------------------------------------

//assign b_loc_mul_a_loc_i    = b*a_loc[0] + y_loc;
assign b_loc_mul_a_loc_i    = a_loc[0] ? (b + y_loc) : y_loc;
assign y_loc_for_red        = (b_loc_mul_a_loc_i[0] == 1'b1) ? (b_loc_mul_a_loc_i + m ) : b_loc_mul_a_loc_i;

always @ (posedge clk or negedge rst_n) begin
  if (rst_n == 1'b0) begin
    y_loc          <= {(NBITS+1){1'b0}};
    a_loc          <= {NBITS{1'b1}};
    done_irq_p_loc <= 1'b0;
  end
  else begin
    if (enable_p == 1'b1) begin
      a_loc          <= a;
      y_loc          <= {(NBITS+1){1'b0}};
      done_irq_p_loc <= 1'b0;
    end
    else if (|m_size_cnt[11:0]) begin
      y_loc <= {y_loc_for_red[NBITS+1 :1]};
      a_loc <= {1'b0, a_loc[NBITS-1 :1]};
    end 
    else begin
      if (y_loc >= m) begin
        y_loc <= y_loc - m;
      end
      else begin
        done_irq_p_loc <= 1'b1;
      end
    end
  end
end

  
  always @ (posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      m_size_cnt    <= 12'b0;
    end
    else begin
      if (enable_p == 1'b1) begin
        m_size_cnt    <= m_size;
      end
      else if (|m_size_cnt[11:0]) begin
        m_size_cnt    <= m_size_cnt-1'b1;//(Ex for 2048 bits, one need to count form 0 to 2047)
      end
    end
  end

  
  always @ (posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      done_irq_p_loc_d  <= 1'b0;
    end
    else begin
      done_irq_p_loc_d  <= done_irq_p_loc  ;
    end
  end



  assign done_irq_p =  done_irq_p_loc & ~done_irq_p_loc_d;
  assign y          =  y_loc[NBITS-1 :0];



endmodule
module montgomery_from_conv #(  parameter NBITS = 256 ) (
  input               clk,
  input               rst_n,
  input               enable_p,
  input  [NBITS-1 :0] a,
  input  [NBITS-1 :0] m,
  input  [11      :0] m_size,
  output [NBITS-1 :0] y,
  output              done_irq_p
);

montgomery_mul #(  .NBITS (NBITS) ) u_montgomery_mul_inst (
  .clk               (clk),             //input               
  .rst_n             (rst_n),           //input               
  .enable_p          (en_montgomery_mul_p),    //input               
  .a                 (a_loc),          //input  [NBITS-1 :0] 
  .b                 (b_loc),          //input  [NBITS-1 :0] 
  .m                 (m),               //input  [NBITS-1 :0] 
  .m_size            (m_size),          //input  [10      :0] 
  .y                 (y_inter),         //output [NBITS-1 :0] 
  .done_irq_p        (done_irq_p_mul)   //output              
);
endmodule

//----------------------------------------

module mod_mul_il #(
  parameter NBITS = 256
 ) (
  input               clk,
  input               rst_n,
  input               enable_p,
  input  [NBITS-1 :0] a,
  input  [NBITS-1 :0] b,
  input  [NBITS-1 :0] m,
  output [NBITS-1 :0] y,
  output              done_irq_p
);

//reg/wire declaration


reg  [NBITS-1 :0] a_loc;
reg  [NBITS-1 :0] y_loc;
reg  [NBITS   :0] b_loc;
reg               done_irq_p_loc;
reg               done_irq_p_loc_d;

wire [NBITS   :0] y_loc_accum;
wire [NBITS   :0] y_loc_accum_red;
wire [NBITS-1 :0] b_loc_red;


//calculate (a*b)%m
assign b_loc_red        = (b_loc > m) ? (b_loc - m) : b_loc;
//assign y_loc_accum      =  b_loc_red*a_loc[0] + y_loc;
assign y_loc_accum      =  a_loc[0] ? (b_loc_red + y_loc) : y_loc;
assign y_loc_accum_red  = (y_loc_accum >= m)   ?  (y_loc_accum -  m) :
                           y_loc_accum ;

always @ (posedge clk or negedge rst_n) begin
  if (rst_n == 1'b0) begin
    y_loc <= {NBITS{1'b0}};
    a_loc <= {NBITS{1'b0}};
    b_loc <= {(NBITS+1){1'b0}};
  end
  else begin
      if (enable_p == 1'b1) begin
        a_loc <= {1'b0, a[NBITS-1 :1]};
        b_loc <= {b, 1'b0};
        if (a[0] == 1'b1) begin
          y_loc <= b;
        end
        else begin
          y_loc <= {NBITS{1'b0}};
        end
      end
      else if (|a_loc) begin
        y_loc <= y_loc_accum_red[NBITS-1 :0];
        b_loc <= {b_loc_red, 1'b0};
        a_loc <= {1'b0, a_loc[NBITS-1:1]};
      end 
  end
end

  
  always @ (posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      done_irq_p_loc    <= 1'b0;
      done_irq_p_loc_d  <= 1'b0;
    end
    else begin
      done_irq_p_loc    <= |a_loc | enable_p;  //enable_p for the case a == 1
      done_irq_p_loc_d  <= done_irq_p_loc  ;
    end
  end
  
  assign done_irq_p =  done_irq_p_loc_d & ~done_irq_p_loc;
  assign y          =  y_loc;
endmodule

