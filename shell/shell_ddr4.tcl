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
# Description: Standalone DDR4 implementation (mutually exclusive with HBM)

putwarnings $DDR4entry

set DDR4Freq   [dict get $DDR4entry SyncClk Freq]
set DDR4name   [dict get $DDR4entry SyncClk Name]
set DDR4intf   [dict get $DDR4entry IntfLabel]
set DDR4Ready  [dict get $DDR4entry CalibDone]
set DDR4ChNum  [dict get $DDR4entry EnChannel]
set DDR4ClkNm  [dict get $DDR4entry SyncClk Label]
set DDR4axi    [dict get $DDR4entry AxiIntf]

set DDR4addrWidth [dict get $DDR4entry AxiAddrWidth]
set DDR4dataWidth [dict get $DDR4entry AxiDataWidth]
set DDR4idWidth   [dict get $DDR4entry AxiIdWidth]
set DDR4userWidth [dict get $DDR4entry AxiUserWidth]
## CAUTION: Axi user signals are not supported as input to the protocol 
## converter to DDR4. Hardcoded to 0

set DDR4axiProt  [string replace $DDR4axi   [string first "-" $DDR4axi] end]
set DDR4ataWidth [string replace $DDR4axi 0 [string first "-" $DDR4axi]    ]


putmeeps "Creating DDR4 instance..."
### TODO: Region, prot and others can be extracted as the other widths
set ddr4_axi4 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $DDR4intf ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH $DDRaddrWidth \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH $DDR4ataWidth \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {32} \
   CONFIG.NUM_READ_THREADS {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {32} \
   CONFIG.NUM_WRITE_THREADS {16} \
   CONFIG.PROTOCOL $DDR4axiProt \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   ] $ddr4_axi4

# Create DDR MC instance if doesn't exsists already
if { [info exists ddr_dev] == 0 || $ddr_dev != "ddr4_$DDR4ChNum"} {
  set PortList [lappend PortList $g_ddr4_file]
  set ddr_dev ddr4_${DDR4ChNum}
	
  # Create instance: ddr4_0, and set properties
  set ddr4_inst [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 $ddr_dev ]
  set_property -dict [ list \
   CONFIG.C0.DDR4_AUTO_AP_COL_A3 {true} \
   CONFIG.C0.DDR4_AxiAddressWidth $DDRaddrWidth \
   CONFIG.C0.DDR4_AxiDataWidth {512} \
   CONFIG.C0.DDR4_CLKFBOUT_MULT {15} \
   CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5} \
   CONFIG.C0.DDR4_CasLatency {17} \
   CONFIG.C0.DDR4_CasWriteLatency {12} \
   CONFIG.C0.DDR4_DataMask {NONE} \
   CONFIG.C0.DDR4_DataWidth {72} \
   CONFIG.C0.DDR4_EN_PARITY {true} \
   CONFIG.C0.DDR4_Ecc {true} \
   CONFIG.C0.DDR4_InputClockPeriod $ddr_freq \
   CONFIG.C0.DDR4_Mem_Add_Map {ROW_COLUMN_BANK_INTLV} \
   CONFIG.C0.DDR4_MemoryPart {MTA18ASF2G72PZ-2G3} \
   CONFIG.C0.DDR4_MemoryType {RDIMMs} \
   CONFIG.C0.DDR4_TimePeriod {833} \
   CONFIG.C0_CLOCK_BOARD_INTERFACE {Custom} \
   CONFIG.C0_DDR4_BOARD_INTERFACE {Custom} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
 ] $ddr4_inst

# Input CLK
make_bd_intf_pins_external  [get_bd_intf_pins ${ddr_dev}/C0_SYS_CLK]
set_property name sysclk${DDR4ChNum} [get_bd_intf_ports C0_SYS_CLK_0]
set_property -dict [list CONFIG.FREQ_HZ $FREQ_HZ] [get_bd_intf_ports sysclk${DDR4ChNum}]

#DDR io interface
make_bd_intf_pins_external  [get_bd_intf_pins ${ddr_dev}/C0_DDR4]
set_property name ddr4_sdram_c${DDR4ChNum} [get_bd_intf_ports C0_DDR4_0]

