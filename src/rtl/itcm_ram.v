//=================================================
//Description: itcm ram
//Author : Hurui
//Modules: itcm_ram
//=================================================
`include "defines.v"

module itcm_ram (
    input clk,
    input we,
    input [`ITCM_RAM_AW-1:0] addr,
    input [`ITCM_RAM_DW-1:0] din,
    input [`ITCM_RAM_MW-1:0] wem,
    output [`ITCM_RAM_DW-1:0] dout
);
    sim_ram#(
    .DP(`ITCM_RAM_DP),
    .DW(`ITCM_RAM_DW),
    .MW(`ITCM_RAM_MW),
    .AW(`ITCM_RAM_AW),
    .FORCE_X2ZERO(1)
    ) u_itcm_gnrl_ram(
    .clk(clk),
    .din(din),
    .addr(addr),
    .we(we),
    .wem(wem),
    .dout(dout)
);
endmodule