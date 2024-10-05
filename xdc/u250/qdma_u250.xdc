
#----------------- PCIe signals -------------------
#PCIE_PERSTN Active low input from PCIe Connector to Ultrascale+ Device to detect presence.
set_property -dict {PACKAGE_PIN BD21 IOSTANDARD LVCMOS12} [get_ports pcie_perstn]; # Bank 64 VCCO - VCC1V2 Net "PCIE_PERST_LS" - IO_L23P_T3U_N8_64
set_property PACKAGE_PIN AM10                 [get_ports pcie_refclk_clk_n]; # Bank 226 Net "PEX_REFCLK_C_N" - MGTREFCLK0N_226
set_property PACKAGE_PIN AM11                 [get_ports pcie_refclk_clk_p]; # Bank 226 Net "PEX_REFCLK_C_P" - MGTREFCLK0P_226
create_clock -period 10.000 -name pcie_refclk [get_ports pcie_refclk_clk_p]

# set_property PACKAGE_PIN AF1 [get_ports pci_express_x16_rxn[0]  ]; # Bank 227  - MGTYRXN3_227
# set_property PACKAGE_PIN AF2 [get_ports pci_express_x16_rxp[0]  ]; # Bank 227  - MGTYRXP3_227
# set_property PACKAGE_PIN AG3 [get_ports pci_express_x16_rxn[1]  ]; # Bank 227  - MGTYRXN2_227
# set_property PACKAGE_PIN AG4 [get_ports pci_express_x16_rxp[1]  ]; # Bank 227  - MGTYRXP2_227
# set_property PACKAGE_PIN AH1 [get_ports pci_express_x16_rxn[2]  ]; # Bank 227  - MGTYRXN1_227
# set_property PACKAGE_PIN AH2 [get_ports pci_express_x16_rxp[2]  ]; # Bank 227  - MGTYRXP1_227
# set_property PACKAGE_PIN AJ3 [get_ports pci_express_x16_rxn[3]  ]; # Bank 227  - MGTYRXN0_227
# set_property PACKAGE_PIN AJ4 [get_ports pci_express_x16_rxp[3]  ]; # Bank 227  - MGTYRXP0_227
# set_property PACKAGE_PIN AF6 [get_ports pci_express_x16_txn[0]  ]; # Bank 227  - MGTYTXN3_227
# set_property PACKAGE_PIN AF7 [get_ports pci_express_x16_txp[0]  ]; # Bank 227  - MGTYTXP3_227
# set_property PACKAGE_PIN AG8 [get_ports pci_express_x16_txn[1]  ]; # Bank 227  - MGTYTXN2_227
# set_property PACKAGE_PIN AG9 [get_ports pci_express_x16_txp[1]  ]; # Bank 227  - MGTYTXP2_227
# set_property PACKAGE_PIN AH6 [get_ports pci_express_x16_txn[2]  ]; # Bank 227  - MGTYTXN1_227
# set_property PACKAGE_PIN AH7 [get_ports pci_express_x16_txp[2]  ]; # Bank 227  - MGTYTXP1_227
# set_property PACKAGE_PIN AJ8 [get_ports pci_express_x16_txn[3]  ]; # Bank 227  - MGTYTXN0_227
# set_property PACKAGE_PIN AJ9 [get_ports pci_express_x16_txp[3]  ]; # Bank 227  - MGTYTXP0_227
# set_property PACKAGE_PIN AK1 [get_ports pci_express_x16_rxn[4]  ]; # Bank 226  - MGTYRXN3_226
# set_property PACKAGE_PIN AK2 [get_ports pci_express_x16_rxp[4]  ]; # Bank 226  - MGTYRXP3_226
# set_property PACKAGE_PIN AL3 [get_ports pci_express_x16_rxn[5]  ]; # Bank 226  - MGTYRXN2_226
# set_property PACKAGE_PIN AL4 [get_ports pci_express_x16_rxp[5]  ]; # Bank 226  - MGTYRXP2_226
# set_property PACKAGE_PIN AM1 [get_ports pci_express_x16_rxn[6]  ]; # Bank 226  - MGTYRXN1_226
# set_property PACKAGE_PIN AM2 [get_ports pci_express_x16_rxp[6]  ]; # Bank 226  - MGTYRXP1_226
# set_property PACKAGE_PIN AN3 [get_ports pci_express_x16_rxn[7]  ]; # Bank 226  - MGTYRXN0_226
# set_property PACKAGE_PIN AN4 [get_ports pci_express_x16_rxp[7]  ]; # Bank 226  - MGTYRXP0_226
# set_property PACKAGE_PIN AK6 [get_ports pci_express_x16_txn[4]  ]; # Bank 226  - MGTYTXN3_226
# set_property PACKAGE_PIN AK7 [get_ports pci_express_x16_txp[4]  ]; # Bank 226  - MGTYTXP3_226
# set_property PACKAGE_PIN AL8 [get_ports pci_express_x16_txn[5]  ]; # Bank 226  - MGTYTXN2_226
# set_property PACKAGE_PIN AL9 [get_ports pci_express_x16_txp[5]  ]; # Bank 226  - MGTYTXP2_226
# set_property PACKAGE_PIN AM6 [get_ports pci_express_x16_txn[6]  ]; # Bank 226  - MGTYTXN1_226
# set_property PACKAGE_PIN AM7 [get_ports pci_express_x16_txp[6]  ]; # Bank 226  - MGTYTXP1_226
# set_property PACKAGE_PIN AN8 [get_ports pci_express_x16_txn[7]  ]; # Bank 226  - MGTYTXN0_226
# set_property PACKAGE_PIN AN9 [get_ports pci_express_x16_txp[7]  ]; # Bank 226  - MGTYTXP0_226
# set_property PACKAGE_PIN AT1 [get_ports pci_express_x16_rxn[10] ]; # Bank 225  - MGTYRXN1_225
# set_property PACKAGE_PIN AT2 [get_ports pci_express_x16_rxp[10] ]; # Bank 225  - MGTYRXP1_225
# set_property PACKAGE_PIN AU3 [get_ports pci_express_x16_rxn[11] ]; # Bank 225  - MGTYRXN0_225
# set_property PACKAGE_PIN AU4 [get_ports pci_express_x16_rxp[11] ]; # Bank 225  - MGTYRXP0_225
# set_property PACKAGE_PIN AP1 [get_ports pci_express_x16_rxn[8]  ]; # Bank 225  - MGTYRXN3_225
# set_property PACKAGE_PIN AP2 [get_ports pci_express_x16_rxp[8]  ]; # Bank 225  - MGTYRXP3_225
# set_property PACKAGE_PIN AR3 [get_ports pci_express_x16_rxn[9]  ]; # Bank 225  - MGTYRXN2_225
# set_property PACKAGE_PIN AR4 [get_ports pci_express_x16_rxp[9]  ]; # Bank 225  - MGTYRXP2_225
# set_property PACKAGE_PIN AT6 [get_ports pci_express_x16_txn[10] ]; # Bank 225  - MGTYTXN1_225
# set_property PACKAGE_PIN AT7 [get_ports pci_express_x16_txp[10] ]; # Bank 225  - MGTYTXP1_225
# set_property PACKAGE_PIN AU8 [get_ports pci_express_x16_txn[11] ]; # Bank 225  - MGTYTXN0_225
# set_property PACKAGE_PIN AU9 [get_ports pci_express_x16_txp[11] ]; # Bank 225  - MGTYTXP0_225
# set_property PACKAGE_PIN AP6 [get_ports pci_express_x16_txn[8]  ]; # Bank 225  - MGTYTXN3_225
# set_property PACKAGE_PIN AP7 [get_ports pci_express_x16_txp[8]  ]; # Bank 225  - MGTYTXP3_225
# set_property PACKAGE_PIN AR8 [get_ports pci_express_x16_txn[9]  ]; # Bank 225  - MGTYTXN2_225
# set_property PACKAGE_PIN AR9 [get_ports pci_express_x16_txp[9]  ]; # Bank 225  - MGTYTXP2_225
# set_property PACKAGE_PIN AV1 [get_ports pci_express_x16_rxn[12] ]; # Bank 224  - MGTYRXN3_224
# set_property PACKAGE_PIN AV2 [get_ports pci_express_x16_rxp[12] ]; # Bank 224  - MGTYRXP3_224
# set_property PACKAGE_PIN AW3 [get_ports pci_express_x16_rxn[13] ]; # Bank 224  - MGTYRXN2_224
# set_property PACKAGE_PIN AW4 [get_ports pci_express_x16_rxp[13] ]; # Bank 224  - MGTYRXP2_224
# set_property PACKAGE_PIN BA1 [get_ports pci_express_x16_rxn[14] ]; # Bank 224  - MGTYRXN1_224
# set_property PACKAGE_PIN BA2 [get_ports pci_express_x16_rxp[14] ]; # Bank 224  - MGTYRXP1_224
# set_property PACKAGE_PIN BC1 [get_ports pci_express_x16_rxn[15] ]; # Bank 224  - MGTYRXN0_224
# set_property PACKAGE_PIN BC2 [get_ports pci_express_x16_rxp[15] ]; # Bank 224  - MGTYRXP0_224
# set_property PACKAGE_PIN AV6 [get_ports pci_express_x16_txn[12] ]; # Bank 224  - MGTYTXN3_224
# set_property PACKAGE_PIN AV7 [get_ports pci_express_x16_txp[12] ]; # Bank 224  - MGTYTXP3_224
# set_property PACKAGE_PIN BB4 [get_ports pci_express_x16_txn[13] ]; # Bank 224  - MGTYTXN2_224
# set_property PACKAGE_PIN BB5 [get_ports pci_express_x16_txp[13] ]; # Bank 224  - MGTYTXP2_224
# set_property PACKAGE_PIN BD4 [get_ports pci_express_x16_txn[14] ]; # Bank 224  - MGTYTXN1_224
# set_property PACKAGE_PIN BD5 [get_ports pci_express_x16_txp[14] ]; # Bank 224  - MGTYTXP1_224
# set_property PACKAGE_PIN BF4 [get_ports pci_express_x16_txn[15] ]; # Bank 224  - MGTYTXN0_224
# set_property PACKAGE_PIN BF5 [get_ports pci_express_x16_txp[15] ]; # Bank 224  - MGTYTXP0_224


