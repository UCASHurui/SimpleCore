/*===========================================================================
    verision   : v1
    Designer   : Wen Fu
    Reference  : Humming Bird e203
    Description: This module to implement the Conditional Branch Instructions, 
                 which is mostly share the datapath with ALU adder to resolve the comparasion 
                 result to save gatecount to mininum
                 Not include  mret, dret, fencei etc.
=============================================================================*/

`include "defines.v"

module exu_alu_bjp(

  //////////////////////////////////////////////////////////////
  // The Handshake Interface
  input  bjp_i_valid,       // Handshake valid
  output bjp_i_ready,       // Handshake ready

  input  [`XLEN-1:0] bjp_i_rs1,
  input  [`XLEN-1:0] bjp_i_rs2,
  input  [`XLEN-1:0] bjp_i_imm,
  input  [`PC_SIZE-1:0] bjp_i_pc,
  input  [`DECINFO_BJP_WIDTH-1:0] bjp_i_info, //11-bits
 
  //////////////////////////////////////////////////////////////
  // The BJP Commit Interface
  output bjp_o_valid,       // Handshake valid
  input  bjp_o_ready,       // Handshake ready

  // The Write-Back Result for JAL and JALR
  output [`XLEN-1:0] bjp_o_wbck_wdat,
  output bjp_o_wbck_err,

  // The Commit Result for BJP
  output bjp_o_cmt_bjp,
  output bjp_o_cmt_prdt,    // The predicted ture/false  
  output bjp_o_cmt_rslv,    // The resolved ture/false

  //////////////////////////////////////////////////////////////
  // To share the ALU datapath
  // The operands and info to ALU
  output [`XLEN-1:0] bjp_req_alu_op1,
  output [`XLEN-1:0] bjp_req_alu_op2,
  output bjp_req_alu_cmp_eq ,   
  output bjp_req_alu_cmp_ne ,  
  output bjp_req_alu_cmp_lt ,   
  output bjp_req_alu_cmp_ge ,    
  output bjp_req_alu_cmp_ltu,
  output bjp_req_alu_cmp_geu,
  output bjp_req_alu_add,

  input  bjp_req_alu_cmp_res,
  input  [`XLEN-1:0] bjp_req_alu_add_res,

  input  clk,
  input  rst_n
  );

  wire bxx   = bjp_i_info [`DECINFO_BJP_BXX ];    //
  wire jump  = bjp_i_info [`DECINFO_BJP_JUMP ];  //unconditional Jump

  wire wbck_link = jump;
  wire bjp_i_bprdt = bjp_i_info [`DECINFO_BJP_BPRDT];

  assign bjp_req_alu_op1 = wbck_link ? bjp_i_pc : bjp_i_rs1;
  assign bjp_req_alu_op2 = wbck_link ? `XLEN'd4 : bjp_i_rs2;

  assign bjp_o_cmt_bjp = bxx | jump;

  assign bjp_req_alu_cmp_eq  = bjp_i_info [`DECINFO_BJP_BEQ  ];  //4
  assign bjp_req_alu_cmp_ne  = bjp_i_info [`DECINFO_BJP_BNE  ];  //5
  assign bjp_req_alu_cmp_lt  = bjp_i_info [`DECINFO_BJP_BLT  ];  //6
  assign bjp_req_alu_cmp_ge  = bjp_i_info [`DECINFO_BJP_BGE  ];  //7
  assign bjp_req_alu_cmp_ltu = bjp_i_info [`DECINFO_BJP_BLTU ];  //8
  assign bjp_req_alu_cmp_geu = bjp_i_info [`DECINFO_BJP_BGEU ];  //9

  assign bjp_req_alu_add  = wbck_link;

  assign bjp_o_valid     = bjp_i_valid;
  assign bjp_i_ready     = bjp_o_ready;
  assign bjp_o_cmt_prdt  = bjp_i_bprdt;
  assign bjp_o_cmt_rslv  = jump ? 1'b1 : bjp_req_alu_cmp_res;

  assign bjp_o_wbck_wdat  = bjp_req_alu_add_res;
  assign bjp_o_wbck_err   = 1'b0;

endmodule
