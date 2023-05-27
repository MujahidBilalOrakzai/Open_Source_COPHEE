# Project_COPHEE
CoPHEE
CoPHEE is a Co-processor for Partially Homomorphic Encrypted Encryption. CoPHEE assists the host processor with the calculation of big number modular arithmetic like modular multiplication, modular exponentiation, and modular inverse, for operand size 64-bit to 2048-bit. In addition, it calculates the greatest common divisor (GCD) of two numbers and generates random numbers. The host processor communicates with CoPHEE through a UART interface. CoPHEE will be designed under  (130nm Globalfoundry) Process and a 256-bit version will be loaded on an FPGA (Arty 35T FPGA).

Copyright (c) 2019 Michail Maniatakos, New York University Abu Dhabi, https://wp.nyu.edu/momalab/

Final Set of RTL Files:

#Uart Master ./modules/uartm/rtl/uartm.v ./modules/uartm/rtl/uartm_ahb.v ./modules/uartm/rtl/uartm_rx.v ./modules/uartm/rtl/uartm_tx.v

#Chip Configuration Space ./modules/gpcfg/rtl/gpcfg_rd.v ./modules/gpcfg/rtl/gpcfg_rd_wr.v ./modules/gpcfg/rtl/gpcfg_rd_wr_p.v ./modules/gpcfg/rtl/hw_rng_fsm.v ./modules/gpcfg/rtl/gpcfg.v

#Modular Interleaved Multiplier ./modules/crypto_lib/rtl/mod_mul_il.v

#Montgomery Multiplier ./modules/crypto_lib/rtl/montgomery_to_conv.v ./modules/crypto_lib/rtl/montgomery_mul.v ./modules/crypto_lib/rtl/montgomery_from_conv.v

#Modular Inverse/Binary Exended GCD ./modules/crypto_lib/rtl/bin_ext_gcd.v

#Modular Exponentiation ./modules/gpcfg/rtl/mod_exp.v

#TRNG ./modules/crypto_lib/rtl/trng_wrap.v ./modules/crypto_lib/rtl/trng.v ./modules/crypto_lib/rtl/random_num_gen.v ./modules/crypto_lib/rtl/vn_corrector.v

#UART SLAVE ./modules/uarts/rtl/uarts.v ./modules/uarts/rtl/uarts_tx.v ./modules/uarts/rtl/uarts_rx.v

