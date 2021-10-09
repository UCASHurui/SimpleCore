//=================================================
//Description: core top
//Author : Hurui
//Modules: ifu + exu + lsu
//=================================================
`include "defines.v"

module core (
    output [`PC_SIZE-1:0] inspect_pc,
    input [`PC_SIZE-1:0] pc_rtvec,
    //ifu to itcm interface
    output ifu2itcm_cmd_valid,
    input ifu2itcm_cmd_ready,
    output [`ITCM_ADDR_WIDTH-1:0] ifu2itcm_cmd_addr,

    input ifu2itcm_rsp_valid,
    output ifu2itcm_rsp_ready,
    input [`ITCM_RAM_DW-1:0] ifu2itcm_rsp_rdata,

    //lsu to dtcm interface
    output lsu2dtcm_cmd_valid,
    input lsu2dtcm_cmd_ready,
    output lsu2dtcm_cmd_read,
    output [`DTCM_ADDR_WIDTH-1:0] lsu2dtcm_cmd_addr,
    output [`XLEN-1:0] lsu2dtcm_cmd_wdata,
    output [`XLEN/8-1:0] lsu2dtcm_cmd_wmask,
    input lsu2dtcm_rsp_valid,
    output lsu2dtcm_rsp_ready,
    input [`XLEN-1:0] lsu2dtcm_rsp_rdata,

    input clk,
    input rst_n
);

// instantiate ifu
wire ifu_exu_valid;
wire [`INSTR_SIZE-1:0] ifu_o_ir;
wire [`PC_SIZE-1:0] ifu_o_pc;
wire [`RFIDX_WIDTH-1:0]ifu_o_rs1idx;
wire [`RFIDX_WIDTH-1:0]ifu_o_rs2idx;
wire ifu_o_prdt_taken;
wire pipe_flush_ack;
wire oitf_empty;
wire pipe_flush_req;
wire ifu_exu_ready;
wire [`XLEN-1:0] pipe_flush_add_op1;
wire [`XLEN-1:0] pipe_flush_add_op2;
wire [`XLEN-1:0] rf2ifu_x1;
wire [`XLEN-1:0] rf2ifu_rs1;
wire dec2ifu_rden;
wire dec2ifu_rs1en;
wire [`RFIDX_WIDTH-1:0] dec2ifu_rdidx;

ifu u_ifu (
    .inspect_pc(inspect_pc),
    .pc_rtvec(pc_rtvec),//from input
    .ifu_o_ir(ifu_o_ir),//to exu
    .ifu_o_pc(ifu_o_pc),//to exu
    .ifu_o_rs1idx(ifu_o_rs1idx),//to exu then dec of exu don't need to decode rs1idx again
    .ifu_o_rs2idx(ifu_o_rs2idx),//to exu then dec of exu don't need to decode rs1idx again
    .ifu_o_prdt_taken(ifu_o_prdt_taken),//to exu
    .ifu_o_valid(ifu_exu_valid),//handshake valid with exu
    .ifu_o_ready(ifu_exu_ready),//handshake ready with exu
    .pipe_flush_ack(pipe_flush_ack),//to exu
    .pipe_flush_req(pipe_flush_req),//from exu
    .pipe_flush_add_op1(pipe_flush_add_op1),//from exu
    .pipe_flush_add_op2(pipe_flush_add_op2),//from exu

    .ifu2itcm_cmd_valid(ifu2itcm_cmd_valid),//output to itcm_ctrl
    .ifu2itcm_cmd_ready(ifu2itcm_cmd_ready),//input from itcm_ctrl
    .ifu2itcm_cmd_addr(ifu2itcm_cmd_addr),//output to itcm_ctrl
    .ifu2itcm_rsp_valid(ifu2itcm_rsp_valid),//input from itcm_ctrl
    .ifu2itcm_rsp_ready(ifu2itcm_rsp_ready),//output to itcm_ctrl
    .ifu2itcm_rsp_rdata(ifu2itcm_rsp_rdata),//input from itcm_ctrl

    .oitf_empty(oitf_empty),//from exu
    .rf2ifu_x1(rf2ifu_x1),//from exu
    .rf2ifu_rs1(rf2ifu_rs1),//from exu
    .dec2ifu_rden(dec2ifu_rden),//from exu
    .dec2ifu_rs1en(dec2ifu_rs1en),//from exu
    .dec2ifu_rdidx(dec2ifu_rdidx),//from exu
    .clk(clk),
    .rst_n(rst_n)
);

