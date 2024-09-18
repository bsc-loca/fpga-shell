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

set DDR4ClkNm  [dict get $DDR4entry SyncClk Label]
set DDR4Freq   [dict get $DDR4entry SyncClk Freq]
set DDR4name   [dict get $DDR4entry SyncClk Name]
set DDR4intf   [dict get $DDR4entry IntfLabel]
set DDR4Ready  [dict get $DDR4entry CalibDone]
set DDR4ChNum  [dict get $DDR4entry EnChannel]
set DDR4axi    [dict get $DDR4entry AxiIntf]

set DDR4addrWidth [dict get $DDR4entry AxiAddrWidth]
set DDR4dataWidth [dict get $DDR4entry AxiDataWidth]
set DDR4idWidth   [dict get $DDR4entry AxiIdWidth]
set DDR4userWidth [dict get $DDR4entry AxiUserWidth]
## CAUTION: Axi user signals are not supported as input to the protocol 
## converter to DDR4. Hardcoded to 0

#it seems it does not do well this command
set PortList [lappend PortList $g_ddr4_file]

putmeeps "Creating input DDR4 interface..."
set DDR4axiProt  [string replace $DDR4axi   [string first "-" $DDR4axi] end]
set DDR4ataWidth [string replace $DDR4axi 0 [string first "-" $DDR4axi]    ]
set ddr4_axi4 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $DDR4intf ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {36} \
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

putmeeps "Creating DDR4_0 instance..."
  # if {[info exists ::env(PROTOSYN_RUNTIME_BOARD)] && $::env(PROTOSYN_RUNTIME_BOARD)=="alveou280"} {
    set DDR4_InClk "9996"
  # }
  # if {[info exists ::env(PROTOSYN_RUNTIME_BOARD)] && $::env(PROTOSYN_RUNTIME_BOARD)=="alveou250"} {
  #   set DDR4_InClk "3332"
  # }

  set ddr_dev ddr4_${DDR4ChNum}
  # Create instance: ddr4_0, and set properties
  # As there is only one channel currently ddr4_dev = ddr4_0
  set ddr4_inst [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 $ddr_dev ]
  set_property -dict [ list \
   CONFIG.C0.DDR4_AUTO_AP_COL_A3 {true} \
   CONFIG.C0.DDR4_AxiAddressWidth {34} \
   CONFIG.C0.DDR4_AxiDataWidth {512} \
   CONFIG.C0.DDR4_CLKFBOUT_MULT {15} \
   CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5} \
   CONFIG.C0.DDR4_CasLatency {17} \
   CONFIG.C0.DDR4_CasWriteLatency {12} \
   CONFIG.C0.DDR4_DataMask {NONE} \
   CONFIG.C0.DDR4_DataWidth {72} \
   CONFIG.C0.DDR4_EN_PARITY {true} \
   CONFIG.C0.DDR4_Ecc {true} \
   CONFIG.C0.DDR4_InputClockPeriod $DDR4_InClk \
   CONFIG.C0.DDR4_Mem_Add_Map {ROW_COLUMN_BANK_INTLV} \
   CONFIG.C0.DDR4_MemoryPart {MTA18ASF2G72PZ-2G3} \
   CONFIG.C0.DDR4_MemoryType {RDIMMs} \
   CONFIG.C0.DDR4_TimePeriod {833} \
   CONFIG.C0_CLOCK_BOARD_INTERFACE {Custom} \
   CONFIG.C0_DDR4_BOARD_INTERFACE {Custom} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
 ] $ddr4_inst

save_bd_design 

# Input CLK
make_bd_intf_pins_external  [get_bd_intf_pins $ddr_dev/C0_SYS_CLK]
set_property name sysclk${DDR4ChNum} [get_bd_intf_ports C0_SYS_CLK_0]

#DDR io interface
make_bd_intf_pins_external  [get_bd_intf_pins ${ddr_dev}/C0_DDR4]
set_property name ddr4_sdram_c${DDR4ChNum} [get_bd_intf_ports C0_DDR4_0]

