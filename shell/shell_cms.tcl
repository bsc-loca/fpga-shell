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
# Description: CMS implementation precondition: HBM

putwarnings "CMS enabled, needed HBM memory"

#Create the CMS, no properties needed
create_bd_cell -type ip -vlnv xilinx.com:ip:cms_subsystem:4.0 cms_subsystem

save_bd_design

#Connect temp sensors data 1 and 2
connect_bd_net [get_bd_pins hbm_0/DRAM_0_STAT_TEMP] [get_bd_pins cms_subsystem/hbm_temp_1] 
connect_bd_net [get_bd_pins hbm_0/DRAM_1_STAT_TEMP] [get_bd_pins cms_subsystem/hbm_temp_2]

#Connect ored cattrip
connect_bd_net [get_bd_pins hbm_cattrip_or/Res] [get_bd_pins cms_subsystem/interrupt_hbm_cattrip]

#We need a 50Mhz clock for the aclk_ctrl, chipset_clk is connected to clock wizard out 1 which creates a 50Mhz 
connect_bd_net [get_bd_pins cms_subsystem/aclk_ctrl] [get_bd_ports chipset_clk]

#We need a aresetn signal which will be connected to a Processor System reset
#Setup the cms_reset
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 cms_reset
connect_bd_net [get_bd_pins cms_reset/ext_reset_in] [get_bd_ports pcie_perstn]
connect_bd_net [get_bd_pins cms_reset/slowest_sync_clk] [get_bd_pins clk_wiz_1/clk_out1]
connect_bd_net [get_bd_pins cms_subsystem/aresetn_ctrl] [get_bd_pins cms_reset/peripheral_aresetn]

#Create GPIO port (width of 4)
make_bd_pins_external  [get_bd_pins cms_subsystem/satellite_gpio]
set_property name satellite_gpio [get_bd_ports satellite_gpio_0]

#Make external UART connection
make_bd_intf_pins_external [get_bd_intf_pins cms_subsystem/satellite_uart]

#Connect with AXI pcie lite interconnect
#First modify interconnect to make space to fit another master
set_property -dict [list \
  CONFIG.NUM_MI {2} \
] [get_bd_cells axi_xbar_pcie_lite]
set_property CONFIG.pf0_bar2_size_qdma {512} [get_bd_cells qdma_0]

#Connect M01 aclk and areset signals
connect_bd_net [get_bd_pins axi_xbar_pcie_lite/M01_ACLK] [get_bd_pins clk_wiz_1/clk_out1]
connect_bd_net [get_bd_pins axi_xbar_pcie_lite/M01_ARESETN] [get_bd_pins cms_reset/interconnect_aresetn]

#Connect M01 to s_axi_ctrl from CMS
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_xbar_pcie_lite/M01_AXI] [get_bd_intf_pins cms_subsystem/s_axi_ctrl]

#We'll leave the 'interrupt_host' signal unconnected

#At BAR2 we can find at [0x0,0x4000) INFO ROM and at [0x4_0000, 0x8_0000) the CMS reserved space
assign_bd_address -offset 0x40000 -target_address_space /qdma_0/M_AXI_LITE [get_bd_addr_segs cms_subsystem/s_axi_ctrl/Mem] -force

putmeeps "CMS created"