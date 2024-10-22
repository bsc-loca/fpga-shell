# Bitstream Configuration                                                 
# ------------------------------------------------------------------------
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes [current_design]

#----------------- System Clock -------------------
#    2) SI335A - SiLabs SI5335A-B06201-GM Selectable output Oscillator 156.2500Mhz/161.1328125Mhz For QSFP0 REFCLK1
#
#      - OUT0--> SYSCLK_300_P/SYSCLK_300_N @ 300.0000Mhz to 1-to-4 Clock buffer (Fixed and Unchanged by FS[1:0])
#           |
#           |--> SI53340-B-GM --> OUT0  SYSCLK0_300_P/SYSCLK0_300_N 300.000Mhz - System Clock for first DDR4 MIG interface
#                             |   PINS: IO_L13P_T2L_N0_GC_QBC_63_AY37/IO_L13N_T2L_N1_GC_QBC_63_AY38
#                             |
#                             |-> OUT1  SYSCLK1_300_P/SYSCLK1_300_N 300.000Mhz - System Clock for second DDR4 MIG interface.
#                             |   PINS: IO_L11P_T1U_N8_GC_64_AW20/IO_L11N_T1U_N9_GC_64_AW19
#                             |
#                             |-> OUT2  SYSCLK2_300_P/SYSCLK2_300_N 300.000Mhz - System Clock for third DDR4 MIG interface.
#                             |   PINS: IO_L13P_T2L_N0_GC_QBC_70_F32/IO_L13N_T2L_N1_GC_QBC_70_E32
#                             |
#                             |-> OUT3  SYSCLK3_300_P/SYSCLK3_300_N 300.000Mhz - System Clock for fourth DDR4 MIG interface.
#                                 PINS: IO_L13P_T2L_N0_GC_QBC_72_J16/IO_L13N_T2L_N1_GC_QBC_72_H16
#
# set_property -dict {PACKAGE_PIN AY38 IOSTANDARD DIFF_POD12_DCI } [get_ports SYSCLK0_300_N    ]; # Bank 42 VCCO - VCC1V2 Net "SYSCLK0_300_N" - IO_L13N_T2L_N1_GC_QBC_42
# set_property -dict {PACKAGE_PIN AY37 IOSTANDARD DIFF_POD12_DCI } [get_ports SYSCLK0_300_P    ]; # Bank 42 VCCO - VCC1V2 Net "SYSCLK0_300_P" - IO_L13P_T2L_N0_GC_QBC_42
# set_property -dict {PACKAGE_PIN AW19 IOSTANDARD LVDS           } [get_ports SYSCLK1_300_N    ]; # Bank 64 VCCO - VCC1V2 Net "SYSCLK1_300_N" - IO_L11N_T1U_N9_GC_64
# set_property -dict {PACKAGE_PIN AW20 IOSTANDARD LVDS           } [get_ports SYSCLK1_300_P    ]; # Bank 64 VCCO - VCC1V2 Net "SYSCLK1_300_P" - IO_L11P_T1U_N8_GC_64
# set_property -dict {PACKAGE_PIN E32  IOSTANDARD DIFF_POD12_DCI } [get_ports SYSCLK2_300_N    ]; # Bank 47 VCCO - VCC1V2 Net "SYSCLK2_300_N" - IO_L13N_T2L_N1_GC_QBC_47
# set_property -dict {PACKAGE_PIN F32  IOSTANDARD DIFF_POD12_DCI } [get_ports SYSCLK2_300_P    ]; # Bank 47 VCCO - VCC1V2 Net "SYSCLK2_300_P" - IO_L13P_T2L_N0_GC_QBC_47
# set_property -dict {PACKAGE_PIN H16  IOSTANDARD DIFF_POD12_DCI } [get_ports SYSCLK3_300_N    ]; # Bank 70 VCCO - VCC1V2 Net "SYSCLK3_300_N" - IO_L13N_T2L_N1_GC_QBC_70
# set_property -dict {PACKAGE_PIN J16  IOSTANDARD DIFF_POD12_DCI } [get_ports SYSCLK3_300_P    ]; # Bank 70 VCCO - VCC1V2 Net "SYSCLK3_300_P" - IO_L13P_T2L_N0_GC_QBC_70

set_property -dict {PACKAGE_PIN AW19 IOSTANDARD LVDS}           [get_ports sysclk0_clk_n]; # Bank 64 VCCO - VCC1V2 Net "SYSCLK1_300_N" - IO_L11N_T1U_N9_GC_64
set_property -dict {PACKAGE_PIN AW20 IOSTANDARD LVDS}           [get_ports sysclk0_clk_p]; # Bank 64 VCCO - VCC1V2 Net "SYSCLK1_300_P" - IO_L11P_T1U_N8_GC_64

set_property -dict {PACKAGE_PIN E32  IOSTANDARD DIFF_POD12_DCI} [get_ports sysclk1_clk_n]; # Bank 47 VCCO - VCC1V2 Net "SYSCLK2_300_N" - IO_L13N_T2L_N1_GC_QBC_47
set_property -dict {PACKAGE_PIN F32  IOSTANDARD DIFF_POD12_DCI} [get_ports sysclk1_clk_p]; # Bank 47 VCCO - VCC1V2 Net "SYSCLK2_300_P" - IO_L13P_T2L_N0_GC_QBC_47

set_property PACKAGE_PIN AL20      [get_ports resetn ]   			
set_property IOSTANDARD  LVCMOS12  [get_ports resetn ]  

#create_clock is needed in case of passing SYSCLK_0 through diff buffer (for HBM)
#create_clock -period 3.3333 -name SYSCLK_0 [get_ports sysclk0_clk_p]

# The clock below doesn't need to be created as it is fixed to the MMCM and it creates the constraint itself
#create_clock -period 3.3333 -name SYSCLK_1 [get_ports sysclk1_clk_p]
