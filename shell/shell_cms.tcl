# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Solderpad Hardware License v 2.1 (the "License");
# you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
# You may obtain a copy of the License at
# 
#     http://www.solderpad.org/licenses/SHL-2.1
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Author: Joan Teruel Jurado, BSC-CNS
# Date: 02.05.2024
# Description: CMS implementation

#COMMON PARTS FOR CMS 
#EACH ALVEO CARD MAY HAVE A DIFFERENT CMS PORT AND INTERFACE CONNECTIONS SO WE NEED TO DIFFERENTIATE EACH CARD

#Create the CMS, no properties needed
create_bd_cell -type ip -vlnv xilinx.com:ip:cms_subsystem:4.0 cms_subsystem

#We need a aresetn signal which will be connected to a Processor System reset
#Setup the cms_reset
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 cms_reset
connect_bd_net [get_bd_pins cms_reset/ext_reset_in] [get_bd_pins qdma_0/axi_aresetn]
connect_bd_net [get_bd_pins cms_reset/slowest_sync_clk] [get_bd_pins clk_wiz_1/clk_out1]
connect_bd_net [get_bd_pins cms_subsystem/aresetn_ctrl] [get_bd_pins cms_reset/peripheral_aresetn]

#First enable the AXI Lite interface in the qdma IP and increase BAR2 space region
#set_property -dict [list CONFIG.axilite_master_en {true}] $qdma_0
set_property CONFIG.pf0_bar2_size_qdma {512} [get_bd_cells qdma_0]

#Connect with AXI pcie lite interconnect
#First modify interconnect to make space to fit another master
set_property -dict [list CONFIG.NUM_MI [expr $slv_axilite_ninstances + 1]] [get_bd_cells axi_xbar_pcie_lite]  
putmeeps "CMS as slave # $slv_axilite_ninstances"

#Connect M0? aclk and areset signals
connect_bd_net [get_bd_pins axi_xbar_pcie_lite/M0${slv_axilite_ninstances}_ACLK] [get_bd_pins clk_wiz_1/clk_out1]
connect_bd_net [get_bd_pins axi_xbar_pcie_lite/M0${slv_axilite_ninstances}_ARESETN] [get_bd_pins cms_reset/interconnect_aresetn]

#Connect M0? to s_axi_ctrl from CMS
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_xbar_pcie_lite/M0${slv_axilite_ninstances}_AXI] [get_bd_intf_pins cms_subsystem/s_axi_ctrl]

#Create GPIO port  // not valid for U50
make_bd_pins_external  [get_bd_pins cms_subsystem/satellite_gpio]
set_property name satellite_gpio [get_bd_ports satellite_gpio_0]

#Make external UART connection
make_bd_intf_pins_external [get_bd_intf_pins cms_subsystem/satellite_uart]
set_property name satellite_uart [get_bd_intf_ports satellite_uart_0]

#We need a 50Mhz clock for the aclk_ctrl, chipset_clk is connected to clock wizard out 1 which creates a 50Mhz 
connect_bd_net [get_bd_pins cms_subsystem/aclk_ctrl] [get_bd_ports chipset_clk]

#We'll leave the 'interrupt_host' signal unconnected

#At BAR2 we can find at [0x0,0x4000) INFO ROM and at [0x4_0000, 0x8_0000) the CMS reserved space
assign_bd_address -offset 0x40000 -target_address_space /qdma_0/M_AXI_LITE [get_bd_addr_segs cms_subsystem/s_axi_ctrl/Mem] -force

