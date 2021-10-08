/*
Description:
All of the general D flip-flops
Author: Hu Rui
Modules:     gnrl_dfflrs 
                    gnrl_dfflr 
                    gnrl_dffl 
                    gnrl_dffrs 
                    gnrl_dffr
*/

//////////////////////////////////////////////////
//gnrl_dfflr: D flip-flop with reset(1) and load_enable
//////////////////////////////////////////////////
module gnrl_dfflrs #(
    parameter DW = 32 
) (
    input lden,
    input [DW-1:0] dnxt,
    output [DW-1:0] qout,

    input clk,
    input rst_n
);

reg [DW-1: 0] qout_r;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        qout_r <= {DW{1'b1}};
    end
    else if (lden == 1'b1) begin
        // original: qout_r <= #1 dnxt;
        qout_r  <= dnxt;
    end
end

assign qout = qout_r;
endmodule

//////////////////////////////////////////////////
//gnrl_dfflr: D flip-flop with reset(0) and load_enable
//////////////////////////////////////////////////
module gnrl_dfflr #(
    parameter DW = 32 
) (
    input lden,
    input [DW-1:0] dnxt,
    output [DW-1:0] qout,

    input clk,
    input rst_n
);

reg [DW-1: 0] qout_r;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        //reset ÖÃ1
        qout_r <= {DW{1'b0}};
    end
    else if (lden == 1'b1) begin
        // original: qout_r <= #1 dnxt;
        qout_r  <= dnxt;
    end
end

assign qout = qout_r;
endmodule

//////////////////////////////////////////////////
//gnrl_dffrs: D flip-flop with load_enable
//without reset
//////////////////////////////////////////////////
module gnrl_dffl #(
    parameter DW = 32 
) (
    input lden,
    input [DW-1:0] dnxt,
    output [DW-1:0] qout,

    input clk
);

reg [DW-1: 0] qout_r;

always @(posedge clk) begin
    if (lden == 1'b1) begin
        // original: qout_r <= #1 dnxt;
        qout_r  <= dnxt;
    end
end

assign qout = qout_r;
endmodule

//////////////////////////////////////////////////
//gnrl_dffrs: D flip-flop with reset(1)
//without load_enable
//////////////////////////////////////////////////
module gnrl_dffrs #(
    parameter DW = 32 
) (
    input [DW-1:0] dnxt,
    output [DW-1:0] qout,

    input clk,
    input rst_n
);

reg [DW-1: 0] qout_r;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        //reset ÖÃ1
        qout_r <= {DW{1'b1}};
    end
    else begin
        // original: qout_r <= #1 dnxt;
        qout_r  <= dnxt;
    end
end

assign qout = qout_r;
endmodule

//////////////////////////////////////////////////
//gnrl_dffr: D flip-flop with reset(0)
//without load_enable
//////////////////////////////////////////////////
module gnrl_dffr #(
    parameter DW = 32 
) (
    input [DW-1:0] dnxt,
    output [DW-1:0] qout,

    input clk,
    input rst_n
);

reg [DW-1: 0] qout_r;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        //reset ÖÃ0
        qout_r <= {DW{1'b0}};
    end
    else begin
        // original: qout_r <= #1 dnxt;
        qout_r  <= dnxt;
    end
end

assign qout = qout_r;
endmodule