# Resets
set ddr_calib_sync [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 ddr_calib_sync ]
set_property -dict [ list \
CONFIG.C_AUX_RESET_HIGH {0} \
] $ddr_calib_sync
connect_bd_net [get_bd_pins ddr_calib_sync/ext_reset_in] [get_bd_pins ddr_calib_sync/aux_reset_in] [get_bd_pins ddr4_${DDR4ChNum}/c0_init_calib_complete]
connect_bd_net [get_bd_pins ddr_calib_sync/slowest_sync_clk] [get_bd_pins rst_ea_$DDR4ClkNm/slowest_sync_clk]
connect_bd_net [get_bd_pins ddr_calib_sync/dcm_locked] [get_bd_pins clk_wiz_1/locked]
make_bd_pins_external [get_bd_pins ddr_calib_sync/peripheral_aresetn]
set_property name $DDR4Ready [get_bd_ports peripheral_aresetn_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_ddrRst
set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {not} CONFIG.LOGO_FILE {data/sym_notgate.png}] [get_bd_cells util_vector_logic_ddrRst]
connect_bd_net [get_bd_pins util_vector_logic_ddrRst/Op1] [get_bd_pins $ddr_dev/c0_ddr4_ui_clk_sync_rst]
connect_bd_net [get_bd_pins util_vector_logic_ddrRst/Res] [get_bd_pins $ddr_dev/c0_ddr4_aresetn]
connect_bd_net [get_bd_pins rst_ea_$DDR4ClkNm/peripheral_reset] [get_bd_pins ddr4_${DDR4ChNum}/sys_rst]

# Workaround to the uneeded AXIL DDR ctrl
# Create instance: gndx32, and set properties
  set gndx32 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gndx32 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {32} \
 ] $gndx32
connect_bd_net [get_bd_pins gndx32/dout] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_araddr] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_awaddr] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_wdata]

#Secondary ports connection which need to be connected to zero
# Create the HBM cattrip ground connection
set hbm_cattrip [ create_bd_port -dir O -from 0 -to 0 hbm_cattrip ]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gnd_cattrip
set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells gnd_cattrip]
connect_bd_net [get_bd_ports hbm_cattrip] [get_bd_pins gnd_cattrip/dout]
connect_bd_net [get_bd_pins gnd_cattrip/dout] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_arvalid] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_awvalid] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_bready] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_rready] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_wvalid]
}

if { $PCIeDMA == "dma" && $PCIedmaMem == "ddr" && $PCIeDMAdone == 0} {
  connect_bd_net [get_bd_pins axi_xbar_pcie/ACLK]     [get_bd_pins $ddr_dev/c0_ddr4_ui_clk]
  connect_bd_net [get_bd_pins axi_xbar_pcie/M00_ACLK] [get_bd_pins $ddr_dev/c0_ddr4_ui_clk]
  connect_bd_net [get_bd_pins axi_xbar_pcie/ARESETN]     [get_bd_pins util_vector_logic_ddrRst/Res]
  connect_bd_net [get_bd_pins axi_xbar_pcie/M00_ARESETN] [get_bd_pins util_vector_logic_ddrRst/Res]
  connect_bd_intf_net [get_bd_intf_pins axi_xbar_pcie/M00_AXI] [get_bd_intf_pins $ddr_dev/C0_DDR4_S_AXI]
  set PCIeDMAdone 1
}

#Modify AXI INTERCONNECT to add external AXI
set_property -dict [list CONFIG.NUM_SI [expr $mst_axi_ninstances + 1]] $axi_xbar_pcie
connect_bd_net [get_bd_pins axi_xbar_pcie/S0${mst_axi_ninstances}_ACLK]    [get_bd_pins rst_ea_$DDR4ClkNm/slowest_sync_clk]
connect_bd_net [get_bd_pins axi_xbar_pcie/S0${mst_axi_ninstances}_ARESETN] [get_bd_pins rst_ea_$DDR4ClkNm/peripheral_aresetn]
connect_bd_intf_net [get_bd_intf_ports $DDR4intf] [get_bd_intf_pins axi_xbar_pcie/S0${mst_axi_ninstances}_AXI]
incr mst_axi_ninstances

#Lets associate a clock to the frequency of the mem_axi bus
set_property CONFIG.ASSOCIATED_BUSIF [get_property CONFIG.ASSOCIATED_BUSIF [get_bd_ports /$DDR4name]]$DDR4intf: [get_bd_ports /$DDR4name]

save_bd_design 
