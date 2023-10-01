# Project_COPHEE
CoPHEE is a Co-processor for Partially Homomorphic Encrypted Encryption. CoPHEE assists the host processor with the calculation of big number modular arithmetic like modular multiplication, modular exponentiation, and modular inverse, for operand size 64-bit to 2048-bit. In addition, it calculates the greatest common divisor (GCD) of two numbers and generates random numbers. The host processor communicates with CoPHEE through a UART interface. CoPHEE will be designed under  (130nm Globalfoundry) Process and a 256-bit version will be loaded on an FPGA (Arty 35T FPGA).

Copyright (c) 2019 Michail Maniatakos, New York University Abu Dhabi, https://wp.nyu.edu/momalab/

**Set of Encryption Module (RTL) Files:**

#Modular Interleaved Multiplier 
Top File./Modular_Multiplier/mod_mul_il.v

#Modular Inverse/Binary Exended GCD 
Top File./GCD/bin_ext_gcd.v

#Montgomery Multiplier
Top File./Montgomery_Multiplication/montgomery_mul.v
./Montgomery_Multiplication/Sub_Modules/mod_mul_il.v
./Montgomery_Multiplication/Sub_Modules/montgomery_from_conv.v
./Montgomery_Multiplication/Sub_Modules/montgomery_mul.v
./Montgomery_Multiplication/Sub_Modules/montgomery_to_conv.v

#Modular Exponentiation 
Top File./Modular_Exponentiation/mod_exp.v
./Modular_Exponentiation/Sub_Modules/mod_mul_il.v
./Modular_Exponentiation/Sub_Modules/montgomery_from_conv.v
./Modular_Exponentiation/Sub_Modules/montgomery_mul.v
./Modular_Exponentiation/Sub_Modules/montgomery_to_conv.v

#TRNG 
Top File./Random Number Generation/random_num_gen.v
Random Number Generation/Sub_Modules/chiplib_mux.v
Random Number Generation/Sub_Modules/trng.v
Random Number Generation/Sub_Modules/trng_wrap.v
Random Number Generation/Sub_Modules/vn_corrector.v

#Montgomery wrap
Top File./Montgomery_wrap/montgomery_wrap.v
./Montgomery_wrap/Sub_Modules/mod_mul_il.v
./Montgomery_wrap/Sub_Modules/montgomery_from_conv.v
./Montgomery_wrap/Sub_Modules/montgomery_mul.v
./Montgomery_wrap/Sub_Modules/montgomery_to_conv.v

**Set of Encryption Module Verification(Test Bench) Files:**

#Modular Interleaved Multiplier./Modular_Multiplier/mod_mul_il_tb.v
**EDA Playground Simulation:** https://edaplayground.com/x/qaZi

#Modular Inverse/Binary Exended GCD GCD/bin_ext_gcd_tb.v
**EDA Playground Simulation:** https://edaplayground.com/x/i7E6

#Montgomery Multiplier  Montgomery_Multiplication/montgomery_mul_tb.v
**EDA Playground Simulation:** https://edaplayground.com/x/Fe5B

#Montgomery wrap   ./Montgomery_wrap/montgomery_wrap_tb.v
**EDA Playground Simulation:** https://edaplayground.com/x/An4h

#Modular Exponentiation   ./Modular_Exponentiation/mod_exp_tb.v
**EDA Playground Simulation:** https://edaplayground.com/x/QHXM

#TRNG   ./Random Number Generation/random_num_gen_tb.v
**EDA Playground Simulation:** https://edaplayground.com/x/VgKD