#--------------------------------------------
# Specifying the placement of PCIe clock domain modules into single SLR to facilitate routing
# https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_1/ug912-vivado-properties.pdf#page=386
#Collecting all units from correspondingly PCIe domain,
set pcie_clk_units [get_cells -of_objects [get_nets -of_objects [get_pins -hierarchical qdma_0/axi_aclk]]]
#Setting specific SLR to which PCIe pins are wired since placer may miss it if just "group_name" is applied
set_property USER_SLR_ASSIGNMENT SLR1 [get_cells "$pcie_clk_units"]

## ================================
#----------------- QDMA CDC -------------------
# Timing constraints for clock domains crossings (CDC) for at least 1st system synthesized clock
set qdma_clk [get_clocks -of_objects [get_pins -hierarchical qdma_0/axi_aclk]]
set sys1_clk [get_clocks -of_objects [get_pins -hierarchical clk_wiz_1/clk_out1]]
# set_false_path -from $xxx_clk -to $yyy_clk
# controlling resync paths to be less than source clock period
# (-datapath_only to exclude clock paths)
set_max_delay -datapath_only -from $qdma_clk -to $sys1_clk [expr [get_property -min period $qdma_clk] * 0.9]
set_max_delay -datapath_only -from $sys1_clk -to $qdma_clk [expr [get_property -min period $sys1_clk] * 0.9]

