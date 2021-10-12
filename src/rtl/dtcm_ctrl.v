//=================================================
//Description: dtcm ctrl module
//Author : Hurui
//Modules: dtcm_ctrl
//=================================================
`include "defines.v"

module dtcm_ctrl (
    //output dtcm_active,
    //ifu to dtcm ram interface
    input lsu2dtcm_cmd_valid,
    output lsu2dtcm_cmd_ready,
    input lsu2dtcm_cmd_read,
    input [`DTCM_ADDR_WIDTH-1:0] lsu2dtcm_cmd_addr,
    input [`DTCM_RAM_MW-1:0] lsu2dtcm_cmd_wmask,
    input [`DTCM_RAM_DW-1:0] lsu2dtcm_cmd_wdata,
    

    output lsu2dtcm_rsp_valid,
    input lsu2dtcm_rsp_ready,
    output [`DTCM_RAM_DW-1:0] lsu2dtcm_rsp_rdata,

    //to dtcm ram
    output dtcm_ram_we,
    output [`DTCM_RAM_AW-1:0] dtcm_ram_addr,
    output [`DTCM_RAM_MW-1:0] dtcm_ram_wem,
    output [`DTCM_RAM_DW-1:0] dtcm_ram_din,
    input [`DTCM_RAM_DW-1:0] dtcm_ram_dout
);
    //generate handshake signals with lsu for simulation purpose
    assign lsu2dtcm_cmd_ready = 1;//only lsu can access dtcm, so dtcm is always ready for lsu
    assign lsu2dtcm_rsp_valid = lsu2dtcm_cmd_valid;//dtcm rsp data come out in the same cycle, so always valid when there is cmd from lsu
    assign lsu2dtcm_rsp_rdata = dtcm_ram_dout;
    assign dtcm_ram_we = ~lsu2dtcm_cmd_read;
    assign dtcm_ram_addr = lsu2dtcm_cmd_addr[`DTCM_ADDR_WIDTH-1:2];
    assign dtcm_ram_wem = lsu2dtcm_cmd_wmask;
    assign dtcm_ram_din = lsu2dtcm_cmd_wdata;
endmodule