#C0_INIT_CALIB_COMPLETE_0 and external port
set mem_calib_complete [ create_bd_port -dir O -from 0 -to 0 -type rst $DDR4Ready ]
connect_bd_net [get_bd_ports mem_calib_complete] [get_bd_pins $ddr_dev/c0_init_calib_complete]

create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 ddr_rst_inv
set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {not} CONFIG.LOGO_FILE {data/sym_notgate.png}] [get_bd_cells ddr_rst_inv]
connect_bd_net [get_bd_pins $ddr_dev/c0_ddr4_ui_clk_sync_rst] [get_bd_pins ddr_rst_inv/Op1]
connect_bd_net [get_bd_pins $ddr_dev/c0_ddr4_aresetn]         [get_bd_pins ddr_rst_inv/Res]


#Modify AXI INTERCONNECT to add mem_axi on S01 and M01 to DDR4
set_property -dict [list CONFIG.NUM_SI [expr $mst_axi_ninstances + 1]] $axi_xbar_pcie

#ADD additional signals S01_ACLK, S01_ARESETN, M01_ACLK, M01_ARESETN
connect_bd_net [get_bd_pins axi_xbar_pcie/S0${mst_axi_ninstances}_ACLK] [get_bd_pins clk_wiz_1/clk_out1]
connect_bd_net [get_bd_pins axi_xbar_pcie/S0${mst_axi_ninstances}_ARESETN] [get_bd_pins rst_ea_CLK0/peripheral_aresetn]

if { $PCIeDMA == "dma" && $PCIedmaMem == "ddr" && $PCIeDMAdone == 0} {
  connect_bd_net [get_bd_pins axi_xbar_pcie/ACLK]     [get_bd_pins $ddr_dev/c0_ddr4_ui_clk]
  connect_bd_net [get_bd_pins axi_xbar_pcie/M00_ACLK] [get_bd_pins $ddr_dev/c0_ddr4_ui_clk]
  connect_bd_net [get_bd_pins axi_xbar_pcie/ARESETN]     [get_bd_pins ddr_rst_inv/Res]
  connect_bd_net [get_bd_pins axi_xbar_pcie/M00_ARESETN] [get_bd_pins ddr_rst_inv/Res]
  connect_bd_intf_net [get_bd_intf_pins axi_xbar_pcie/M00_AXI] [get_bd_intf_pins $ddr_dev/C0_DDR4_S_AXI]
  set PCIeDMAdone 1
}

#MEM_AXI
connect_bd_intf_net [get_bd_intf_ports $DDR4intf] [get_bd_intf_pins axi_xbar_pcie/S0${mst_axi_ninstances}_AXI]
incr mst_axi_ninstances
#Lets associate a clock to the frequency of the mem_axi bus
set_property CONFIG.ASSOCIATED_BUSIF [get_property CONFIG.ASSOCIATED_BUSIF [get_bd_ports /$DDR4name]]$DDR4intf: [get_bd_ports /$DDR4name]

connect_bd_net [get_bd_pins $ddr_dev/sys_rst] [get_bd_pins rst_ea_$DDR4ClkNm/peripheral_reset]

# Create the HBM cattrip ground connection
set hbm_cattrip [ create_bd_port -dir O -from 0 -to 0 hbm_cattrip ]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gnd_cattrip
set_property CONFIG.CONST_VAL {0} [get_bd_cells gnd_cattrip]
connect_bd_net [get_bd_ports hbm_cattrip] [get_bd_pins gnd_cattrip/dout]

#Secondary ports connection which need to be connected to zero
# Create instance: gndx1, and set properties
  set gndx1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gndx1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {1} \
 ] $gndx1
connect_bd_net [get_bd_pins gndx1/dout]  [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_arvalid] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_awvalid] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_bready] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_rready] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_wvalid]

# Create instance: gndx32, and set properties
  set gndx32 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gndx32 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {32} \
 ] $gndx32
connect_bd_net [get_bd_pins gndx32/dout] [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_araddr]  [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_awaddr]  [get_bd_pins $ddr_dev/c0_ddr4_s_axi_ctrl_wdata]

#Set address space
# assign_bd_address -offset 0x00000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
# assign_bd_address -offset 0x00000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces mem_axi]        [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
