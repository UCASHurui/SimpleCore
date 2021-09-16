// =====================================
//Testbench for Simulation model of SRAM
//Author:     HuRui
//Modules:    tb_sim_ram
//=====================================

module tb_sim_ram;
parameter DW = 32;
parameter DP = 64;
parameter AW = 32;
parameter MW = 4;
parameter FORCE_X2ZERO = 1;

reg clk;
reg[DW-1:0] din;
reg [AW-1:0]addr;
reg we;
reg [MW-1:0] wem;

sim_ram#(
    .DP(DP),
    .DW(DW),
    .MW(MW),
    .AW(AW),
    .FORCE_X2ZERO(FORCE_X2ZERO)
) u_sim_ram(
    .clk(clk),
    .din(din),
    .addr(addr),
    .we(we),
    .wem(wem)
);

initial begin
    clk = 1;
    din = {DW{1'b1}};
    addr = 0;
    we = 1;
    wem = {MW{1'b1}};

    // write to 2 different address and read out;
    #5 we = 1;
    wem = 4'b1111;
    #5 din={DW{1'b1}};
    addr = 4;
    wem = 4'b1010;
    #5 we = 0;
    addr=0;
    #5 addr=4;
end

initial begin
    forever begin
        #1 clk = ~clk;
    end
end

endmodule