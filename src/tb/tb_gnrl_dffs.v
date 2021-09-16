/*
Author:Hurui
Testbench for general dffs
*/

module tb_gnrl_dffs #(
    parameter DW = 32
);
    reg clk;
    reg rst_n;
    reg[DW-1:0] Q;
    reg load_enable;
    wire[DW-1:0] qout_gnrl_dfflrs;
    wire[DW-1:0] qout_gnrl_dfflr;
    wire[DW-1:0] qout_gnrl_dffl;
    wire[DW-1:0] qout_gnrl_dffrs;
    wire[DW-1:0] qout_gnrl_dffr;
    
    gnrl_dfflrs#(.DW(32))u_gnrl_dfflrs(
        .lden(load_enable),
        .dnxt(Q),
        .qout(qout_gnrl_dfflrs),
        .clk(clk),
        .rst_n(rst_n)
    );

    gnrl_dfflr#(.DW(32))u_gnrl_dfflr(
        .lden(load_enable),
        .dnxt(Q),
        .qout(qout_gnrl_dfflr),
        .clk(clk),
        .rst_n(rst_n)
    );

    gnrl_dffl #(.DW(32))u_gnrl_dffl(
        .lden(load_enable),
        .dnxt(Q),
        .qout(qout_gnrl_dffl),
        .clk(clk)
    );

    gnrl_dffrs#(.DW(32))u_gnrl_dffrs(
        .dnxt(Q),
        .qout(qout_gnrl_dffrs),
        .clk(clk),
        .rst_n(rst_n)
    );

    gnrl_dffr#(.DW(32))u_gnrl_dffr(
        .dnxt(Q),
        .qout(qout_gnrl_dffr),
        .clk(clk),
        .rst_n(rst_n)
    );
    
    initial begin
        load_enable = 0;
	    Q = 0;
	    rst_n = 1;
        #5 rst_n = 0;
	    #6 rst_n = 1;
        #5 load_enable = 1;
        #100 $finish;
    end

    always @(posedge clk ) begin
        Q <= Q +1;
    end

    initial begin
        clk = 1;
        forever begin
            #5 clk = ~clk;
        end
    end

endmodule