//=================================================
//Description: cpu module 
//Author : Hurui
//Modules: core + itcm_ctrl + dtcm_ctrl
//=================================================
`include "defines.v"

module cpu (
    input [`PC_SIZE-1:0] pc_rtvec,
    //SRAM interface
    //ITCM SRAM
    output [`ITCM_RAM_AW-1:0] itcm_ram_addr,
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
wire [`ITCM_ADDR_WIDTH-1:0] ifu2itcm_cmd_addr;
wire ifu2itcm_rsp_valid;
wire ifu2itcm_rsp_ready;
wire [`ITCM_RAM_DW-1:0] ifu2itcm_rsp_rdata;

wire lsu2dtcm_cmd_valid;
wire lsu2dtcm_cmd_ready;
wire lsu2dtcm_cmd_read;
wire [`DTCM_ADDR_WIDTH-1:0] lsu2dtcm_cmd_addr;
wire [`DTCM_RAM_DW-1:0] lsu2dtcm_cmd_wdata;
wire [`DTCM_RAM_MW-1:0] lsu2dtcm_cmd_wmask;
wire lsu2dtcm_rsp_valid;
wire lsu2dtcm_rsp_ready;
wire [`DTCM_RAM_DW-1:0] lsu2dtcm_rsp_rdata;
//instantiate core
core u_core (
    .pc_rtvec(pc_rtvec),
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
    .ifu2itcm_cmd_valid(ifu2itcm_cmd_valid),
    .ifu2itcm_cmd_ready(ifu2itcm_cmd_ready),
    .ifu2itcm_cmd_addr(ifu2itcm_cmd_addr),
    .ifu2itcm_rsp_valid(ifu2itcm_rsp_valid),
    .ifu2itcm_rsp_ready(ifu2itcm_rsp_ready),
    .ifu2itcm_rsp_rdata(ifu2itcm_rsp_rdata),
    .itcm_ram_addr(itcm_ram_addr),
    .itcm_ram_dout(itcm_ram_dout),
    .clk(clk),
    .rst_n(rst_n)
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
    .dtcm_ram_dout(dtcm_ram_dout),
    .clk(clk),
    .rst_n(rst_n)
);
endmodule