if { ($g_board_part != "u280") || ($g_board_part != "u55c") || ($g_board_part != "u50")} {
  #SPECIFIC IMPLEMENTATION FOR U280/U55C/U50
  putmeeps "CMS enabled for U280/U55C/U50"

  set   fd_mod  [open $g_cms_file    "w"]
  puts $fd_mod "    // CMS"
  puts $fd_mod "    input [0:0]     satellite_uart_rxd    ,"
  puts $fd_mod "    output [0:0]    satellite_uart_txd    ,"

  if {$g_board_part == "u50"} {  
    puts $fd_mod "    input [1:0]     satellite_gpio,"
  } else {
    puts $fd_mod "    input [3:0]     satellite_gpio,"
  }
  close $fd_mod

  #IF in U280 the memory controller taken is not HBM, we must 'fake' HBM inputs, 
  #In the case of U55C or U50 this is not an issue as there is only HBM 
  if {$MemController eq "HBM"} {
    putmeeps "CMS connected to HBM"
    #Connect temp sensors data 1 and 2
    connect_bd_net [get_bd_pins hbm_0/DRAM_0_STAT_TEMP] [get_bd_pins cms_subsystem/hbm_temp_1] 
    connect_bd_net [get_bd_pins hbm_0/DRAM_1_STAT_TEMP] [get_bd_pins cms_subsystem/hbm_temp_2]

    #Connect ored cattrip
    connect_bd_net [get_bd_pins hbm_cattrip_or/Res] [get_bd_pins cms_subsystem/interrupt_hbm_cattrip]
  } elseif {$MemController eq "DDR"} {
    putwarnings "CMS working with DDR"
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gnd_hbmtemp
    set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {6} \
    ] [get_bd_cells gnd_hbmtemp]

    #Connect temp sensors data 1 and 2 to GND
    connect_bd_net [get_bd_pins gnd_hbmtemp/dout] [get_bd_pins cms_subsystem/hbm_temp_1] 
    connect_bd_net [get_bd_pins gnd_hbmtemp/dout] [get_bd_pins cms_subsystem/hbm_temp_2]

    #Connect ored cattrip to GND
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gnd_cattrip
    set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells gnd_cattrip]
    connect_bd_net [get_bd_pins gnd_cattrip/dout] [get_bd_pins cms_subsystem/interrupt_hbm_cattrip]
  } else {
    puterrors "Wrong MemController must have either DDR or HBM"
    putwarnings $g_board_part 
    exit 1
  }

} elseif {$g_board_part != "u200"} {
  #SPECIFIC IMPLEMENTATION FOR U200/U250
  putwarnings "CMS enabled for U200/U250"

  #Possible configuration for CMS; right now we do not use QSFP
  #set   fd_mod  [open $g_cms_file    "w"]
  #puts $fd_mod "    // CMS"
  #puts $fd_mod "    input [0:0]     satellite_uart_rxd    ,"
  #puts $fd_mod "    output [0:0]    satellite_uart_txd    ,"
  #puts $fd_mod "    input [3:0]     satellite_gpio,"
  #puts $fd_mod "    // CMS WITH QSFP"
  #puts $fd_mod "    input [0:0]     qsfp0_modsel_l_0,"
  #puts $fd_mod "    input [0:0]     qsfp1_modsel_l_0,"
  #puts $fd_mod "    input [0:0]     qsfp0_modprs_l_0,"
  #puts $fd_mod "    input [0:0]     qsfp1_modprs_l_0,"
  #puts $fd_mod "    input [0:0]     qsfp0_reset_l_0,"
  #puts $fd_mod "    input [0:0]     qsfp1_reset_l_0,"
  #puts $fd_mod "    input [0:0]     qsfp0_lpmode_0,"
  #puts $fd_mod "    input [0:0]     qsfp1_lpmode_0,"
  #puts $fd_mod "    input [0:0]     qsfp0_int_l_0,"
  #puts $fd_mod "    input [0:0]     qsfp1_int_l_0,"
  #close $fd_mod

  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gnd_pin
  set_property CONFIG.CONST_VAL {0} [get_bd_cells gnd_pin]

  #Make external qsfpX_int_l
  connect_bd_net  [get_bd_pins cms_subsystem/qsfp0_int_l] [get_bd_pins gnd_pin/dout]
  connect_bd_net  [get_bd_pins cms_subsystem/qsfp1_int_l] [get_bd_pins gnd_pin/dout]
  #Make external qsfpX_modprs_l
  connect_bd_net  [get_bd_pins cms_subsystem/qsfp0_modprs_l] [get_bd_pins gnd_pin/dout]
  connect_bd_net  [get_bd_pins cms_subsystem/qsfp1_modprs_l] [get_bd_pins gnd_pin/dout]
  # #Make external qsfpX_lpmode
  # connect_bd_net  [get_bd_pins cms_subsystem/qsfp0_lpmode] [get_bd_pins gnd_pin/dout]
  # connect_bd_net  [get_bd_pins cms_subsystem/qsfp1_lpmode] [get_bd_pins gnd_pin/dout]
  # #Make external qsfpX_lpmodsel_l
  # connect_bd_net  [get_bd_pins cms_subsystem/qsfp0_lpmodsel_l] [get_bd_pins gnd_pin/dout]
  # connect_bd_net  [get_bd_pins cms_subsystem/qsfp1_lpmodsel_l] [get_bd_pins gnd_pin/dout]
  # #Make external qsfpX_reset_l
  # connect_bd_net  [get_bd_pins cms_subsystem/qsfp0_reset_l] [get_bd_pins gnd_pin/dout]
  # connect_bd_net  [get_bd_pins cms_subsystem/qsfp1_reset_l] [get_bd_pins gnd_pin/dout]
  
} else {
  puterrors "Wrong target: Only Alveos U200/250, U280 and U55C support CMS"
  putwarnings $g_board_part 
  exit 1
}

#Append cms.sv interfaces file
set PortList [lappend PortList $g_cms_file]
incr slv_axilite_ninstances
putmeeps "CMS created"
save_bd_design