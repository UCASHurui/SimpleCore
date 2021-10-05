//=================================================
//Description: cpu top
//Author : Hurui
//Modules: cpu + sram for sim
//=================================================
`include "defines.v"

module cpu_top (
    input pc_rtvec,//initial value of pc
    input clk,
    input rst_n
);

wire itcm_ram_we;
wire [`ITCM_RAM_AW-1:0] itcm_ram_addr;
wire [`ITCM_RAM_DW-1:0] itcm_ram_din;
wire itcm_ram_wem;
wire [`ITCM_RAM_DW-1:0] itcm_ram_dout;
wire dtcm_ram_we;
wire [`DTCM_RAM_AW-1:0] dtcm_ram_addr;
wire [`DTCM_RAM_DW-1:0] dtcm_ram_din;
wire dtcm_ram_wem;
wire [`DTCM_RAM_DW-1:0] dtcm_ram_dout;
//instantiate cpu
cpu u_cpu (
    .inspect_pc(),
    .pc_rtvec(pc_rtvec)
    .itcm_ram_we(itcm_ram_we),
    .itcm_ram_addr(itcm_ram_addr),
    .itcm_ram_din(itcm_ram_din),
    .itcm_ram_wem(itcm_ram_wem),
    .itcm_ram_dout(itcm_ram_dout),
    .dtcm_ram_we(dtcm_ram_we),
    .dtcm_ram_addr(dtcm_ram_addr),
    .dtcm_ram_din(dtcm_ram_din),
    .dtcm_ram_wem(dtcm_ram_wem),
    .dtcm_ram_dout(dtcm_ram_dout),
    .clk(clk),
    .purpose(purpose)
);

//instantiate sram
srams u_srams (
    .itcm_ram_we(itcm_ram_we),
    .itcm_ram_addr(itcm_ram_addr),
    .itcm_ram_din(itcm_ram_din),
    .itcm_ram_wem(itcm_ram_wem),
    .itcm_ram_dout(itcm_ram_dout),
    .dtcm_ram_we(dtcm_ram_we),
    .dtcm_ram_addr(dtcm_ram_addr),
    .dtcm_ram_din(dtcm_ram_din),
    .dtcm_ram_wem(dtcm_ram_wem),
    .dtcm_ram_dout(dtcm_ram_dout),
    .clk(clk)
);
endmodule