#----------------- PCIe JTAG CDC -------------------
# Timing constraints for clock domains crossings (CDC) for at least 1st system synthesized clock
# JTAG clock got from QDMA AXI clock inside debug_bridge isn't of clock type by default and is 8 times slower
create_clock -period [expr [get_property -min period $qdma_clk] * 8] -name PCIE_JTCK [get_pins -hierarchical jtag_tck_buf/BUFG_O]
set pci_jtck [get_clocks -of_objects [get_pins -hierarchical jtag_tck_buf/BUFG_O]]
# set_false_path -from $xxx_clk -to $yyy_clk
# controlling resync paths to be less than source clock period
# (-datapath_only to exclude clock paths)
# For JTAG clock we consider both edges
set_max_delay -datapath_only -from $sys1_clk -to $pci_jtck [expr [get_property -min period $sys1_clk] * 0.9    ]
set_max_delay -datapath_only -from $pci_jtck -to $sys1_clk [expr [get_property -min period $pci_jtck] * 0.9 / 2]
#--------------------------------------------

#----------------- SDRAM CDC -------------------
# Timing constraints for CDC in SDRAM user interface with at least 1st system synthesized clock,
# particularly in HBM APB which is disabled but clocked by fixed external clock
set mref_clk [get_clocks -of_objects [get_ports sysclk0_clk_p]]
# set_false_path -from $xxx_clk -to $yyy_clk
# controlling resync paths to be less than source clock period
# (-datapath_only to exclude clock paths)
set_max_delay -datapath_only -from $sys1_clk -to $mref_clk [expr [get_property -min period $sys1_clk] * 0.9]
set_max_delay -datapath_only -from $mref_clk -to $sys1_clk [expr [get_property -min period $mref_clk] * 0.9]
