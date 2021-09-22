// =====================================
//Testbench for Decode
//Author:     HuRui
//Modules:    tb_exu_decode
//create test case for each input instruction(which defined using macro)
//only one instruction per test
//=====================================
`timescale 1ns/1ps
`include "defines.v"

//`define TEST_LUI
//`define TEST_AUIPC
//`define TEST_JAL
//`define TEST_JALR
`define TEST_BEQ
//`define TEST_BNE
//`define TEST_BLT
//`define TEST_BGE
//`define TEST_BLTU
//`define TEST_BGEU
//`define TEST_LB
//`define TEST_LH
//`define TEST_LW
//`define TEST_LBU
//`define TEST_LHU
//`define TEST_SB
//`define TEST_SH
//`define TEST_SW
//`define TEST_ADDI
//`define TEST_SLTI
//`define TEST_SLTIU
//`define TEST_XORI
//`define TEST_ORI
//`define TEST_ANDI
//`define TEST_SLLI
//`define TEST_SRLI
//`define TEST_SRAI
//`define TEST_ADD
//`define TEST_SUB
//`define TEST_SLL
//`define TEST_SLT
//`define TEST_SLTU
//`define TEST_XOR
//`define TEST_SRL
//`define TEST_SRA
//`define TEST_OR
//`define TEST_AND
//`define TEST_MUL
//`define TEST_MULH
//`define TEST_MULHSU
//`define TEST_MULHU
//`define TEST_DIV
//`define TEST_DIVU
//`define TEST_REM
//`define TEST_REMU
//`define TEST_NOP
module tb_exu_decode;
reg [`XLEN-1:0] i_instr;
reg [`PC_SIZE-1:0] i_pc;
reg i_prdt_taken;

wire [`XLEN-1:0]i_instr_ = i_instr;
wire [`PC_SIZE-1:0] i_pc_ = i_pc;
wire i_prdt_taken_ = i_prdt_taken;
wire o_dec_rs1en;
wire o_dec_rs2en;
wire o_dec_rdwen;
wire [`RFIDX_WIDTH-1:0]o_dec_rs1idx;
wire [`RFIDX_WIDTH-1:0]o_dec_rs2idx;
wire [`RFIDX_WIDTH-1:0]o_dec_rdidx;
wire [`DECINFO_WIDTH-1:0] o_dec_info;
wire [`XLEN-1:0] o_dec_imm;
wire [`PC_SIZE-1:0] o_dec_pc;
wire o_dec_illegal;
wire o_dec_bjp;
wire o_dec_jal;
wire o_dec_jalr;
wire o_dec_bxx;
wire [`RFIDX_WIDTH-1:0] o_dec_jalr_rs1idx;
wire [`XLEN-1:0] o_dec_bjp_imm;

// initialization
initial begin
    i_instr = 0;
    i_pc = 0;
    i_prdt_taken = 0;
end

//instatiation
exu_decode u_exu_decode(
    .i_instr(i_instr_),
    .i_pc(i_pc_),
    .i_prdt_taken(i_prdt_taken_),
    
    //regfile ralated
    .dec_rs1en(o_dec_rs1en),
    .dec_rs2en(o_dec_rs2en),
    .dec_rdwen(o_dec_rdwen),
    .dec_rs1idx(o_dec_rs1idx),
    .dec_rs2idx(o_dec_rs2idx),
    .dec_rdidx(o_dec_rdidx),
    .dec_info(o_dec_info),
    .dec_imm(o_dec_imm),
    .dec_pc(o_dec_pc),
    .dec_illegal(o_dec_illegal),
    
    //bjp instructions related
    .dec_bjp(o_dec_bjp),
    .dec_jal(o_dec_jal),
    .dec_jalr(o_dec_jalr),
    .dec_bxx(o_dec_bxx),

    .dec_jalr_rs1idx(o_dec_jalr_rs1idx),
    .dec_bjp_imm(o_dec_bjp_imm)
);

