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
putmeeps "Creating CMS..."
#Create the CMS, no properties needed
create_bd_cell -type ip -vlnv xilinx.com:ip:cms_subsystem:4.0 cms_subsystem_0

save_bd_design

#Connect temp sensors data 1 and 2
connect_bd_net [get_bd_pins hbm_0/DRAM_0_STAT_TEMP] [get_bd_pins cms_subsystem_0/hbm_temp_1] 
connect_bd_net [get_bd_pins hbm_0/DRAM_1_STAT_TEMP] [get_bd_pins cms_subsystem_0/hbm_temp_2]

#Connect ored cattrip
connect_bd_net [get_bd_pins hbm_cattrip_or/Res] [get_bd_pins cms_subsystem_0/interrupt_hbm_cattrip]

#We need a 50Mhz clock for the aclk_ctrl, chipset_clk is connected to clock wizard out 1 which creates a 50Mhz 
connect_bd_net [get_bd_pins cms_subsystem_0/aclk_ctrl] [get_bd_ports chipset_clk]

#We need a aresetn signal
connect_bd_net [get_bd_pins cms_subsystem_0/aresetn_ctrl] [get_bd_pins rst_ea_CLK0/peripheral_aresetn]

#Create GPIO port (width of 4)
create_bd_port -dir I -from 3 -to 0 -type intr satellite_gpio

#Create an input GPIO port for the SC
set_property -dict [list \
 CONFIG.SENSITIVITY [get_property CONFIG.SENSITIVITY [get_bd_pins cms_subsystem_0/satellite_gpio]] \
 CONFIG.PortWidth [get_property CONFIG.PortWidth [get_bd_pins cms_subsystem_0/satellite_gpio]] \
] [get_bd_ports satellite_gpio]

connect_bd_net [get_bd_pins /cms_subsystem_0/satellite_gpio] [get_bd_ports satellite_gpio]

#Create an output UART TXD port
create_bd_port -dir O satellite_uart_txd
connect_bd_net [get_bd_pins /cms_subsystem_0/satellite_uart_txd] [get_bd_ports satellite_uart_txd]

#Create an input UART RXD port
create_bd_port -dir I satellite_uart_rxd
connect_bd_net [get_bd_pins /cms_subsystem_0/satellite_uart_rxd] [get_bd_ports satellite_uart_rxd]

#Connect with AXI pcie lite interconnect
#First modify interconnect to make space to fit another master
set_property -dict [list \
  CONFIG.NUM_MI {2} \
  CONFIG.M00_HAS_REGSLICE {4} \
  CONFIG.M01_HAS_REGSLICE {4} \
] [get_bd_cells axi_xbar_pcie_lite]

#Connect M01 aclk and areset signals
connect_bd_net [get_bd_pins axi_xbar_pcie_lite/M01_ACLK] [get_bd_pins clk_wiz_1/clk_out1]
connect_bd_net [get_bd_pins axi_xbar_pcie_lite/M01_ARESETN] [get_bd_pins rst_ea_CLK0/peripheral_aresetn]

#Connect M01 to s_axi_ctrl from CMS
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_xbar_pcie_lite/M01_AXI] [get_bd_intf_pins cms_subsystem_0/s_axi_ctrl]

#What do we do with 'interrupt_host'?

putmeeps "CMS created"