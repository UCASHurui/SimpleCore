`timescale 1ns/1ps

`include "../rtl/defines.v"



module tb_cpu_top;
    reg clk;
    reg rst_n;
    reg[`PC_SIZE-1:0] pc_rtvec; 
    
    cpu_top u_cpu_top(
    .pc_rtvec(pc_rtvec),
    .clk(clk),
    .rst_n(rst_n)
    );
    
    initial begin
        rst_n = 0;
        pc_rtvec = {{`PC_SIZE-3{1'b0}},3'b000};
        #100 rst_n = 1;
        @(posedge clk)
        #10000 $finish;
    end 
    
    initial clk = 0;
    always #5 clk = ~clk;
   
endmodule

// module tb_cpu_top;
// wire[`PC_SIZE-1:0] inspect_pc;
// reg  [`PC_SIZE-1:0] pc_rtvec;

// // Fetch Interface to memory system (ITCM), internal protocol
// // Instruction Fetch Request channel
// wire ifu_req_valid;
// reg  ifu_req_ready;
// wire[`PC_SIZE-1:0] ifu_req_pc;            // Fetch PC

// // Insrtuction Fetch Response channel
// reg  ifu_rsp_valid;                         // Response valid 
// wire ifu_rsp_ready;                         // Response ready
// reg  [`INSTR_SIZE-1:0] ifu_rsp_instr;       // Response instruction
// // The Instruction Register stage to EXU interface
// wire [`INSTR_SIZE-1:0] ifu_o_ir;           // The instruction register
// wire [`PC_SIZE-1:0] ifu_o_pc;
// wire [`RFIDX_WIDTH-1:0] ifu_o_rs1idx;
// wire [`RFIDX_WIDTH-1:0] ifu_o_rs2idx;
// wire ifu_o_prdt_taken;                      // The Bxx is predicted as taken
// wire ifu_o_valid;                           // Handshake signals with EXU stage
// reg  ifu_o_ready;

// wire  pipe_flush_ack;                        // pipeline flush acknowledge
// reg   pipe_flush_req;                        // pipeline flush request
// reg   [`PC_SIZE-1:0] pipe_flush_add_op1;  
// reg   [`PC_SIZE-1:0] pipe_flush_add_op2;
// reg  oitf_empty;
// reg  [`XLEN-1:0] rf2ifu_x1;
// reg  [`XLEN-1:0] rf2ifu_rs1;
// reg dec2ifu_rs1en;
// reg  dec2ifu_rden;
// reg  [`RFIDX_WIDTH-1:0] dec2ifu_rdidx;

// reg  clk;
// reg  rst_n;

// ifu_ifetch u_ifu_ifetch(
// .inspect_pc(inspect_pc),
// .pc_rtvec(pc_rtvec),
// .ifu_req_valid(ifu_req_valid), 
// .ifu_req_ready(ifu_req_ready),
// .ifu_req_pc(ifu_req_pc),            
// .ifu_rsp_valid(ifu_rsp_valid),                         // Response valid 
// .ifu_rsp_ready(ifu_rsp_ready),                         // Response ready
// .ifu_rsp_instr(ifu_rsp_instr),       // Response instruction
 
// .ifu_o_ir(ifu_o_ir),            // The instruction register
// .ifu_o_pc(ifu_o_pc),
// .ifu_o_rs1idx(ifu_o_rs1idx),
// .ifu_o_rs2idx(ifu_o_rs2idx),
// .ifu_o_prdt_taken(ifu_o_prdt_taken),                       // The Bxx is predicted as taken
// .ifu_o_valid(ifu_o_valid),                            // Handshake signals with EXU stage
// .ifu_o_ready(ifu_o_ready),

// .pipe_flush_ack(pipe_flush_ack),                        // pipeline flush acknowledge
// .pipe_flush_req(pipe_flush_req),                        // pipeline flush request
// .pipe_flush_add_op1(pipe_flush_add_op1),  
// .pipe_flush_add_op2(pipe_flush_add_op2),
// .oitf_empty(oitf_empty),
// .rf2ifu_x1(rf2ifu_x1),
// .rf2ifu_rs1(rf2ifu_rs1),
//  .dec2ifu_rs1en(dec2ifu_rs1en),
//  .dec2ifu_rden(dec2ifu_rden),
// .dec2ifu_rdidx(dec2ifu_rdidx),

//  .clk(clk),
// .rst_n(rst_n)
//     );
    
//     initial begin
//         rst_n = 0;
//         #30 rst_n = 1;
//         @(posedge clk)
//         pc_rtvec = {{`PC_SIZE-3{1'b0}},3'b001};
//         #50
//         @(posedge clk)
//         ifu_req_ready = 1;
//         ifu_rsp_instr = 32'b0000000_00000_00000_001_00001_011_0111;
//         ifu_o_ready = 1;
//         pipe_flush_req = 0;
//         pipe_flush_add_op1 = `PC_SIZE'b0;
//         pipe_flush_add_op2 = `PC_SIZE'b0;
//         oitf_empty = 1;
//         rf2ifu_rs1=`XLEN'b1;
//         rf2ifu_x1=`XLEN'b1;
//         dec2ifu_rs1en = 1;
//         dec2ifu_rden=1;
        
//         #1000 $finish;
//     end 
    
//     initial  clk = 0;     
//     always  #5 clk = ~clk;
// endmodule