//test cases for each supported instruction
initial begin
    //=================================================
    `ifdef TEST_LUI
    #5 i_instr <= 32'b0000000_00000_00000_001_00001_011_0111;
    i_pc <= 32'd128;
    i_prdt_taken = 0;

    #5 i_instr <= 32'b1000000_00000_00000_001_01111_011_0111;
    i_pc <= 32'd128;
    i_prdt_taken = 0;
    `endif
    //=================================================
    `ifdef TEST_AUIPC
    #5 i_instr <= 32'b0000000_00000_00000_001_00001_001_0111;
    i_pc <= 32'd128;
    i_prdt_taken = 0;

    #5 i_instr <= 32'b1000000_00000_00000_001_11111_001_0111;
    i_pc <= 32'd256;
    i_prdt_taken = 0;
    `endif
    //=================================================
    `ifdef TEST_JAL
    #5 i_instr <= 32'b0000100_00011_00100_001_00001_110_1111;
    i_pc <= 32'd128;
    i_prdt_taken = 0;

    #5 i_instr <= 32'b1000000_00000_00000_001_11111_110_1111;
    i_pc <= 32'd256;
    i_prdt_taken = 0;
    `endif
    //=================================================
    `ifdef TEST_JALR
    #5 i_instr <= 32'b0000100_00011_00100_001_00001_110_0111;
    i_pc <= 32'd128;
    i_prdt_taken = 0;

    #5 i_instr <= 32'b1000000_00000_00000_001_11111_110_0111;
    i_pc <= 32'd256;
    i_prdt_taken = 0;
    `endif
    //=================================================
    `ifdef TEST_BEQ
    #5 i_instr <= 32'b0000100_00011_00100_000_00001_110_0011;
    i_pc <= 32'd128;
    i_prdt_taken = 0;

    #5 i_instr <= 32'b1000000_00000_00000_000_11111_110_0011;
    i_pc <= 32'd256;
    i_prdt_taken = 0;
    `endif
    //=================================================
    `ifdef TEST_BNE
    `endif
    //=================================================
    `ifdef TEST_BLT
    `endif
    //=================================================
    `ifdef TEST_BGE
    `endif
    //=================================================
    `ifdef TEST_BLTU
    `endif
    //=================================================
    `ifdef TEST_BGEU
    `endif
    //=================================================
    `ifdef TEST_LB
    `endif
    //=================================================
    `ifdef TEST_LH
    `endif
    //=================================================
    `ifdef TEST_LW
    `endif
    //=================================================
    `ifdef TEST_LBU
    `endif
    //=================================================
    `ifdef TEST_LHU
    `endif
    //=================================================
    `ifdef TEST_SB
    `endif
    //=================================================
    `ifdef TEST_SH
    `endif
    //=================================================
    `ifdef TEST_SW
    `endif
    //=================================================
    `ifdef TEST_ADDI
    `endif
    //=================================================
    `ifdef TEST_SLTI
    `endif
    //=================================================
    `ifdef TEST_SLTIU
    `endif
    //=================================================
    `ifdef TEST_XORI
    `endif
    //=================================================
    `ifdef TEST_ORI
    `endif
    //=================================================
    `ifdef TEST_ANDI
    `endif
    //=================================================
    `ifdef TEST_SLLI
    `endif
    //=================================================
    `ifdef TEST_SRLI
    `endif
    //=================================================
    `ifdef TEST_SRAI
    `endif
    //=================================================
    `ifdef TEST_ADD
    `endif
    //=================================================
    `ifdef TEST_SUB
    `endif
    //=================================================
    `ifdef TEST_SLL
    `endif
    //=================================================
    `ifdef TEST_SLT
    `endif
    //=================================================
    `ifdef TEST_SLTU
    `endif
    //=================================================
    `ifdef TEST_XOR
    `endif
    //=================================================
    `ifdef TEST_SRL
    `endif
    //=================================================
    `ifdef TEST_SRA
    `endif
    //=================================================
    `ifdef TEST_OR
    `endif
    //=================================================
    `ifdef TEST_AND
    `endif
    //=================================================
    `ifdef TEST_MUL
    `endif
    //=================================================
    `ifdef TEST_MULH
    `endif
    //=================================================
    `ifdef TEST_MULHSU
    `endif
    //=================================================
    `ifdef TEST_MULHU
    `endif
    //=================================================
    `ifdef TEST_DIV
    `endif
    //=================================================
    `ifdef TEST_DIVU
    `endif
    //=================================================
    `ifdef TEST_REM
    `endif
    //=================================================
    `ifdef TEST_REMU
    `endif
    //=================================================
    `ifdef TEST_NOP
    `endif

    #100 $finish;
end

endmodule