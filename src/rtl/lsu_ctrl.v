//=================================================
//Description: load store ctrl unit
//Author : Hurui
//Modules: lsu_ctrl
//=================================================
`include "defines.v"

module lsu_ctrl (
    //The LSU write-back interface(to longpipe wbck)
    output lsu_o_valid,
    input lsu_o_ready,
    output [`XLEN-1:0] lsu_o_wbck_data,
    output [`ITAG_WIDTH-1:0] lsu_o_wbck_itag,

    //AGU to LSU-ctrl interface
    input agu_cmd_valid,
    output agu_cmd_ready,
    input agu_cmd_read,
    input [`DTCM_ADDR_WIDTH-1:0] agu_cmd_addr,
    input [`XLEN-1:0] agu_cmd_wdata,
    input [`XLEN/8-1:0] agu_cmd_wmask,
    input [`ITAG_WIDTH-1:0] agu_cmd_itag,
    output agu_rsp_valid,
    input agu_rsp_ready,

    //LSU to DTCM interface
    output dtcm_cmd_valid,
    input dtcm_cmd_ready,
    output dtcm_cmd_read,
    output [`DTCM_ADDR_WIDTH-1:0] dtcm_cmd_addr,
    output [`XLEN-1:0] dtcm_cmd_wdata,
    output [`XLEN/8-1:0] dtcm_cmd_wmask,
    input dtcm_rsp_valid,
    output dtcm_rsp_ready,
    input [`XLEN-1:0] dtcm_rsp_rdata,
    
    input clk,
    input rst_n
);
    wire wbck_hsked = dtcm_rsp_ready & dtcm_rsp_valid;
    assign lsu_o_valid = wbck_hsked;
    assign lsu_o_wbck_data = {`XLEN{wbck_hsked}} & dtcm_rsp_rdata;
    wire fifo_i_ready;
    assign agu_cmd_ready = fifo_i_ready; //dtcm ready to accept new instruction when there is no existing outstand lsu instruction
    assign agu_rsp_valid = wbck_hsked;
    
    assign dtcm_cmd_valid = agu_cmd_valid;
    assign dtcm_cmd_read = agu_cmd_read;
    assign dtcm_cmd_addr = agu_cmd_addr;
    assign dtcm_cmd_wdata = agu_cmd_wdata;
    assign dtcm_cmd_wmask = agu_cmd_wmask;
    assign dtcm_rsp_ready = 1'b1; //LSU always ready to accept data from DTCM

    //third pipeline stage
    //although OITF is 2 instructions deep, we only allow 1 outstanding instruction for lsu
    wire [`ITAG_WIDTH-1:0] agu_cmd_fifo_data = 
        agu_cmd_itag;
    wire fifo_i_valid = agu_cmd_valid;
   
    wire fifo_o_valid;
    wire fifo_o_ready = 1'b1;
    wire [`ITAG_WIDTH-1:0] fifo_o_rdata;
    assign lsu_o_wbck_itag= {`ITAG_WIDTH{wbck_hsked}}&fifo_o_rdata;
  
    //Assume DTCM return data 1cycle later
    gnrl_pipe_stage #(
        .DW(`ITAG_WIDTH),
        .DP(1)
    ) u_lsu_pipe_stage (
        .i_vld(fifo_i_valid),
        .i_rdy(fifo_i_ready),
        .i_dat(agu_cmd_itag),
        .o_vld(dtcm_rsp_valid), //rsp valid from dtcm
        .o_rdy(fifo_o_ready),
        .o_dat(fifo_o_rdata),
        .clk(clk),
        .rst_n(rst_n)
    );

endmodule