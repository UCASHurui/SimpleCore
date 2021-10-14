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
    output[DW-1:0] dout
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
  
    genvar i;
    generate
        for(i = 0; i<MW; i = i + 1) begin
            if((8*i+8) > DW) begin
                always @(posedge clk) begin
                    if (wen[i]) begin
                        mem_r[addr][DW-1:8*i] <= din[DW-1:8*i];
                    end
                end
            end
            else begin
                always @(posedge clk) begin
                    if (wen[i]) begin
                        mem_r[addr][8*i+7:8*i] <= din[8*i+7:8*i];
                    end
                end
            end
        end
    endgenerate
    
    assign dout = mem_r[addr_r];
    /*
      generate
       if(FORCE_X2ZERO == 1) begin: force_x_to_zero
          for (i = 0; i < DW; i = i+1) begin:force_x_gen 
              `ifndef SYNTHESIS//{
             assign dout[i] = (dout_pre[i] === 1'bx) ? 1'b0 : dout_pre[i];
              `else//}{
             assign dout[i] = dout_pre[i];
              `endif//}
          end
       end
       else begin:no_force_x_to_zero
         assign dout = dout_pre;
       end
      endgenerate
    */
    
   /*
    initial begin
        if (ITCM==1) begin
            mem_r[1] = 32'b0000000_00000_00000_001_00001_011_0111;//lui x1, 32'h0000_1000
            mem_r[2] = 32'b0000000_00000_00000_010_00010_011_0110;//lui x2, 32'h0000_2000
            mem_r[3] = 32'b0000100_00011_00100_000_00001_001_0011;//addi x1, 32'h0000_0083
            mem_r[4] = 32'b0000000_00001_00100_000_00010_001_0011;//addi x2, 32'h0000_0001
                        mem_r[0] = 32'b0000000_00000_00000_001_00001_011_0111;//LUI
            mem_r[1] = 32'b0000000_00000_00000_001_11111_001_0111;//AUIPC
            mem_r[2] = 32'b0000100_00011_00100_001_00001_110_1111;//JAL
            mem_r[3] = 32'b0000000_00000_00000_001_11111_001_0111;//JALR
            
            mem_r[4] = 32'b0000100_00011_00100_000_00001_110_0011;//BEQ
            mem_r[5] = 32'b0000100_00011_00100_001_00001_110_0011;//BNE
            mem_r[6] = 32'b0000100_00011_00100_100_00001_110_0011;//BLT
            mem_r[7] = 32'b0000100_00011_00100_101_00001_110_0011;//BGE
            mem_r[8] = 32'b0000100_00011_00100_110_00001_110_0011;//BLTU
            mem_r[9] = 32'b0000100_00011_00100_111_00001_110_0011;//BGEU
            mem_r[10] = 32'b0000100_00011_00100_000_00001_000_0011;//LB
            mem_r[11] = 32'b0000100_00011_00100_001_00001_000_0011;//LH
            mem_r[12] = 32'b0000100_00011_00100_010_00001_000_0011;//LW
            mem_r[13] = 32'b0000100_00011_00100_100_00001_000_0011;//LBU
            mem_r[14] = 32'b0000100_00011_00100_101_00001_000_0011;//LHU
            mem_r[15] = 32'b0000100_00011_00100_000_00001_010_0011;//SB
            mem_r[16] = 32'b0000100_00011_00100_001_00001_010_0011;//SH
            mem_r[17] = 32'b0000100_00011_00100_010_00001_010_0011;//SW
            mem_r[18] = 32'b0000100_00011_00100_000_00001_001_0011;//ADDI
            mem_r[19] = 32'b0000100_00011_00100_010_00001_001_0011;//SLTI
            mem_r[20] = 32'b0000100_00011_00100_011_00001_001_0011;//SLTIU
            mem_r[21] = 32'b0000100_00011_00100_100_00001_001_0011;//XORI
            mem_r[22] = 32'b0000100_00011_00100_110_00001_001_0011;//ORI
            mem_r[23] = 32'b0000100_00011_00100_111_00001_001_0011;//ANDI
            mem_r[24] = 32'b0000000_00011_00100_001_00001_001_0011;//SLLI
            mem_r[25] = 32'b0000000_00011_00100_101_00001_001_0011;//SRLI
            mem_r[26] = 32'b0100000_00011_00100_101_00001_001_0011;//SRAI
        end
    end
    */
    initial begin
        if (ITCM==1) begin
            mem_r[1] = 32'b0000000_00000_00000_000_00001_011_0111;//lui x1, 32'h0000_0000
            mem_r[2] = 32'b0000000_00000_00001_000_00001_000_0011;//LB
            mem_r[3] = 32'b0000100_00011_00001_000_00001_001_0011;//addi x1, 32'h0000_0083
            mem_r[4] = 32'b0000100_00011_00001_000_00001_001_0011;//addi x1, 32'h0000_0083
        end
    end
    
    initial begin
        if (DTCM==1) begin 
            mem_r[0] = 32'd0;//0x0000
            mem_r[1] = 32'd1;//0x0001
            mem_r[2] = 32'b00000000_00000000_00000001_00000001;//0x0011
            mem_r[3] = 32'b00000001_00000001_00000001_00000001;//0x1111
        end
    end
endmodule
