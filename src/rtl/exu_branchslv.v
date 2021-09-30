//=================================================
//Description: EXU branch solve module
// resolve branch instructions(check if pipeline flush needed)
//Author : Hurui
//Modules: exu_wbck
//=================================================
`include "defines.v"

module exu_branchslv (
    input cmt_i_valid,
    output cmt_i_ready,
    input cmt_i_bjp,
    input cmt_i_bjp_prdt, //predicted branch taken or not
    input cmt_i_bjp_rslv,//the resolved true/false
    input [`PC_SIZE-1:0] cmt_i_pc,
    input [`XLEN-1:0] cmt_i_imm,

    input brchmis_flush_ack,//from ifu, always ready to accept flush
    output brchmis_flush_req,
    output [`PC_SIZE-1:0] brchmis_flush_add_op1,
    output [`PC_SIZE-1:0] brchmis_flush_add_op2
);
wire brchmis_need_flush = cmt_i_bjp
                                            & (cmt_i_bjp_prdt ^ cmt_i_bjp_rslv) // prediction != resolve then flush
wire brchmis_flush_req = cmt_i_valid & brchmis_need_flush;
//wire brchmis_flush_hsked = brchmis_flush_req & brchmis_flush_ack;

assign cmt_i_ready = (~cmt_i_bjp) | 
                                   (brchmis_need_flush? brchmis_flush_ack:1'b1);

assign brchmis_flush_add_op1 = cmt_i_pc;
assign brchmis_flush_add_op2 = cmt_i_bjp_prdt? `PC_SIZE'd4:cmt_i_imm[`PC_SIZE-1:0];
endmodule 