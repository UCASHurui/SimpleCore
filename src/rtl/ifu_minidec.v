//=====================================================================
// Author : LI Jiarui
// Reference: hbird_e200_opensource
//
// Description:
//  The mini-decode module to decode the instruction in IFU in SimpleCore
//
// ====================================================================

`include "defines.v"

module ifu_minidec(

  //////////////////////////////////////////////////////////////
  // The IR stage to Decoder
  input  [`INSTR_SIZE-1:0] instr,
  
  //////////////////////////////////////////////////////////////
  // The Decoded Info-Bus


  output dec_rs1en,
  output dec_rs2en,
  output [`RFIDX_WIDTH-1:0] dec_rs1idx,
  output [`RFIDX_WIDTH-1:0] dec_rs2idx,
  
  // instructions are all 32 bits
  output dec_bjp, // if current instructions is branch/jump instruction 
  output dec_jal,
  output dec_jalr,
  output dec_bxx, // conditional branch
  output [`RFIDX_WIDTH-1:0] dec_jalr_rs1idx,
  output [`XLEN-1:0] dec_bjp_imm 

  );

  exu_decode u_exu_decode(

  .i_instr(instr),
  .i_pc(`PC_SIZE'b0),
  .i_prdt_taken(1'b0), 
  .dec_ilegl(),

  .dec_rs1en(dec_rs1en),
  .dec_rs2en(dec_rs2en),
  .dec_rdwen(),
  .dec_rs1idx(dec_rs1idx),
  .dec_rs2idx(dec_rs2idx),
  .dec_rdidx(),
  .dec_info(),  
  .dec_imm(),
  .dec_pc(),

  .dec_bjp (dec_bjp ),
  .dec_jal (dec_jal ),
  .dec_jalr(dec_jalr),
  .dec_bxx (dec_bxx ),

  .dec_jalr_rs1idx(dec_jalr_rs1idx),
  .dec_bjp_imm    (dec_bjp_imm    )  
  );


endmodule