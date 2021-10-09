//=====================================================================
//
// Author: LI Jiarui
//
// Description:
//  The ift2icb module convert the fetch request to ITCM.
//  SimpleCore currently does not support ICache or Sys-MEM.
//
// ====================================================================
`include "defines.v"
module ifu_ifu2itcm(
  input  ifu_req_valid, // Handshake valid
  output ifu_req_ready, // Handshake ready
  input  [`PC_SIZE-1:0] ifu_req_pc, // Fetch PC
  output ifu_rsp_valid, // to ifu
  input  ifu_rsp_ready, // from ifu
  output [`INSTR_SIZE-1:0] ifu_rsp_instr, // Response instruction
  
  output ifu2itcm_cmd_valid, // Handshake valid
  input  ifu2itcm_cmd_ready, // Handshake ready
  output [`ITCM_RAM_AW-1:0]   ifu2itcm_cmd_addr, //transcation to itcm start address
  input  ifu2itcm_rsp_valid, // Response valid 
  output ifu2itcm_rsp_ready, // Response ready
  input  [`ITCM_RAM_DW-1:0] ifu2itcm_rsp_rdata
  );
  
  assign ifu2itcm_cmd_valid = ifu_req_valid;
  assign ifu_req_ready = ifu2itcm_cmd_ready;
  assign ifu2itcm_cmd_addr = ifu_req_pc[`ITCM_RAM_AW+2-1:2];//to check
  assign ifu_rsp_valid = ifu2itcm_rsp_valid;
  assign ifu2itcm_rsp_ready = ifu_rsp_ready;
  assign ifu_rsp_instr = ifu2itcm_rsp_rdata;
endmodule
