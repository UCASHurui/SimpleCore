//=================================================
//Description: itcm ctrl module
//Author : Hurui
//Modules: itcm_ctrl
//=================================================
`include "defines.v"

module itcm_ctrl (
    //output itcm_active,
    //ifu to itcm ram interface
    input ifu2itcm_cmd_valid,
    output ifu2itcm_cmd_ready,
    input ifu2itcm_cmd_read,
    input [`ITCM_RAM_AW-1:0] ifu2itcm_cmd_addr,
    input [`ITCM_RAM_MW-1:0] ifu2itcm_cmd_wmask,
    input [`ITCM_RAM_DW-1:0] ifu2itcm_cmd_wdata,
    

    output ifu2itcm_rsp_valid,
    input ifu2itcm_rsp_ready,
    output [`ITCM_RAM_DW-1:0] ifu2itcm_rsp_rdata,

    //to itcm ram
    output itcm_ram_we,
    output [`ITCM_RAM_AW-1:0] itcm_ram_addr,
    output [`ITCM_RAM_MW-1:0] itcm_ram_wem,
    output [`ITCM_RAM_DW-1:0] itcm_ram_din,
    input [`ITCM_RAM_DW-1:0] itcm_ram_dout
    //output ifu2itcm_holdup,
);
    //generate handshake signals with ifu for simulation purpose
    assign ifu2itcm_cmd_ready = 1;//only ifu can access itcm, so itcm is always ready for ifu
    assign ifu2itcm_rsp_valid = ifu2itcm_cmd_valid;//valid when there is cmd from ifu
    assign itcm_ram_dout = itcm_ram_din;
    assign itcm_ram_we = ~ifu2itcm_cmd_read;
    assign itcm_ram_addr = ifu2itcm_cmd_addr;
    assign itcm_ram_wem = ifu2itcm_cmd_wmask;
    assign itcm_ram_din = ifu2itcm_cmd_wdata;
endmodule