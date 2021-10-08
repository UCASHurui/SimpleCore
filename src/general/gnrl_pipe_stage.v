//=================================================
//Description: load store ctrl unit
//Author : Hurui
//Modules: lsu_ctrl
//=================================================
module gnrl_pipe_stage #(
    //parameter CUT_READY = 0,
    parameter DP = 1,
    parameter DW = 32
)(
    input           i_vld, 
    output          i_rdy, 
    input  [DW-1:0] i_dat,
    output          o_vld, 
    input           o_rdy, 
    output [DW-1:0] o_dat,

    input           clk,
    input           rst_n
);
    wire vld_set;
    wire vld_clr;
    wire vld_ena;
    wire vld_r;
    wire vld_nxt;

    assign vld_set = i_vld & i_rdy;
    assign vld_clr = o_vld & o_rdy;

    assign vld_ena = vld_set | vld_clr;
    assign vld_nxt = vld_set | (~ vld_clr);

    gnrl_dfflr #(1) vld_dfflr(vld_ena, vld_nxt, vld_r, clk);
    gnrl_dfflr #(DW) dat_dfflr(vld_set, i_dat, o_dat, clk);

    assign o_vld = vld_r;
    assign i_rdy = (~vld_r) | vld_clr;
endmodule