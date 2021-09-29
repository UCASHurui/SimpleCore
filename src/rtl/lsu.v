//=================================================
//Description: lsu top
//Author : Hurui
//Modules: instantiate lsu_ctrl
//=================================================
`include "defines.v"

module lsu (
    //LSU write back interface
    output lsu_o_valid,
    input lsu_o_ready,
    output [`XLEN-1:0] lsu_o_wbck_data,
    output [`ITAG_WDITH-1:0] lsu_o_wbck_itag,
    //the AGU  to LSU-ctrl interface
    input agu_cmd_valid,
    output agu_cmd_ready,
    input agu_cmd_read,
    input [`DTCM_AW-1:0] agu_cmd_addr,
    input [`XLEN-1:0] agu_cmd_wdata,
    input [`XLEN/8-1:0] agu_cmd_wmask,
    input [`ITAG_WIDTH-1:0] agu_cmd_itag,
    output agu_rsp_valid,
    input agu_rsp_ready,

    //interface to DTCM
    output dtcm_cmd_valid,
    input dtcm_cmd_ready,
    output dtcm_cmd_read,
    output [`DTCM_AW-1:0] dtcm_cmd_addr,
    output [`XLEN-1:0] dtcm_cmd_wdata,
    output [`XLEN/8-1:0] dtcm_cmd_wmask,
    input dtcm_rsp_valid,
    output dtcm_rsp_ready,
    input [`XLEN-1:0] dtcm_rsp_rdata,
    
    input clk,
    input rst_n
);

lsu_ctrl u_lsu_ctrl (
    .lsu_o_valid(lsu_o_valid),
    .lsu_o_ready(lsu_o_ready),
    .lsu_o_wbck_data(lsu_o_wbck_data),
    .lsu_o_wbck_itag(lsu_o_wbck_itag),
    .agu_cmd_valid(agu_cmd_valid),
    .agu_cmd_ready(agu_cmd_ready),
    .agu_cmd_read(agu_cmd_read),
    .agu_cmd_addr(agu_cmd_addr),
    .agu_cmd_wdata(agu_cmd_wdata),
    .agu_cmd_wmask(agu_cmd_wmask),
    .agu_cmd_itag(agu_cmd_itag),
    .agu_rsp_valid(agu_rsp_valid),
    .agu_rsp_ready(agu_rsp_ready),
    .dtcm_cmd_valid(dtcm_cmd_valid),
    .dtcm_cmd_ready(dtcm_cmd_ready),
    .dtcm_cmd_read(dtcm_cmd_read),
    .dtcm_cmd_addr(dtcm_cmd_addr),
    .dtcm_cmd_wdata(dtcm_cmd_wdata),
    .dtcm_cmd_wmask(dtcm_cmd_wmask),
    .dtcm_rsp_valid(dtcm_rsp_valid),
    .dtcm_rsp_ready(dtcm_rsp_ready),
    .dtcm_rsp_rdata(dtcm_rsp_rdata),
    .clk(clk),
    .rst_n(rst_n)
);
    
endmodule