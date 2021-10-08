/*
  Basic functions and interface of IFU module
  1. IFU的PC生成单元产生下一条指令的PC�?
     The PC generator generates the Program Counter(PC) of next instruction
  2. �?PC传输到地址判断和ICB生成单元，就�?根据PC值产生相应�?�指请求，可能的指令�?的是ITCM或者�?�部存储，�?�部存储通过BIU访问�?
     Such PC is then transmitted to address discriminator and ICB generator, loading instruction request is generated according to PC, possible destination are ITCM or external memory.
     external memory is read through BIU. 
  3. �?PC值也会传输到和EXU单元接口的PC寄存器中�?
     Such is PC is also transmitted to PC register interfaced with EXU unit. 
  4. 取回的指令会放置到和EXU接口的IR(Instruction register)寄存器中。EXU单元会根�?指令和其对应的PC值进行后�?的操作�?
  5. 因为每个周期都�?�产生下一条指令的PC，所以取回的指令也会传入Mini-Decode单元，进行简单的译码操作，判�?当前指令�?�?通指令还�?分支跳转指令�?
     如果判别为分�?跳转指令，则在同一周期进�?�分�?预测�?
     最后，根据译码的信�?和分�?预测的信�?生成下一条指令的PC�?
  6. 来自commit模块的冲刷�?�线请求会�?�位PC值�?
*/


//=====================================================================
//
// Author : LI Jiarui 
//
// Description:
//  The instruction fetch unit(IFU) of SimpleCore.
//
// ====================================================================

