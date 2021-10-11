//=================================================
//Description: the commit moduel to commit instructions or flush pipeline, only branchmis may cause pipeline flush
//Author : Hurui
//Modules: exu_longpwbck
//=================================================
`include "defines.v"

module exu_commit (
    output nonflush_cmt_ena,

    input alu_cmt_i_valid,
    output alu_cmt_i_ready,
    input [`XLEN-1:0] alu_cmt_i_imm,
    input alu_cmt_i_bjp,
    input alu_cmt_i_bjp_prdt,//predicted taken or not
    input alu_cmt_i_bjp_rslv,//resolved taken or not
    input [`PC_SIZE-1:0] alu_cmt_i_pc,
    input alu_cmt_i_ilegl,
    //Flush interface to IFU
    output flush_pulse,
    //output flush_req, //since only branch may cause flush in our implementation
    input pipe_flush_ack,
    output pipe_flush_req,
    output [`PC_SIZE-1:0] pipe_flush_add_op1,
    output [`PC_SIZE-1:0] pipe_flush_add_op2
);

    wire alu_brchmis_flush_ack = pipe_flush_ack;
    wire [`PC_SIZE-1:0] alu_brchmis_add_op1;
    wire [`PC_SIZE-1:0] alu_brchmis_add_op2;
    assign pipe_flush_add_op1 = alu_brchmis_add_op1;
    assign pipe_flush_add_op2 = alu_brchmis_add_op2;

    exu_branchslv u_exu_branchslv (
        .cmt_i_valid(alu_cmt_i_valid),
        .cmt_i_ready(alu_cmt_i_ready),
        .cmt_i_bjp(alu_cmt_i_bjp),
        .cmt_i_bjp_prdt(alu_cmt_i_bjp_prdt),
        .cmt_i_bjp_rslv(alu_cmt_i_bjp_rslv),
        .cmt_i_pc(alu_cmt_i_pc),
        .cmt_i_imm(alu_cmt_i_imm),
        .brchmis_flush_ack(alu_brchmis_flush_ack),
        .brchmis_flush_req(pipe_flush_req),
        .brchmis_flush_add_op1(alu_brchmis_add_op1),
        .brchmis_flush_add_op2(alu_brchmis_add_op2)
    );
    
    assign flush_pulse = pipe_flush_ack & pipe_flush_req; //flush handshaked
    wire cmt_ena = alu_cmt_i_valid & alu_cmt_i_ready;
    assign nonflush_cmt_ena = (~pipe_flush_req) & cmt_ena;
endmodule