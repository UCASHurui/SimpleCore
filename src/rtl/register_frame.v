module register (inputs,outputs );
    //input reg [31:0] reg1;
    //input reg [31:0] reg2;
    input wire [31:0] readReg1;
    input wire [31:0] readReg2;
    input //type name  // wire [] 
    input //type name // wire [] 
    input wire RegWrite; 

    output read_data_1;
    output read_data_2;
   


always @(posedge RegWrite)
    begin
        // operates outputs
    end    

endmodule