`include "defines.v"

module ifu (
    output [`PC_SIZE-1:0] inspect_pc,
    output ifu_active,
    input itcm_nohold,
    input [`PC_SIZE-1:0] pc_rtvec,
   
  // The IR stage to EXU interface
  output [`INSTR_SIZE-1:0] ifu_o_ir,// The instruction register
  output [`PC_SIZE-1:0] ifu_o_pc,   // The PC register along with
  output [`RFIDX_WIDTH-1:0] ifu_o_rs1idx,
  output [`RFIDX_WIDTH-1:0] ifu_o_rs2idx,
  output ifu_o_prdt_taken,               // The Bxx is predicted as taken
  //output ifu_o_muldiv_b2b,               
  output ifu_o_valid, // Handshake signals with EXU stage
  input  ifu_o_ready,

  output  pipe_flush_ack,
  input   pipe_flush_req,
  input   [`PC_SIZE-1:0] pipe_flush_add_op1,  
  input   [`PC_SIZE-1:0] pipe_flush_add_op2,
  
  input [`ADDR_SIZE-1:0] itcm_region_indic,
  //ifu to itcm module
  output ifu2itcm_cmd_valid, // Handshake valid
  input  ifu2itcm_cmd_ready, // Handshake ready
  // Note: The data on rdata or wdata channel must be naturally aligned, this is in line with the AXI definition
  output [`ITCM_ADDR_WIDTH-1:0]   ifu2itcm_cmd_addr, // Bus transaction start addr 

  //    * Bus RSP channel
  input  ifu2itcm_rsp_valid, // Response valid 
  output ifu2itcm_rsp_ready, // Response ready
  //input  ifu2itcm_rsp_err,   // Response error 
  // Note: the RSP rdata is inline with AXI definition
  input  [`ITCM_DATA_WIDTH-1:0] ifu2itcm_icb_rsp_rdata, 

  input  oitf_empty,
  //Regfile to ifu interface
  input  [`XLEN-1:0] rf2ifu_x1,
  input  [`XLEN-1:0] rf2ifu_rs1,

  input  dec2ifu_rden,
  input  dec2ifu_rs1en,
  input  [`RFIDX_WIDTH-1:0] dec2ifu_rdidx,
  //input  dec2ifu_mulhsu,
  //input  dec2ifu_div   ,
  //input  dec2ifu_rem   ,
  //input  dec2ifu_divu  ,
  //input  dec2ifu_remu  ,

  input  clk,
  input  rst_n
);

  
  wire ifu_req_valid; 
  wire ifu_req_ready; 
  wire [`PC_SIZE-1:0]   ifu_req_pc; 
  wire ifu_req_seq;
  //wire ifu_req_seq_rv32;
  wire [`PC_SIZE-1:0] ifu_req_last_pc;
  wire ifu_rsp_valid; 
  wire ifu_rsp_ready; 
  wire ifu_rsp_err;   
  //wire ifu_rsp_replay;   
  wire [`INSTR_SIZE-1:0] ifu_rsp_instr; 

  ifu_ifetch u_ifu_ifetch(
    .inspect_pc   (inspect_pc),
    .pc_rtvec      (pc_rtvec),  
    .ifu_req_valid (ifu_req_valid),
    .ifu_req_ready (ifu_req_ready),
    .ifu_req_pc    (ifu_req_pc   ),
    .ifu_req_seq     (ifu_req_seq     ),
    .ifu_req_last_pc (ifu_req_last_pc ),
    .ifu_rsp_valid (ifu_rsp_valid),
    .ifu_rsp_ready (ifu_rsp_ready),
    .ifu_rsp_err   (ifu_rsp_err  ),
    .ifu_rsp_instr (ifu_rsp_instr),
    .ifu_o_ir      (ifu_o_ir     ),
    .ifu_o_pc      (ifu_o_pc     ),
    .ifu_o_pc_vld  (ifu_o_pc_vld ),
    .ifu_o_rs1idx  (ifu_o_rs1idx),
    .ifu_o_rs2idx  (ifu_o_rs2idx),
    .ifu_o_prdt_taken(ifu_o_prdt_taken),
    //.ifu_o_muldiv_b2b(ifu_o_muldiv_b2b),
    .ifu_o_valid   (ifu_o_valid  ),
    .ifu_o_ready   (ifu_o_ready  ),
    .pipe_flush_ack     (pipe_flush_ack    ), 
    .pipe_flush_req     (pipe_flush_req    ),
    .pipe_flush_add_op1 (pipe_flush_add_op1),     
    .pipe_flush_add_op2 (pipe_flush_add_op2), 

    .oitf_empty    (oitf_empty   ),
    .rf2ifu_x1     (rf2ifu_x1    ),
    .rf2ifu_rs1    (rf2ifu_rs1   ),
    .dec2ifu_rden  (dec2ifu_rden ),
    .dec2ifu_rs1en (dec2ifu_rs1en),
    .dec2ifu_rdidx (dec2ifu_rdidx),
    //.dec2ifu_mulhsu(dec2ifu_mulhsu),
    //.dec2ifu_div   (dec2ifu_div   ),
    //.dec2ifu_rem   (dec2ifu_rem   ),
    //.dec2ifu_divu  (dec2ifu_divu  ),
    //.dec2ifu_remu  (dec2ifu_remu  ),

    .clk           (clk),
    .rst_n         (rst_n) 
  );



  ifu_ifu2itcm u_ifu_ifu2itcm (
    .ifu_req_valid (ifu_req_valid),
    .ifu_req_ready (ifu_req_ready),
    .ifu_req_pc    (ifu_req_pc   ),
    .ifu_req_seq     (ifu_req_seq     ),
    .ifu_req_last_pc (ifu_req_last_pc ),
    .ifu_rsp_valid (ifu_rsp_valid),
    .ifu_rsp_ready (ifu_rsp_ready),
    .ifu_rsp_err   (ifu_rsp_err  ),
    .ifu_rsp_instr (ifu_rsp_instr),
    .itcm_nohold   (itcm_nohold),


  
    .itcm_region_indic (itcm_region_indic),
    
    .ifu2itcm_cmd_valid(ifu2itcm_cmd_valid),
    .ifu2itcm_cmd_ready(ifu2itcm_cmd_ready),
    
    //.ifu2itcm_cmd_addr (ifu2itcm_cmd_addr ),
    
    .ifu2itcm_rsp_valid(ifu2itcm_rsp_valid),
    .ifu2itcm_rsp_ready(ifu2itcm_rsp_ready),
    //.ifu2itcm_icb_rsp_err  (ifu2itcm_icb_rsp_err  ),
    .ifu2itcm_icb_rsp_rdata(ifu2itcm_rsp_rdata),

    .ifu2itcm_holdup (ifu2itcm_holdup),
    .clk           (clk          ),
    .rst_n         (rst_n        ) 
  );

  assign ifu_active = 1'b1;// Seems the IFU never rest at block level
  assign ifu2itcm_cmd_addr =  inspect_pc;
    
endmodule