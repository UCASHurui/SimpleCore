//=================================================
//Description: core top
//Author : Hurui
//Modules: ifu + exu + lsu
//=================================================
`include "defines.v"

module core (
    output [`PC_SIZE-1:0] inspect_pc,
    
    //ifu to itcm interface
    output ifu2itcm_cmd_valid,
    input ifu2itcm_cmd_ready,
    output [`ITCM_RAM_AW-1:0] ifu2itcm_cmd_addr,

    input ifu2itcm_rsp_valid,
    output ifu2itcm_rsp_ready,
    input [`ITCM_RAM_DW-1:0] ifu2itcm_rsp_rdata,

    //lsu to dtcm interface
    output lsu2dtcm_cmd_valid,
    input lsu2dtcm_cmd_ready,
    output lsu2dtcm_cmd_read;
    output [`DTCM_RAM_AW-1:0] lsu2dtcm_cmd_addr,
    output [`XLEN-1:0] lsu2dtcm_cmd_wdata,
    output [`XLEN/8-1:0] lsu2dtcm_cmd_wmask,
    input lsu2dtcm_rsp_valid,
    output lsu2dtcm_rsp_ready,
    input [`XLEN-1:0] lsu2dtcm_rsp_rdata,

    input clk,
    input rst_n
);
wire ifu_o_valid;
wire [`XLEN-1:0] ifu_o_ir;
wire [`PC_SIZE-1:0] ifu_o_pc;
wire [`RFIDX_WIDTH-1:0]ifu_o_rs1idx;
wire [`RFIDX_WIDTH-1:0]ifu_o_rs2idx;
wire ifu_o_prdt_taken;
assign ifu2itcm_cmd_addr = inspect_pc[`PC_SIZE-1:`PC_SIZE - `ITCM_RAM_AW]; //ifu are only allowed to read itcm through pc addr
ifu u_ifu (
    .inspect_pc(inspect_pc),
    .ifu_active(),
    .itcm_nohold(),
    .pc_rtvec(),
    .ifu_o_ir(ifu_o_ir),
    .ifu_o_pc(ifu_o_pc),
    .ifu_o_rs1idx(ifu_o_rs1idx),
    .ifu_o_rs2idx(ifu_o_rs2idx),
    .ifu_o_prdt_taken(ifu_o_prdt_taken),
    .ifu_o_valid(),//handshake valid with exu
    .ifu_o_ready(),//handshake ready with exu
    .pipe_flush_ack(),
    .pipe_flush_req(),
    .pipe_flush_add_op1(),
    .pipe_flush_add_op2(),
    .ifu_halt_req(),
    .ifu_halt_ack(),
    .oitf_empty(),
    .rf2ifu_x1(),
    .rf2ifu_rs1(),
    .dec2ifu_rden(),
    .dec2ifu_rs1en(),
    .dec2ifu_rdidx(),
    .clk(clk),
    .rst_n(rst_n)
);

//instantiate exu

//instantiate lsu

endmodule