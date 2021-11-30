//=================================================
//Description: cpu top
//Author : Hurui
//Modules: cpu + sram for sim
//=================================================
`include "defines.v"

module cpu_top (
    input[`PC_SIZE-1:0] pc_rtvec,//initial value of pc
    output [`ITCM_RAM_AW-1:0] itcm_ram_addr,
    output [`DTCM_RAM_AW-1:0] dtcm_ram_addr,
    input clk,
    input rst_n
);

//wire [`ITCM_RAM_AW-1:0] itcm_ram_addr;
wire [`ITCM_RAM_DW-1:0] itcm_ram_dout;
//wire[`DTCM_RAM_AW-1:0] dtcm_ram_addr;
wire dtcm_ram_we;
wire [`DTCM_RAM_DW-1:0] dtcm_ram_din;
wire [`DTCM_RAM_MW-1:0] dtcm_ram_wem;
wire [`DTCM_RAM_DW-1:0] dtcm_ram_dout;
//instantiate cpu
cpu u_cpu (
    .pc_rtvec(pc_rtvec),
    .itcm_ram_addr(itcm_ram_addr),
    .itcm_ram_dout(itcm_ram_dout),
    .dtcm_ram_we(dtcm_ram_we),
    .dtcm_ram_addr(dtcm_ram_addr),
    .dtcm_ram_din(dtcm_ram_din),
    .dtcm_ram_wem(dtcm_ram_wem),
    .dtcm_ram_dout(dtcm_ram_dout),
    .clk(clk),
    .rst_n(rst_n)
);

//instantiate sram
srams u_srams (
    .itcm_ram_addr(itcm_ram_addr),
    .itcm_ram_dout(itcm_ram_dout),
    .dtcm_ram_we(dtcm_ram_we),
    .dtcm_ram_addr(dtcm_ram_addr),
    .dtcm_ram_din(dtcm_ram_din),
    .dtcm_ram_wem(dtcm_ram_wem),
    .dtcm_ram_dout(dtcm_ram_dout),
    .clk(clk)
);
endmodule
