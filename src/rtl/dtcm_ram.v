//=================================================
//Description: dtcm ram
//Author : Hurui
//Modules: dtcm_ram
//=================================================
`include "defines.v"

module dtcm_ram (
    input clk,
    input we,
    input [`DTCM_RAM_AW-1:0] addr,
    input [`DTCM_RAM_DW-1:0] din,
    input [`DTCM_RAM_MW-1:0] wem,
    output [`DTCM_RAM_DW-1:0] dout
);
    sim_ram#(
    .DP(`DTCM_RAM_DP),
    .DW(`DTCM_RAM_DW),
    .MW(`DTCM_RAM_MW),
    .AW(`DTCM_RAM_AW),
    .FORCE_X2ZERO(1),
    .ITCM(0),
    .DTCM(1)
    ) u_dtcm_gnrl_ram(
    .clk(clk),
    .din(din),
    .addr(addr),
    .we(we),
    .wem(wem),
    .dout(dout)
);
endmodule