//=================================================
//Description: srams containing ITCM and DTCM
//Author : Hurui
//Modules: srams
//=================================================
`include "defines.v"

module srams (
    //ITCM ram
    input itcm_ram_we,
    input [`ITCM_RAM_AW-1:0] itcm_ram_addr,
    input [`ITCM_RAM_DW-1:0] itcm_ram_din,
    input [`ITCM_RAM_MW-1:0] itcm_ram_wem,
    output [`ITCM_RAM_DW-1:0] itcm_ram_dout,
    //DTCM ram
    input dtcm_ram_we,
    input [`ITCM_RAM_AW-1:0] dtcm_ram_addr,
    input [`ITCM_RAM_DW-1:0] dtcm_ram_din,
    input [`ITCM_RAM_MW-1:0] dtcm_ram_wem,
    output [`ITCM_RAM_DW-1:0] dtcm_ram_dout,
    input clk
);

itcm_ram u_itcm_ram (
        .clk(clk),
        .we(itcm_ram_we),
        .addr(itcm_ram_addr),
        .din(itcm_ram_din),
        .wem(itcm_ram_wem),
        .dout(itcm_ram_dout)
        );

dtcm_ram u_dtcm_ram (
        .clk(clk),
        .we(dtcm_ram_we),
        .addr(dtcm_ram_addr),
        .din(dtcm_ram_din),
        .wem(dtcm_ram_wem),
        .dout(dtcm_ram_dout)
        );
endmodule