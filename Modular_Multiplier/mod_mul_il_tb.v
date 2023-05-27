
`timescale 1 ns/1 ps
module mod_mul_il_tb;

  // Parameters
  parameter NBITS = 256;
  
  // Inputs
  reg clk;
  reg rst_n;
  reg enable_p;
  reg [NBITS-1:0] a;
  reg [NBITS-1:0] b;
  reg [NBITS-1:0] m;
  
  // Outputs
  wire [NBITS-1:0] y;
  wire done_irq_p;
  
  initial begin
$dumpfile("dump.vcd");
$dumpvars(1);
end

  
  // Instantiate the module under test
  mod_mul_il #(
    .NBITS(NBITS)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .enable_p(enable_p),
    .a(a),
    .b(b),
    .m(m),
    .y(y),
    .done_irq_p(done_irq_p)
  );
  
  // Clock generation
  always #5 clk = ~clk;
  
  // Initialize inputs
  initial begin
    clk = 0;
    rst_n = 1;
    enable_p = 0;
    a = 0;
    b = 0;
    m = 0;
    
    #10;
    
    // Test case 1: Perform modular multiplication
    rst_n = 0;
    #5;
    rst_n = 1;
    enable_p = 1;
    a = 15; // Example input value
    b = 7; // Example input value
    m = 10; // Example modulo value
    
    #10;
    
    // Test case 2: Perform another modular multiplication
    enable_p = 1;
    a = 21; // Example input value
    b = 3; // Example input value
    m = 8; // Example modulo value
    
    #10;
    
    // Add more test cases as needed
    
    // End simulation
    $finish;
  end

endmodule

