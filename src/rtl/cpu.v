//=================================================
//Description: cpu module 
//Author : Hurui
//Modules: core + itcm_ctrl + dtcm_ctrl
//=================================================
`include "defines.v"

module cpu (
    output [`PC_SIZE-1:0] inspect_pc,
    input [`PC_SIZE-1:0] pc_rtvec,
    //SRAM interface
    //ITCM SRAM
    output itcm_ram_we,
    output [`ITCM_RAM_AW-1:0] itcm_ram_addr,
    output [`ITCM_RAM_DW-1:0] itcm_ram_din,
    output [`ITCM_RAM_MW-1:0] itcm_ram_wem,
    input [`ITCM_RAM_DW-1:0] itcm_ram_dout,
    //DTCM SRAM
    output dtcm_ram_we,
    output [`DTCM_RAM_AW-1:0] dtcm_ram_addr,
    output [`DTCM_RAM_DW-1:0] dtcm_ram_din,
    output [`DTCM_RAM_MW-1:0] dtcm_ram_wem,
    input [`DTCM_RAM_DW-1:0] dtcm_ram_dout,
    
    input clk,//for simulation purpose, from testbench
    input rst_n//for simulation purpose, from testbench
);
wire ifu2itcm_cmd_valid;
wire ifu2itcm_cmd_ready;
wire [`ITCM_RAM_AW-1:0] ifu2itcm_cmd_addr;
wire ifu2itcm_cmd_read = 1'b1;//ifu not allowed to write itcm
wire [`ITCM_RAM_DW-1:0] ifu2itcm_cmd_wdata = `ITCM_RAM_DW{1'b0}; //ifu not allowed to write itcm
wire [`ITCM_RAM_MW-1:0] ifu2itcm_cmd_wmask = `ITCM_RAM_MW{1'b0}; //ifu not allowed to write itcm
wire ifu2itcm_rsp_valid;
wire ifu2itcm_rsp_ready;
wire [`ITCM_RAM_DW-1:0] ifu2itcm_rsp_rdata;

//instantiate core
core u_core (
    .inspect_pc(inspect_pc),
    .pc_rtvec(pc_rtvec)
    .ifu2itcm_cmd_valid(ifu2itcm_cmd_valid),
    .ifu2itcm_cmd_ready(ifu2itcm_cmd_ready),
    .ifu2itcm_cmd_addr(ifu2itcm_cmd_addr),
    .ifu2itcm_rsp_valid(ifu2itcm_rsp_valid),
    .ifu2itcm_rsp_ready(ifu2itcm_rsp_ready),
    .ifu2itcm_rsp_rdata(ifu2itcm_rsp_rdata),
    .lsu2dtcm_cmd_valid(lsu2dtcm_cmd_valid),
    .lsu2dtcm_cmd_ready(lsu2dtcm_cmd_ready),
    .lsu2dtcm_cmd_read(lsu2dtcm_cmd_read),
    .lsu2dtcm_cmd_addr(lsu2dtcm_cmd_addr),
    .lsu2dtcm_cmd_wdata(lsu2dtcm_cmd_wdata),
    .lsu2dtcm_cmd_wmask(lsu2dtcm_cmd_wmask),
    .lsu2dtcm_rsp_valid(lsu2dtcm_rsp_valid),
    .lsu2dtcm_rsp_ready(lsu2dtcm_rsp_ready),
    .lsu2dtcm_rsp_rdata(lsu2dtcm_rsp_rdata),
    .clk(clk),
    .rst_n(rst_n)
);

//instantiate itcm_ctrl
itcm_ctrl u_itcm_ctrl (
    .itcm_active(),
    .ifu2itcm_cmd_valid(ifu2itcm_cmd_valid),
    .ifu2itcm_cmd_ready(ifu2itcm_cmd_ready),
    .ifu2itcm_cmd_read(ifu2itcm_cmd_read),
    .ifu2itcm_cmd_addr(ifu2itcm_cmd_addr),
    .ifu2itcm_cmd_wmask(ifu2itcm_cmd_wmask),
    .ifu2itcm_cmd_wdata(ifu2itcm_cmd_wdata),
    .ifu2itcm_rsp_valid(ifu2itcm_rsp_valid),
    .ifu2itcm_rsp_ready(ifu2itcm_rsp_ready),
    .ifu2itcm_rsp_rdata(ifu2itcm_rsp_rdata),
    .itcm_ram_we(itcm_ram_we),
    .itcm_ram_addr(itcm_ram_addr),
    .itcm_ram_wem(itcm_ram_wem),
    .itcm_ram_din(itcm_ram_din),
    .itcm_ram_dout(itcm_ram_dout)
);

//instantiate dtcm_ctrl
dtcm_ctrl u_dtcm_ctrl (
    .lsu2dtcm_cmd_valid(lsu2dtcm_cmd_valid),
    .lsu2dtcm_cmd_ready(lsu2dtcm_cmd_ready),
    .lsu2dtcm_cmd_read(lsu2dtcm_cmd_read),
    .lsu2dtcm_cmd_addr(lsu2dtcm_cmd_addr),
    .lsu2dtcm_cmd_wmask(lsu2dtcm_cmd_wmask),
    .lsu2dtcm_cmd_wdata(lsu2dtcm_cmd_wdata),
    .lsu2dtcm_rsp_valid(lsu2dtcm_rsp_valid),
    .lsu2dtcm_rsp_ready(lsu2dtcm_rsp_ready),
    .lsu2dtcm_rsp_rdata(lsu2dtcm_rsp_rdata),
    .dtcm_ram_we(dtcm_ram_we),
    .dtcm_ram_addr(dtcm_ram_addr),
    .dtcm_ram_wem(dtcm_ram_wem),
    .dtcm_ram_din(dtcm_ram_din),
    .dtcm_ram_dout(dtcm_ram_dout)
);
endmodule