//instantiate exu
wire lsu_o_ready;
wire agu_cmd_valid;
wire [`DTCM_ADDR_WIDTH-1:0] agu_cmd_addr;
wire agu_cmd_read;
wire [`ITAG_WIDTH-1:0] agu_cmd_itag;
wire [`XLEN-1:0] agu_cmd_wdata;
wire [`XLEN/8-1:0] agu_cmd_wmask;
wire agu_rsp_ready;
wire lsu_o_valid;
wire [`XLEN-1:0] lsu_o_wbck_data;
wire [`ITAG_WIDTH-1:0] lsu_o_wbck_itag;
wire agu_cmd_ready;
wire agu_rsp_valid;

exu u_exu (
    .i_valid(ifu_exu_valid),//from ifu
    .i_ready(ifu_exu_ready),//to ifu
    .i_ir(ifu_o_ir),//from ifu
    .i_pc(inspect_pc),//from ifu
    .i_prdt_taken(ifu_o_prdt_taken),//from ifu
    .i_rs1idx(ifu_o_rs1idx),//from ifu
    .i_rs2idx(ifu_o_rs2idx),//from ifu
    .pipe_flush_ack(pipe_flush_ack),//from  ifu
    .pipe_flush_req(pipe_flush_req),//to ifu
    .pipe_flush_add_op1(pipe_flush_add_op1),//to ifu
    .pipe_flush_add_op2(pipe_flush_add_op2),//to ifu

    .lsu_wbck_i_valid(lsu_o_valid),//from lsu
    .lsu_wbck_i_ready(lsu_o_ready),//to lsu
    .lsu_wbck_i_data(lsu_o_wbck_data),//from lsu
    .lsu_wbck_i_itag(lsu_o_wbck_itag),//from lsu

    .oitf_empty(oitf_empty),//to ifu
    .rf2ifu_x1(rf2ifu_x1),//to ifu
    .rf2ifu_rs1(rf2ifu_rs1),//to ifu
    .dec2ifu_rden(dec2ifu_rden),//to exu
    .dec2ifu_rs1en(dec2ifu_rs1en),//to exu
    .dec2ifu_rdidx(dec2ifu_rdidx),//to exu
    //.dec2_ifu_mulhsu(),
    //.dec2_ifu_div(),
    //.dec2_ifu_rem(),
    //.dec2_ifu_divu(),
    //.dec2_ifu_remu(),

    .agu_cmd_valid(agu_cmd_valid),//to lsu
    .agu_cmd_ready(agu_cmd_ready),//from lsu
    .agu_cmd_addr(agu_cmd_addr),//to lsu
    .agu_cmd_read(agu_cmd_read),//to lsu
    .agu_cmd_itag(agu_cmd_itag),//to lsu
    .agu_cmd_wdata(agu_cmd_wdata),//to lsu
    .agu_cmd_wmask(agu_cmd_wmask),//to lsu
    .agu_rsp_valid(agu_rsp_valid),//from lsu
    .agu_rsp_ready(agu_rsp_ready),//to lsu
    .clk(clk),
    .rst_n(rst_n)
);

//instantiate lsu
lsu u_lsu (
    .lsu_o_valid(lsu_o_valid),//to exu
    .lsu_o_ready(lsu_o_ready),//from exu
    .lsu_o_wbck_data(lsu_o_wbck_data),//to exu
    .lsu_o_wbck_itag(lsu_o_wbck_itag),//to exu

    .agu_cmd_valid(agu_cmd_valid),//from exu
    .agu_cmd_ready(agu_cmd_ready),//to exu
    .agu_cmd_read(agu_cmd_read),//from exu
    .agu_cmd_addr(agu_cmd_addr),//from exu
    .agu_cmd_wdata(agu_cmd_wdata),//from exu
    .agu_cmd_wmask(agu_cmd_wmask),//from exu
    .agu_cmd_itag(agu_cmd_itag),//from exu
    .agu_rsp_valid(agu_rsp_valid),//to exu
    .agu_rsp_ready(agu_rsp_ready),//from exu

    .dtcm_cmd_valid(lsu2dtcm_cmd_valid),//to dtcm_ctrl
    .dtcm_cmd_ready(lsu2dtcm_cmd_ready),//from dtcm_ctrl
    .dtcm_cmd_read(lsu2dtcm_cmd_read),//to dtcm_ctrl
    .dtcm_cmd_addr(lsu2dtcm_cmd_addr),//to dtcm_ctrl
    .dtcm_cmd_wdata(lsu2dtcm_cmd_wdata),//to dtcm_ctrl
    .dtcm_cmd_wmask(lsu2dtcm_cmd_wmask),//to dtcm_ctrl
    .dtcm_rsp_valid(lsu2dtcm_rsp_valid),//from dtcm_ctrl
    .dtcm_rsp_ready(lsu2dtcm_rsp_ready),//to dtcm_ctrl
    .dtcm_rsp_rdata(lsu2dtcm_rsp_rdata),//from dtcm_ctrl
    .clk(clk),
    .rst_n(rst_n)
);
endmodule