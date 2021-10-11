//=====================================================================
//
// Designer   : LI Jiarui
//
// Description:
//  The ifetch module to generate next PC and bus request
//
// General logic:
// 1. for first instruction fetch after RESET, use top module input 'pc_rtvec' for pc value for first instruction fetch.
//    users may assign different values to control PC default reset value.
// 2. all SimpleCore instructions are in 32 bit, hence the next PC in sequential fetch should be PC+4
// 3. for branch instruction, use target jump address predicted in 'ifu_bpu.v'
// 4. for instruction from EXU pipeline flush, use address from EXU as new PC
//
// ====================================================================
`include "defines.v"

module ifu_ifetch(
  output[`PC_SIZE-1:0] inspect_pc,
  input  [`PC_SIZE-1:0] pc_rtvec,

  // Fetch Interface to memory system (ITCM), internal protocol
  // Instruction Fetch Request channel
  output ifu_req_valid, 
  input  ifu_req_ready,
  output [`PC_SIZE-1:0] ifu_req_pc, // Fetch PC
  
  // Insrtuction Fetch Response channel
  input  ifu_rsp_valid, // Response valid 
  output ifu_rsp_ready, // Response ready
  input  [`INSTR_SIZE-1:0] ifu_rsp_instr, // Response instruction
  // The Instruction Register stage to EXU interface
  output [`INSTR_SIZE-1:0] ifu_o_ir,// The instruction register
  output [`PC_SIZE-1:0] ifu_o_pc,
  output [`RFIDX_WIDTH-1:0] ifu_o_rs1idx,
  output [`RFIDX_WIDTH-1:0] ifu_o_rs2idx,
  output ifu_o_prdt_taken,               // The Bxx is predicted as taken
  output ifu_o_valid, // Handshake signals with EXU stage
  input  ifu_o_ready,

  output  pipe_flush_ack, // pipeline flush acknowledge
  input   pipe_flush_req, // pipeline flush request
  input   [`PC_SIZE-1:0] pipe_flush_add_op1,  
  input   [`PC_SIZE-1:0] pipe_flush_add_op2,
  input  oitf_empty,
  input  [`XLEN-1:0] rf2ifu_x1,
  input  [`XLEN-1:0] rf2ifu_rs1,
  input  dec2ifu_rs1en,
  input  dec2ifu_rden,
  input  [`RFIDX_WIDTH-1:0] dec2ifu_rdidx,

  input  clk,
  input  rst_n
  );

  wire ifu_req_hsked  = (ifu_req_valid & ifu_req_ready) ;
  wire ifu_rsp_hsked  = (ifu_rsp_valid & ifu_rsp_ready) ;
  wire ifu_ir_o_hsked = (ifu_o_valid & ifu_o_ready) ;
  wire pipe_flush_hsked = pipe_flush_req & pipe_flush_ack;

  // The rst_flag is the synced version of rst_n
 //    * rst_n is asserted 
 // The rst_flag will be clear when
 //    * rst_n is de-asserted 
  wire reset_flag_r;
  gnrl_dffrs #(1) reset_flag_dffrs (1'b0, reset_flag_r, clk, rst_n);
  wire reset_req_r;
  wire reset_req_set = (~reset_req_r) & reset_flag_r;
  wire reset_req_clr = reset_req_r & ifu_req_hsked;
  wire reset_req_ena = reset_req_set | reset_req_clr;
  wire reset_req_nxt = reset_req_set | (~reset_req_clr);
  gnrl_dfflr #(1) reset_req_dfflr (reset_req_ena, reset_req_nxt, reset_req_r, clk, rst_n);
  wire ifu_reset_req = reset_req_r;
  assign pipe_flush_ack = 1'b1;

  // The IR register to be used in EXU for decoding
  wire ir_valid_set;
  wire ir_valid_clr;
  wire ir_valid_ena;
  wire ir_valid_r;
  wire ir_valid_nxt;

  // The ir valid is set when there is new instruction fetched AND no flushing 
  wire pc_newpend_r;
  wire ifu_ir_i_ready;
  assign ir_valid_set  = ifu_rsp_hsked & (~pipe_flush_req);
  
  // The ir valid is cleared when it is accepted by EXU stage OR flushing 
  assign ir_valid_clr  = ifu_ir_o_hsked | (pipe_flush_hsked & ir_valid_r);

  assign ir_valid_ena  = ir_valid_set  | ir_valid_clr;
  assign ir_valid_nxt  = ir_valid_set  | (~ir_valid_clr);

  gnrl_dfflr #(1) ir_valid_dfflr (ir_valid_ena, ir_valid_nxt, ir_valid_r, clk, rst_n);
  // IFU-IR loaded with the returned instruction from the IFetch RSP channel
  wire [`INSTR_SIZE-1:0] ifu_ir_nxt = ifu_rsp_instr;
  
  wire prdt_taken;  
  wire ifu_prdt_taken_r;
  gnrl_dfflr #(1) ifu_prdt_taken_dfflr (ir_valid_set, prdt_taken, ifu_prdt_taken_r, clk, rst_n);

  wire [`INSTR_SIZE-1:0] ifu_ir_r;// The instruction register
  wire ir_ena = ir_valid_set;
  gnrl_dfflr #(`INSTR_SIZE) ifu_ir_dfflr (ir_ena, ifu_ir_nxt, ifu_ir_r, clk, rst_n);

  wire minidec_rs1en;
  wire minidec_rs2en;
  wire [`RFIDX_WIDTH-1:0] minidec_rs1idx;
  wire [`RFIDX_WIDTH-1:0] minidec_rs2idx;
  wire [`PC_SIZE-1:0] pc_r;
  wire [`PC_SIZE-1:0] ifu_pc_nxt = pc_r; // generate next pc
  wire [`PC_SIZE-1:0] ifu_pc_r;
  wire [`RFIDX_WIDTH-1:0] ir_rs1idx_r;
  wire [`RFIDX_WIDTH-1:0] ir_rs2idx_r;
  gnrl_dfflr #(`RFIDX_WIDTH) ifu_rs1idx_dfflr (ir_pc_vld_set, minidec_rs1idx,  ir_rs1idx_r, clk, rst_n);
  gnrl_dfflr #(`RFIDX_WIDTH) ifu_rs2idx_dfflr (ir_pc_vld_set, minidec_rs2idx,  ir_rs2idx_r, clk, rst_n);
  gnrl_dfflr #(`PC_SIZE) ifu_pc_dfflr (ir_pc_vld_set, ifu_pc_nxt,  ifu_pc_r, clk, rst_n);

  assign ifu_o_ir  = ifu_ir_r;
  assign ifu_o_pc  = ifu_pc_r;


  assign ifu_o_rs1idx = ir_rs1idx_r;
  assign ifu_o_rs2idx = ir_rs2idx_r;
  assign ifu_o_prdt_taken = ifu_prdt_taken_r;
  assign ifu_o_valid  = ir_valid_r;

  // The IFU-IR stage will be ready when it is empty or under-clearing
  assign ifu_ir_i_ready   = (~ir_valid_r) | ir_valid_clr;

  

  // JALR instruction dependency check
  wire ir_empty = ~ir_valid_r;
  wire ir_rs1en = dec2ifu_rs1en;
  wire ir_rden = dec2ifu_rden;
  wire [`RFIDX_WIDTH-1:0] ir_rdidx = dec2ifu_rdidx;
  wire [`RFIDX_WIDTH-1:0] minidec_jalr_rs1idx;
  wire jalr_rs1idx_cam_irrdidx = ir_rden & (minidec_jalr_rs1idx == ir_rdidx) & ir_valid_r;

  // Next PC generation
  wire minidec_bjp;
  wire minidec_jal;
  wire minidec_jalr;
  wire minidec_bxx;
  wire [`XLEN-1:0] minidec_bjp_imm;

  // The mini-decoder to check instruciton length and branch type 
  ifu_minidec u_ifu_minidec (
      .instr       (ifu_ir_nxt         ),
      .dec_rs1en   (minidec_rs1en      ),
      .dec_rs2en   (minidec_rs2en      ),
      .dec_rs1idx  (minidec_rs1idx     ),
      .dec_rs2idx  (minidec_rs2idx     ),
      .dec_bjp     (minidec_bjp        ),
      .dec_jal     (minidec_jal        ),
      .dec_jalr    (minidec_jalr       ),
      .dec_bxx     (minidec_bxx        ),

      .dec_jalr_rs1idx (minidec_jalr_rs1idx),
      .dec_bjp_imm (minidec_bjp_imm)
  );

  wire bpu_wait;
  wire [`PC_SIZE-1:0] prdt_pc_add_op1;  
  wire [`PC_SIZE-1:0] prdt_pc_add_op2;
  wire bpu2rf_rs1_ena;//note: not used
  
  ifu_bpu u_ifu_bpu(
    .pc                       (pc_r),
   
    .dec_jal                  (minidec_jal  ),
    .dec_jalr                 (minidec_jalr ),
    .dec_bxx                  (minidec_bxx  ),
    .dec_bjp_imm              (minidec_bjp_imm  ),
    .dec_jalr_rs1idx          (minidec_jalr_rs1idx  ),

    .dec_i_valid              (ifu_rsp_valid),
    .ir_valid_clr             (ir_valid_clr),
                
    .oitf_empty               (oitf_empty),
    .ir_empty                 (ir_empty  ),
    .ir_rs1en                 (ir_rs1en  ),

    .jalr_rs1idx_cam_irrdidx  (jalr_rs1idx_cam_irrdidx),
  
    .bpu_wait                 (bpu_wait       ),  
    .prdt_taken               (prdt_taken     ),  
    .prdt_pc_add_op1          (prdt_pc_add_op1),  
    .prdt_pc_add_op2          (prdt_pc_add_op2),

    .bpu2rf_rs1_ena           (bpu2rf_rs1_ena),
    .rf2bpu_x1                (rf2ifu_x1    ),
    .rf2bpu_rs1               (rf2ifu_rs1   ),

    .clk                      (clk  ) ,
    .rst_n                    (rst_n )                 
  );

  // all SimpleCore instruction is in 32 bit, hence increament is always 4
  wire [2:0] pc_incr_ofst = 3'd4;
  wire [`PC_SIZE-1:0] pc_nxt_pre;
  wire [`PC_SIZE-1:0] pc_nxt;

  wire bjp_req = minidec_bjp & prdt_taken;

  wire [`PC_SIZE-1:0] pc_add_op1 = 
                               ifu_reset_req   ? pc_rtvec :
                               pipe_flush_req  ? pipe_flush_add_op1 :
                               bjp_req ? prdt_pc_add_op1    :
                                                 pc_r;

  wire [`PC_SIZE-1:0] pc_add_op2 =  
                               ifu_reset_req   ? `PC_SIZE'b0 :
                               pipe_flush_req  ? pipe_flush_add_op2 :
                               bjp_req ? prdt_pc_add_op2    :
                                                 pc_incr_ofst ;

  assign ifu_req_last_pc = pc_r;
//1
  assign pc_nxt_pre = pc_add_op1 + pc_add_op2;
  
  assign pc_nxt = {pc_nxt_pre[`PC_SIZE-1:2],2'b00};

  // The Ifetch issue new ifetch request when
  //  1. it is a bjp insturction
  //  2. it does not need to wait
  wire ifu_new_req = (~bpu_wait)& (~reset_flag_r);


  // The fetch request valid is triggering when
  //      * New ifetch request
  //      * or The flush-request is pending
  wire ifu_req_valid_pre = ifu_new_req| ifu_reset_req | pipe_flush_req;
  // The new request ready condition is:
  //   * No outstanding reqeusts
  //   * Or if there is outstanding, but it is reponse valid back
  wire out_flag_clr;
  wire out_flag_r;
  wire new_req_condi = (~out_flag_r) | out_flag_clr;

  assign ifu_req_valid = ifu_req_valid_pre & new_req_condi;
  wire ifu_rsp2ir_ready = (pipe_flush_req) ? 1'b1 : 
                           reset_req_r ? 1'b1:(ifu_ir_i_ready & ifu_req_ready & (~bpu_wait));

  // Response channel only ready when:
  //   * IR is ready to accept new instructions
  assign ifu_rsp_ready = ifu_rsp2ir_ready;

  // The PC will need to be updated when ifu req channel handshaked or a flush is incoming
  wire pc_ena = ifu_req_hsked | pipe_flush_hsked;

  gnrl_dfflr #(`PC_SIZE) pc_dfflr (pc_ena, pc_nxt, pc_r, clk, rst_n);

  assign inspect_pc = pc_r;
  assign ifu_req_pc = pc_nxt;

     // The out_flag will be set if there is a new request handshaked
  wire out_flag_set = ifu_req_hsked;
     // The out_flag will be cleared if there is a request response handshaked
  assign out_flag_clr = ifu_rsp_hsked;
  wire out_flag_ena = out_flag_set | out_flag_clr;
     // If meanwhile set and clear, then set preempt
  wire out_flag_nxt = out_flag_set | (~out_flag_clr);

  gnrl_dfflr #(1) out_flag_dfflr (out_flag_ena, out_flag_nxt, out_flag_r, clk, rst_n);

       // The pc_newpend will be set if there is a new PC loaded
  wire pc_newpend_set = pc_ena;
     // The pc_newpend will be cleared if have already loaded into the IR-PC stage
  wire pc_newpend_clr = ir_pc_vld_set;
  wire pc_newpend_ena = pc_newpend_set | pc_newpend_clr;
     // If meanwhile set and clear, then set preempt
  wire pc_newpend_nxt = pc_newpend_set | (~pc_newpend_clr);
  gnrl_dfflr #(1) pc_newpend_dfflr (pc_newpend_ena, pc_newpend_nxt, pc_newpend_r, clk, rst_n);
endmodule

