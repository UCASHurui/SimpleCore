//=================================================
//Description: load store unit 
//Author : Hurui
//Modules: lsu
//=================================================
`include "defines.v"

module lsu (
    output lsu_active,
    input [`ADDR_SIZE-1:0] itcm_region_indic,
    input [`ADDR_SIZE-1:0] dtcm_region_indic,
    //LSU write back interface
    output lsu_o_valid,
    input lsu_o_ready,
    output [`XLEN-1:0] lsu_o_wbck_data,
    output [`ITAG_WDITH-1:0] lsu_o_wbck_itag,
    //the AGU  to LSU-ctrl interface


    //interface to DTCM
    
);
    
endmodule