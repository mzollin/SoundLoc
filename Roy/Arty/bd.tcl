
################################################################
# This is a generated script based on design: bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source bd_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a35ticsg324-1L
   set_property BOARD_PART digilentinc.com:arty:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
set design_name bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: ram
proc create_hier_cell_ram { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_ram() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -from 0 -to 0 -type rst SYS_Rst

  # Create instance: bram, and set properties
  set bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 bram ]
  set_property -dict [ list \
CONFIG.Memory_Type {True_Dual_Port_RAM} \
CONFIG.use_bram_block {BRAM_Controller} \
 ] $bram

  # Create instance: d, and set properties
  set d [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 d ]

  # Create instance: dctrl, and set properties
  set dctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dctrl ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $dctrl

  # Create instance: i, and set properties
  set i [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 i ]

  # Create instance: ictrl, and set properties
  set ictrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ictrl ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $ictrl

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins d/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins d/LMB_Sl_0] [get_bd_intf_pins dctrl/SLMB]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins bram/BRAM_PORTA] [get_bd_intf_pins dctrl/BRAM_PORT]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins i/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins i/LMB_Sl_0] [get_bd_intf_pins ictrl/SLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins bram/BRAM_PORTB] [get_bd_intf_pins ictrl/BRAM_PORT]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins d/SYS_Rst] [get_bd_pins dctrl/LMB_Rst] [get_bd_pins i/SYS_Rst] [get_bd_pins ictrl/LMB_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins d/LMB_Clk] [get_bd_pins dctrl/LMB_Clk] [get_bd_pins i/LMB_Clk] [get_bd_pins ictrl/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set mic_bs [ create_bd_intf_port -mode Master -vlnv hsr.ch:user:mic_bs_rtl:1.0 mic_bs ]
  set sh [ create_bd_intf_port -mode Master -vlnv hsr.com:user:SH_595_rtl:1.0 sh ]
  set usb_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 usb_uart ]

  # Create ports
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset
  set sys_clock [ create_bd_port -dir I -type clk sys_clock ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {100000000} \
CONFIG.PHASE {0.000} \
 ] $sys_clock

  # Create instance: SDM_Decimator_0, and set properties
  set SDM_Decimator_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:SDM_Decimator:1.0 SDM_Decimator_0 ]

  # Create instance: SH, and set properties
  set SH [ create_bd_cell -type ip -vlnv Xilinx.com:user:AXI_SH_595:1.0 SH ]
  set_property -dict [ list \
CONFIG.C_SH_DATA_WIDTH {16} \
CONFIG.C_USE_OE_N {false} \
 ] $SH

  # Create instance: UART, and set properties
  set UART [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 UART ]
  set_property -dict [ list \
CONFIG.C_BAUDRATE {921600} \
CONFIG.C_S_AXI_ACLK_FREQ_HZ {100000000} \
CONFIG.UARTLITE_BOARD_INTERFACE {usb_uart} \
CONFIG.USE_BOARD_FLOW {true} \
 ] $UART

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.C_S_AXI_ACLK_FREQ_HZ.VALUE_SRC {DEFAULT} \
 ] $UART

  # Create instance: XCorr, and set properties
  set XCorr [ create_bd_cell -type ip -vlnv xilinx.com:user:XCorr:1.0 XCorr ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.3 clk_wiz_0 ]
  set_property -dict [ list \
CONFIG.CLKOUT1_DRIVES {BUFG} \
CONFIG.CLKOUT1_JITTER {130.958} \
CONFIG.CLKOUT1_PHASE_ERROR {98.575} \
CONFIG.CLKOUT2_DRIVES {BUFG} \
CONFIG.CLKOUT2_JITTER {270.159} \
CONFIG.CLKOUT2_PHASE_ERROR {128.132} \
CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {100.000} \
CONFIG.CLKOUT2_USED {false} \
CONFIG.CLKOUT3_DRIVES {BUFG} \
CONFIG.CLKOUT4_DRIVES {BUFG} \
CONFIG.CLKOUT5_DRIVES {BUFG} \
CONFIG.CLKOUT6_DRIVES {BUFG} \
CONFIG.CLKOUT7_DRIVES {BUFG} \
CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
CONFIG.MMCM_CLKIN1_PERIOD {10.0} \
CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.000} \
CONFIG.MMCM_CLKOUT1_DIVIDE {1} \
CONFIG.MMCM_COMPENSATION {ZHOLD} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.NUM_OUT_CLKS {1} \
CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
CONFIG.USE_BOARD_FLOW {true} \
CONFIG.USE_PHASE_ALIGNMENT {false} \
CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.MMCM_CLKIN1_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKIN2_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_COMPENSATION.VALUE_SRC {DEFAULT} \
 ] $clk_wiz_0

  # Create instance: ic, and set properties
  set ic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ic ]
  set_property -dict [ list \
CONFIG.NUM_MI {5} \
 ] $ic

  # Create instance: intc, and set properties
  set intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 intc ]

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]

  # Create instance: ram
  create_hier_cell_ram [current_bd_instance .] ram

  # Create instance: rst, and set properties
  set rst [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst ]
  set_property -dict [ list \
CONFIG.RESET_BOARD_INTERFACE {reset} \
CONFIG.USE_BOARD_FLOW {true} \
 ] $rst

  # Create instance: uB, and set properties
  set uB [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:9.6 uB ]
  set_property -dict [ list \
CONFIG.C_BRANCH_TARGET_CACHE_SIZE {0} \
CONFIG.C_DEBUG_ENABLED {1} \
CONFIG.C_DEBUG_TRACE_SIZE {0} \
CONFIG.C_D_AXI {1} \
CONFIG.C_D_LMB {1} \
CONFIG.C_ICACHE_FORCE_TAG_LUTRAM {0} \
CONFIG.C_ICACHE_LINE_LEN {4} \
CONFIG.C_I_LMB {1} \
CONFIG.C_USE_BARREL {1} \
CONFIG.C_USE_BRANCH_TARGET_CACHE {0} \
CONFIG.C_USE_DCACHE {0} \
CONFIG.C_USE_DIV {1} \
CONFIG.C_USE_EXTENDED_FSL_INSTR {0} \
CONFIG.C_USE_FPU {0} \
CONFIG.C_USE_HW_MUL {1} \
CONFIG.C_USE_ICACHE {0} \
CONFIG.C_USE_MSR_INSTR {1} \
CONFIG.C_USE_PCMP_INSTR {1} \
CONFIG.C_USE_REORDER_INSTR {0} \
 ] $uB

  # Create interface connections
  connect_bd_intf_net -intf_net SDM_Decimator_0_mic_bs [get_bd_intf_ports mic_bs] [get_bd_intf_pins SDM_Decimator_0/mic_bs]
  connect_bd_intf_net -intf_net SDM_Decimator_0_mic_data [get_bd_intf_pins SDM_Decimator_0/mic_data] [get_bd_intf_pins XCorr/mic]
  connect_bd_intf_net -intf_net SH [get_bd_intf_ports sh] [get_bd_intf_pins SH/sh]
  connect_bd_intf_net -intf_net UART [get_bd_intf_ports usb_uart] [get_bd_intf_pins UART/UART]
  connect_bd_intf_net -intf_net axi_intc_0_interrupt [get_bd_intf_pins intc/interrupt] [get_bd_intf_pins uB/INTERRUPT]
  connect_bd_intf_net -intf_net ic_M00_AXI [get_bd_intf_pins UART/S_AXI] [get_bd_intf_pins ic/M00_AXI]
  connect_bd_intf_net -intf_net ic_M01_AXI [get_bd_intf_pins ic/M01_AXI] [get_bd_intf_pins intc/s_axi]
  connect_bd_intf_net -intf_net ic_M02_AXI [get_bd_intf_pins SH/S_AXI] [get_bd_intf_pins ic/M02_AXI]
  connect_bd_intf_net -intf_net ic_M03_AXI [get_bd_intf_pins SDM_Decimator_0/S_AXI] [get_bd_intf_pins ic/M03_AXI]
  connect_bd_intf_net -intf_net ic_M04_AXI [get_bd_intf_pins XCorr/S_AXI] [get_bd_intf_pins ic/M04_AXI]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DP [get_bd_intf_pins ic/S00_AXI] [get_bd_intf_pins uB/M_AXI_DP]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins uB/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins ram/DLMB] [get_bd_intf_pins uB/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins ram/ILMB] [get_bd_intf_pins uB/ILMB]

  # Create port connections
  connect_bd_net -net XCorr_irq [get_bd_pins XCorr/irq] [get_bd_pins intc/intr]
  connect_bd_net -net clk_wiz1_clk_out1 [get_bd_pins SDM_Decimator_0/s_axi_aclk] [get_bd_pins SH/s_axi_aclk] [get_bd_pins UART/s_axi_aclk] [get_bd_pins XCorr/s_axi_aclk] [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins ic/ACLK] [get_bd_pins ic/M00_ACLK] [get_bd_pins ic/M01_ACLK] [get_bd_pins ic/M02_ACLK] [get_bd_pins ic/M03_ACLK] [get_bd_pins ic/M04_ACLK] [get_bd_pins ic/S00_ACLK] [get_bd_pins intc/s_axi_aclk] [get_bd_pins ram/LMB_Clk] [get_bd_pins rst/slowest_sync_clk] [get_bd_pins uB/Clk]
  connect_bd_net -net clk_wiz_1_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins rst/dcm_locked]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst/mb_debug_sys_rst]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins rst/ext_reset_in]
  connect_bd_net -net rst_clk_wiz_1_100M_bus_struct_reset [get_bd_pins ram/SYS_Rst] [get_bd_pins rst/bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_mb_reset [get_bd_pins rst/mb_reset] [get_bd_pins uB/Reset]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins SDM_Decimator_0/s_axi_aresetn] [get_bd_pins SH/s_axi_aresetn] [get_bd_pins UART/s_axi_aresetn] [get_bd_pins XCorr/s_axi_aresetn] [get_bd_pins ic/M00_ARESETN] [get_bd_pins ic/M01_ARESETN] [get_bd_pins ic/M02_ARESETN] [get_bd_pins ic/M03_ARESETN] [get_bd_pins ic/M04_ARESETN] [get_bd_pins ic/S00_ARESETN] [get_bd_pins intc/s_axi_aresetn] [get_bd_pins rst/peripheral_aresetn]
  connect_bd_net -net rst_interconnect_aresetn [get_bd_pins ic/ARESETN] [get_bd_pins rst/interconnect_aresetn]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz_0/clk_in1]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces uB/Data] [get_bd_addr_segs SDM_Decimator_0/S_AXI/S_AXI_reg] SEG_SDM_Decimator_0_S_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces uB/Data] [get_bd_addr_segs SH/S_AXI/S_AXI_reg] SEG_SH_S_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40600000 [get_bd_addr_spaces uB/Data] [get_bd_addr_segs UART/S_AXI/Reg] SEG_UART_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A20000 [get_bd_addr_spaces uB/Data] [get_bd_addr_segs XCorr/S_AXI/S_AXI] SEG_XCorr_S_AXI
  create_bd_addr_seg -range 0x00020000 -offset 0x00000000 [get_bd_addr_spaces uB/Data] [get_bd_addr_segs ram/dctrl/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00020000 -offset 0x00000000 [get_bd_addr_spaces uB/Instruction] [get_bd_addr_segs ram/ictrl/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces uB/Data] [get_bd_addr_segs intc/S_AXI/Reg] SEG_intc_Reg

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.12  2016-01-29 bk=1.3547 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port sh -pg 1 -y 210 -defaultsOSRD
preplace port sys_clock -pg 1 -y 630 -defaultsOSRD
preplace port usb_uart -pg 1 -y 80 -defaultsOSRD
preplace port reset -pg 1 -y 570 -defaultsOSRD
preplace port mic_bs -pg 1 -y 390 -defaultsOSRD
preplace inst SDM_Decimator_0 -pg 1 -lvl 6 -y 350 -defaultsOSRD
preplace inst UART -pg 1 -lvl 6 -y 90 -defaultsOSRD
preplace inst ram -pg 1 -lvl 5 -y 500 -defaultsOSRD
preplace inst intc -pg 1 -lvl 3 -y 490 -defaultsOSRD
preplace inst rst -pg 1 -lvl 2 -y 590 -defaultsOSRD
preplace inst mdm_1 -pg 1 -lvl 3 -y 350 -defaultsOSRD
preplace inst SH -pg 1 -lvl 6 -y 210 -defaultsOSRD
preplace inst XCorr -pg 1 -lvl 7 -y 310 -defaultsOSRD
preplace inst uB -pg 1 -lvl 4 -y 490 -defaultsOSRD
preplace inst clk_wiz_0 -pg 1 -lvl 1 -y 630 -defaultsOSRD
preplace inst ic -pg 1 -lvl 5 -y 190 -defaultsOSRD
preplace netloc axi_intc_0_interrupt 1 3 1 780
preplace netloc rst_interconnect_aresetn 1 2 3 NJ 610 NJ 610 1250
preplace netloc ic_M03_AXI 1 5 1 1590
preplace netloc SDM_Decimator_0_mic_data 1 6 1 1830
preplace netloc UART 1 6 2 NJ 80 NJ
preplace netloc ic_M02_AXI 1 5 1 N
preplace netloc clk_wiz1_clk_out1 1 1 6 180 500 530 570 780 570 1240 390 1600 420 NJ
preplace netloc SDM_Decimator_0_mic_bs 1 6 2 NJ 390 NJ
preplace netloc microblaze_0_ilmb_1 1 4 1 N
preplace netloc microblaze_0_M_AXI_DP 1 4 1 1230
preplace netloc sys_clock_1 1 0 1 NJ
preplace netloc ic_M00_AXI 1 5 1 1570
preplace netloc ic_M01_AXI 1 2 4 550 410 NJ 410 NJ 410 1570
preplace netloc rst_clk_wiz_1_100M_bus_struct_reset 1 2 3 NJ 600 NJ 600 1260
preplace netloc SH 1 6 2 NJ 210 NJ
preplace netloc rst_clk_wiz_1_100M_peripheral_aresetn 1 2 5 540 620 NJ 620 1270 400 1610 430 NJ
preplace netloc rst_clk_wiz_1_100M_mb_reset 1 2 2 520 580 NJ
preplace netloc clk_wiz_1_locked 1 1 1 180
preplace netloc XCorr_irq 1 2 6 550 590 NJ 590 NJ 590 NJ 590 NJ 590 2030
preplace netloc microblaze_0_dlmb_1 1 4 1 N
preplace netloc ic_M04_AXI 1 5 2 1580 280 NJ
preplace netloc microblaze_0_debug 1 3 1 790
preplace netloc reset_1 1 0 2 NJ 570 NJ
preplace netloc mdm_1_debug_sys_rst 1 1 3 190 680 NJ 680 770
levelinfo -pg 1 0 100 350 660 1010 1420 1720 1940 2050 -top 0 -bot 690
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

