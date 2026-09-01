//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Tue Sep  1 09:14:32 2026
//Host        : HP15S running 64-bit major release  (build 9200)
//Command     : generate_target Bit32_version_wrapper.bd
//Design      : Bit32_version_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module Bit32_version_wrapper
   (clk_i,
    done_o_0,
    fail_count_o_0,
    fail_flag_o_0,
    fault_addr_o,
    fault_addr_valid_o,
    fault_en_i_0,
    repair_count_o_0,
    repair_full_o_0,
    repair_reset_i_0,
    repaired_logical_addr_o_0,
    repaired_physical_addr_o_0,
    repaired_valid_o_0,
    rst_i,
    start_i_0);
  input clk_i;
  output done_o_0;
  output [7:0]fail_count_o_0;
  output fail_flag_o_0;
  output [9:0]fault_addr_o;
  output fault_addr_valid_o;
  input fault_en_i_0;
  output [9:0]repair_count_o_0;
  output repair_full_o_0;
  input repair_reset_i_0;
  output [9:0]repaired_logical_addr_o_0;
  output [9:0]repaired_physical_addr_o_0;
  output repaired_valid_o_0;
  input rst_i;
  input start_i_0;

  wire clk_i;
  wire done_o_0;
  wire [7:0]fail_count_o_0;
  wire fail_flag_o_0;
  wire [9:0]fault_addr_o;
  wire fault_addr_valid_o;
  wire fault_en_i_0;
  wire [9:0]repair_count_o_0;
  wire repair_full_o_0;
  wire repair_reset_i_0;
  wire [9:0]repaired_logical_addr_o_0;
  wire [9:0]repaired_physical_addr_o_0;
  wire repaired_valid_o_0;
  wire rst_i;
  wire start_i_0;

  Bit32_version Bit32_version_i
       (.clk_i(clk_i),
        .done_o_0(done_o_0),
        .fail_count_o_0(fail_count_o_0),
        .fail_flag_o_0(fail_flag_o_0),
        .fault_addr_o(fault_addr_o),
        .fault_addr_valid_o(fault_addr_valid_o),
        .fault_en_i_0(fault_en_i_0),
        .repair_count_o_0(repair_count_o_0),
        .repair_full_o_0(repair_full_o_0),
        .repair_reset_i_0(repair_reset_i_0),
        .repaired_logical_addr_o_0(repaired_logical_addr_o_0),
        .repaired_physical_addr_o_0(repaired_physical_addr_o_0),
        .repaired_valid_o_0(repaired_valid_o_0),
        .rst_i(rst_i),
        .start_i_0(start_i_0));
endmodule
