/*===========================================================================
    verision   : v1
    Designer   : Wen Fu
    Reference  : Humming Bird e203
    Description: This module implemented the regular ALU instructions.
                 This module not contain datapath, it only produce 
                 request signal of sharing datapath
                 Not include interrupt signal such as ecall, ebreak etc.
=============================================================================*/
`include "defines.v"

module alu_rglr(

  //////////////////////////////////////////////////////////////
  // The Handshake Interface 
  input  alu_i_valid, // Handshake valid
  output alu_i_ready, // Handshake ready

  input  [`XLEN-1:0] alu_i_rs1,
  input  [`XLEN-1:0] alu_i_rs2,
  input  [`XLEN-1:0] alu_i_imm,
  input  [`PC_SIZE-1:0] alu_i_pc,
  input  [`DECINFO_ALU_WIDTH-1:0] alu_i_info, //16-bits

  //////////////////////////////////////////////////////////////
  // The ALU Write-back/Commit Interface
  output alu_o_valid,                         // Handshake valid
  input  alu_o_ready,                         // Handshake ready

  //   The Write-Back Interface for Special (unaligned ldst) 
  output [`XLEN-1:0] alu_o_wbck_wdat,

  //////////////////////////////////////////////////////////////
  // To share the ALU datapath
  // The operands and info to ALU
  output alu_req_alu_add ,
  output alu_req_alu_sub ,
  output alu_req_alu_xor ,
  output alu_req_alu_sll ,
  output alu_req_alu_srl ,
  output alu_req_alu_sra ,
  output alu_req_alu_or  ,
  output alu_req_alu_and ,
  output alu_req_alu_slt ,
  output alu_req_alu_sltu,
  output alu_req_alu_lui ,
  output [`XLEN-1:0] alu_req_alu_op1,
  output [`XLEN-1:0] alu_req_alu_op2,

  input  [`XLEN-1:0] alu_req_alu_res,
  input  clk,
  input  rst_n,
  );

  wire op2imm  = alu_i_info [`DECINFO_ALU_OP2IMM];                  //13 need imm 
  wire op1pc   = alu_i_info [`DECINFO_ALU_OP1PC ];                  //14 need pc  

  assign alu_req_alu_op1  = op1pc  ? alu_i_pc  : alu_i_rs1;
  assign alu_req_alu_op2  = op2imm ? alu_i_imm : alu_i_rs2;  

  wire nop    = alu_i_info [`DECINFO_ALU_NOP ] ;                     //15           

  // The NOP is encoded as ADDI, so need to uncheck it
  // return the type of operands, sending it to the sharing datapath
  assign alu_req_alu_add  = alu_i_info [`DECINFO_ALU_ADD ] & (~nop); // 2
  assign alu_req_alu_sub  = alu_i_info [`DECINFO_ALU_SUB ];          // 3   
  assign alu_req_alu_slt  = alu_i_info [`DECINFO_ALU_SLT ];          // 4
  assign alu_req_alu_sltu = alu_i_info [`DECINFO_ALU_SLTU];          // 5
  assign alu_req_alu_xor  = alu_i_info [`DECINFO_ALU_XOR ];          // 6
  assign alu_req_alu_or   = alu_i_info [`DECINFO_ALU_OR  ];          // 7
  assign alu_req_alu_and  = alu_i_info [`DECINFO_ALU_AND ];          // 8
  assign alu_req_alu_sll  = alu_i_info [`DECINFO_ALU_SLL ];          // 9
  assign alu_req_alu_srl  = alu_i_info [`DECINFO_ALU_SRL ];          // 10
  assign alu_req_alu_sra  = alu_i_info [`DECINFO_ALU_SRA ];          // 11
  assign alu_req_alu_lui  = alu_i_info [`DECINFO_ALU_LUI ];          // 12

  assign alu_o_valid = alu_i_valid;
  assign alu_i_ready = alu_o_ready;

  //writing back the result of sharing datapath
  assign alu_o_wbck_wdat = alu_req_alu_res;
   
endmodule
