`define PC_SIZE 32                                                      //PC width
`define XLEN 32                                                         //regfile reg width  
`define RFIDX_WIDTH 5                                                   //regfile addr width
`define INSTR_SIZE 32                                                   //instruction size

//Decode info bus macros
`define DECINFO_GRP_WIDTH 2 //4 group in total(ALU, BJP, MULDIV, AGU)
`define DECINFO_GRP_ALU `DECINFO_GRP_WIDTH'd0
`define DECINFO_GRP_BJP `DECINFO_GRP_WIDTH'd1
`define DECINFO_GRP_MULDIV `DECINFO_GRP_WIDTH'd2
`define DECINFO_GRP_AGU `DECINFO_GRP_WIDTH'd3

`define DECINFO_GRP_LSB 0//low bit of GRP segment 0
`define DECINFO_GRP_MSB `DECINFO_GRP_LSB+`DECINFO_GRP_WIDTH - 1         //high bit og GRP segment 1
`define DECINFO_GRP `DECINFO_GRP_MSB:`DECINFO_GRP_LSB 

`define DECINFO_BJP_JUMP `DECINFO_GRP_MSB+1                             //2
`define DECINFO_BJP_BPRDT `DECINFO_BJP_JUMP+1                           //3
`define DECINFO_BJP_BEQ `DECINFO_BJP_BPRDT+1                            //4
`define DECINFO_BJP_BNE `DECINFO_BJP_BEQ+1                              //5
`define DECINFO_BJP_BLT `DECINFO_BJP_BNE+1                              //6
`define DECINFO_BJP_BGT `DECINFO_BJP_BLT+1                              //7
`define DECINFO_BJP_BLTU `DECINFO_BJP_BGT+1                             //8
`define DECINFO_BJP_BGTU `DECINFO_BJP_BLTU+1                            //9
`define DECINFO_BJP_BXX `DECINFO_BJP_BGTU+1                             //10
`define DECINFO_BJP_WIDTH `DECINFO_BJP_BXX+1                            //11 bits

`define DECINFO_ALU_ADD `DECINFO_GRP_MSB+1                              //2 
`define DECINFO_ALU_SUB `DECINFO_ALU_ADD+1                              //3
`define DECINFO_ALU_SLT `DECINFO_ALU_SUB+1                              //4
`define DECINFO_ALU_SLTU `DECINFO_ALU_SLT+1                             //5
`define DECINFO_ALU_XOR `DECINFO_ALU_SLTU+1                             //6
`define DECINFO_ALU_OR `DECINFO_ALU_XOR+1                               //7
`define DECINFO_ALU_AND `DECINFO_ALU_OR+1                               //8
`define DECINFO_ALU_SLL`DECINFO_ALU_AND+1                               //9
`define DECINFO_ALU_SRL `DECINFO_ALU_SLL+1                              //10
`define DECINFO_ALU_SRA `DECINFO_ALU_SRL+1                              //11
`define DECINFO_ALU_LUI `DECINFO_ALU_SRA+1                              //12
`define DECINFO_ALU_OP2IMM `DECINFO_ALU_LUI+1                           //13
`define DECINFO_ALU_OP1PC `DECINFO_ALU_OP2IMM+1                         //14
`define DECINFO_ALU_NOP `DECINFO_ALU_OP1PC+1                            //15
`define DECINFO_ALU_WIDTH `DECINFO_ALU_NOP+1                            //16 bits


`define DECINFO_MULDIV_MUL `DECINFO_GRP_MSB+1                           //2
`define DECINFO_MULDIV_MULH `DECINFO_MULDIV_MUL+1                       //3
`define DECINFO_MULDIV_MULHSU `DECINFO_MULDIV_MULH+1                    //4
`define DECINFO_MULDIV_MULHU `DECINFO_MULDIV_MULHSU+1                   //5
`define DECINFO_MULDIV_DIV `DECINFO_MULDIV_MULHU+1                      //6
`define DECINFO_MULDIV_DIVU `DECINFO_MULDIV_DIV+1                       //7
`define DECINFO_MULDIV_REM `DECINFO_MULDIV_DIVU+1                       //8
`define DECINFO_MULDIV_REMU `DECINFO_MULDIV_REM+1                       //9
`define DECINFO_MULDIV_WIDTH `DECINFO_MULDIV_REMU+1                     //10

`define DECINFO_AGU_LOAD `DECINFO_GRP_MSB+1                             //2
`define DECINFO_AGU_STORE `DECINFO_AGU_LOAD+1                           //3
`define DECINFO_AGU_SIZE_LSB `DECINFO_AGU_STORE+1                       //4
`define DECINFO_AGU_SIZE_MSB `DECINFO_AGU_STORE+2                       //5
`define DECINFO_AGU_SIZE `DECINFO_AGU_SIZE_MSB:`DECINFO_AGU_SIZE_LSB    //4~5
`define DECINFO_AGU_USIGN `DECINFO_AGU_SIZE_MSB+1                       //6
`define DECINFO_AGU_OP2IMM `DECINFO_AGU_USIGN+1                         //7
`define DECINFO_AGU_WIDTH `DECINFO_AGU_OP2IMM+1                         //total 8-bits

`define DECINFO_WIDTH `DECINFO_ALU_WIDTH                                //since ALU info bus is the longest
`define ALU_ADDER_WIDTH `XLEN+1                                         //33-bits


