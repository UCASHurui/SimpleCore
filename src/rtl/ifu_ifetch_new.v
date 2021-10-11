
`include "defines.v"

module ifu_ifetch(
   output[`PC_SIZE-1:0] inspect_pc,
   input  [`PC_SIZE-1:0] pc_rtvec,
   output ifu_req_valid, 
   input  ifu_req_ready,
   output [`PC_SIZE-1:0] ifu_req_pc,
   input  ifu_rsp_valid, 
   output ifu_rsp_ready, 
   input  [`INSTR_SIZE-1:0] ifu_rsp_instr, 

   output [`INSTR_SIZE-1:0] ifu_o_ir,// The instruction register
   output [`PC_SIZE-1:0] ifu_o_pc,
   output [`RFIDX_WIDTH-1:0] ifu_o_rs1idx,
   output [`RFIDX_WIDTH-1:0] ifu_o_rs2idx,
   output ifu_o_prdt_taken, // The Bxx is predicted as taken
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

   //instantiate minidec
   wire minidec_bjp;
   wire minidec_jal;
   wire minidec_jalr;
   wire minidec_bxx;
   wire [`XLEN-1:0] minidec_bjp_imm;
   wire [`RFIDX_WIDTH-1:0] minidec_jalr_rs1idx;
   wire minidec_rs1en;  
   wire minidec_rs2en;
   wire [`RFIDX_WIDTH-1:0] minidec_rs1idx;
   wire [`RFIDX_WIDTH-1:0] minidec_rs2idx;
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

      //instantiate bpu
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
      .ir_valid_clr             (ir_valid_clr),//note :signal rmved
                  
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
   // reset
   // ir generate 
   wire ifu_req_hsked  = (ifu_req_valid & ifu_req_ready);
   wire ifu_rsp_hsked  = (ifu_rsp_valid & ifu_rsp_ready);
   wire ifu_ir_o_hsked = (ifu_o_valid & ifu_o_ready);
   assign pipe_flush_ack = 1'b1;//always accept pipeflush
   wire pipe_flush_hsked = pipe_flush_req & pipe_flush_ack;

   wire prdt_taken;  
   wire ifu_prdt_taken_r;
   gnrl_dfflr #(1) ifu_prdt_taken_dfflr (ir_valid_set, prdt_taken, ifu_prdt_taken_r, clk, rst_n);

   wire [`INSTR_SIZE-1:0] ifu_ir_r;// The instruction register
   wire [`INSTR_SIZE-1:0] ifu_ir_nxt = ifu_rsp_instr;//read from ITCM
   gnrl_dfflr #(`INSTR_SIZE) ifu_ir_dfflr (ir_ena, ifu_ir_nxt, ifu_ir_r, clk, rst_n);


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
   wire [`RFIDX_WIDTH-1:0] ir_rdidx = dec2ifu_rdidx;

   wire jalr_rs1idx_cam_irrdidx = dec2ifu_rden & (minidec_jalr_rs1idx == ir_rdidx);

   // Next PC generation
   wire hold_req;
   wire [`PC_SIZE-1:0] pc_nxt_pre;
   wire [`PC_SIZE-1:0] pc_nxt;

   wire bjp_req = minidec_bjp & prdt_taken;

   wire [`PC_SIZE-1:0] pc_add_op1 = 
                                 ifu_reset_req   ? pc_rtvec :
                                 ifu_hold_req   ? pc_r :
                                 pipe_flush_req  ? pipe_flush_add_op1 :
                                 bjp_req ? prdt_pc_add_op1    :
                                                   pc_r;

   wire [`PC_SIZE-1:0] pc_add_op2 =  
                                 ifu_reset_req   ? `PC_SIZE'b0 :
                                 ifu_hold_req   ? `PC_SIZE'b0 :
                                 pipe_flush_req  ? pipe_flush_add_op2 :
                                 bjp_req ? prdt_pc_add_op2    :
                                                   `PC_SIZE'd4 ;

   assign ifu_req_last_pc = pc_r;
   assign pc_nxt_pre = pc_add_op1 + pc_add_op2;
   assign pc_nxt = {pc_nxt_pre[`PC_SIZE-1:2],2'b00};


   assign ifu_rsp_ready = ;
   gnrl_dfflr #(`PC_SIZE) pc_dfflr (pc_ena, pc_nxt, pc_r, clk, rst_n);
   assign inspect_pc = pc_r;
   assign ifu_req_pc = pc_nxt;
   endmodule

