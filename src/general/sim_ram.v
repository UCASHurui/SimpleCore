// =====================================
//Simulation model of SRAM
//Author:     HuRui
//Modules:    sim_ram
//assume legal address
//=====================================

module sim_ram#(
    parameter DP = 512,//depth
    parameter DW = 32,//data width
    parameter MW= 4,//mask width
    parameter AW = 32,//address width
    parameter FORCE_X2ZERO = 0,
    parameter ITCM = 0,//instantiate as ITCM RAM
    parameter DTCM = 0 //instantiate as DTCM RAM
) (
    input  clk,
    input[DW-1:0] din,
    input[AW-1:0] addr,
    input we,
    input[MW-1:0] wem,//write enable mask
    output[DW-1:0] dout,
);
    reg [DW-1:0] mem_r[0:DP-1];
    reg [AW-1:0] addr_r;
    wire [MW-1:0] wen;
    wire ren;

    assign ren = ~we;
    assign wen = ({MW{we}} & wem);

    //the output will holdup
    always @(posedge clk ) begin
        if(ren) begin
            addr_r <= addr;
        end
    end
    
    wire[DW-1:0] dout_pre;
    assign dout_pre = mem_r[addr];
    assign dout = dout_pre;
    
   
    initial begin
        if (ITCM==1) begin
            mem_r[0] = 32'b0000000_00000_00000_001_00001_011_0111;//lui
            mem_r[1] = 32'b0000000_00000_00000_001_00001_011_0110;//lui
            mem_r[2] = 32'b0000000_00000_00000_001_00001_011_0101;//lui
            mem_r[3] = 32'b0000000_00000_00000_001_00001_011_0100;//lui
        end
    end
endmodule
