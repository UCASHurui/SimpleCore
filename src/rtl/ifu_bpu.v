//=====================================================================
// Author: LI Jiarui
//
// Description:
//  Branch Prediction Unit of IFU
//  To conduct branch prediction of B/J instructions captured after ifu_minidec
//  Static Predictions only 
// ====================================================================
`include "defines.v"

module ifu_bpu(

  // Current PC of instruction
  input  [`PC_SIZE-1:0] pc,

  // The mini-decoded info 
  input  dec_jal,  
  input  dec_jalr,
  input  dec_bxx,  // Conditional branch/jump 
  input  [`XLEN-1:0] dec_bjp_imm, // immediate number operation
  input  [`RFIDX_WIDTH-1:0] dec_jalr_rs1idx,

  // The Instruction Register index and OITF status to be used for checking dependency
  input  oitf_empty, //Oustanding Instructions Track FIFO to hold all the non-ALU long pipeline instruction's status and information
  input  ir_empty,
  input  ir_rs1en,
  input  jalr_rs1idx_cam_irrdidx,
  
  // The add op to next-pc adder
  output bpu_wait,  
  output prdt_taken,  // predict if taken, BTFN
  output [`PC_SIZE-1:0] prdt_pc_add_op1,  
  output [`PC_SIZE-1:0] prdt_pc_add_op2,

  input  dec_i_valid,

  // The RS1 to read regfile
  output bpu2rf_rs1_ena,
  input  ir_valid_clr,
  input  [`XLEN-1:0] rf2bpu_x1,
  input  [`XLEN-1:0] rf2bpu_rs1,

  input  clk,
  input  rst_n
  );


  // Static branch prediction logics of BPU
  //   * JAL: The target address of JAL is calculated based on current PC value
  //          and offset, and JAL is unconditionally always jump
  //
  //   * JALR with rs1 == x0: The target address of JALR is calculated based on
  //          x0+offset, and JALR is unconditionally always jump
  //
  //   * JALR with rs1 = x1: The x1 register value is directly wired from regfile
  //          when the x1 have no dependency with ongoing instructions by checking
  //          two conditions:
  //            ** (1) The OTIF in EXU must be empty 
  //            ** (2) The instruction in IR have no x1 as destination register
  //          * If there is dependency, then hold up IFU until the dependency is cleared
  //
  //   * JALR with rs1 != x0 or x1: The target address of JALR need to be resolved
  //          at EXU stage, hence have to be forced halted, wait the EXU to be
  //          empty and then read the regfile to grab the value of xN.
  //          This will exert 1 cycle performance lost for JALR instruction
  //
  //   * Bxxx(BTFN): Conditional branch is always predicted as taken if it is backward
  //          jump, and not-taken if it is forward jump. The target address of JAL
  //          is calculated based on current PC value and offset
  
  // The JAL and JALR always jump, only when bxxx backward is predicted as taken  (BTFN) 
  // when immediate number offset is negative, aka the top sign is 1, represents backward jump
  // discriminated by: dec_bjp_imm[`XLEN-1]
  assign prdt_taken   = (dec_jal | dec_jalr | (dec_bxx & dec_bjp_imm[`XLEN-1]));  

  // The JALR with rs1 == x1 have dependency or xN have dependency
  wire dec_jalr_rs1x0 = (dec_jalr_rs1idx == `RFIDX_WIDTH'd0);
  wire dec_jalr_rs1x1 = (dec_jalr_rs1idx == `RFIDX_WIDTH'd1);
  // wire dec_jalr_rs1xn = (~dec_jalr_rs1x0) & (~dec_jalr_rs1x1);

  wire jalr_rs1x1_dep = dec_i_valid & dec_jalr & dec_jalr_rs1x1 & ((~oitf_empty) | (jalr_rs1idx_cam_irrdidx));
  wire jalr_rs1xn_dep = dec_i_valid & dec_jalr & dec_jalr_rs1xn & ((~oitf_empty) | (~ir_empty));

                      // If only depend to IR stage (OITF is empty), then if IR is under clearing, or
                          // it does not use RS1 index, then we can also treat it as non-dependency
  wire jalr_rs1xn_dep_ir_clr = (jalr_rs1xn_dep & oitf_empty & (~ir_empty)) & (ir_valid_clr | (~ir_rs1en));

  wire rs1xn_rdrf_r;
  wire rs1xn_rdrf_set = (~rs1xn_rdrf_r) & dec_i_valid & dec_jalr & dec_jalr_rs1xn & ((~jalr_rs1xn_dep) | jalr_rs1xn_dep_ir_clr);
  wire rs1xn_rdrf_clr = rs1xn_rdrf_r;
  wire rs1xn_rdrf_ena = rs1xn_rdrf_set |   rs1xn_rdrf_clr;
  wire rs1xn_rdrf_nxt = rs1xn_rdrf_set | (~rs1xn_rdrf_clr);

  sirv_gnrl_dfflr #(1) rs1xn_rdrf_dfflrs(rs1xn_rdrf_ena, rs1xn_rdrf_nxt, rs1xn_rdrf_r, clk, rst_n);

  assign bpu2rf_rs1_ena = rs1xn_rdrf_set;

  assign bpu_wait = jalr_rs1x1_dep | jalr_rs1xn_dep | rs1xn_rdrf_set;

  // all PC shares the same ADDER to save area

  // to get target jump address, add PC and immediate number representation of offset 
  // ADDER operation 1, use self PC address for bxx insrtuction
  assign prdt_pc_add_op1 = (dec_bxx | dec_jal) ? pc[`PC_SIZE-1:0]
                         : (dec_jalr & dec_jalr_rs1x0) ? `PC_SIZE'b0
                         : (dec_jalr & dec_jalr_rs1x1) ? rf2bpu_x1[`PC_SIZE-1:0]
                         : rf2bpu_rs1[`PC_SIZE-1:0];  
 
  // ADDER operation 2, represent offset by immediate number
  assign prdt_pc_add_op2 = dec_bjp_imm[`PC_SIZE-1:0];  

endmodule
