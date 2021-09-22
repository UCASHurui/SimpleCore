`define idle	1'b0
`define exec	1'b1

// define by operation code
`define U_instru_op	  7'b011_0111
`define J_jal_op      7'b110_1111
`define I_jalr_op     7'b110_0111
`define B_instru_op	  7'b110_0011
`define I_instru_op	  7'b000_0011
`define S_instru_op	  7'b010_0011
`define R_instru_op	  7'b011_0011
`define I_series_op	  7'b001_0011

/*
// each 3 bits function code

/ ***** I_jalr_op *****
`define J_jal_funct     3'b000

/ ***** B_instru_op *****
`define B_beq_funct     3'b000
`define B_bne_funct     3'b001
`define B_blt_funct     3'b100
`define B_bge_funct     3'b101
`define B_bltu_funct    3'b110
`define B_bgeu_funct    3'b111

/ ***** I_instru_op *****
`define I_lb_funct      3'b000
`define I_lh_funct      3'b001
`define I_lw_funct      3'b110
`define I_lbu_funct     3'b100
`define I_lhu_funct     3'b101


/*