//=====================================================================
//
// Author: LI Jiarui
//
// Description:
//  The ift2icb module convert the fetch request to ITCM.
//  SimpleCore currently does not support ICache or Sys-MEM.
//
// ====================================================================
`include "defines.v"


module ifu_ifu2itcm(

  //input  itcm_nohold,
  
  // Fetch Interface to memory system, internal protocol
  //    * IFetch REQ channel
  input  ifu_req_valid, // Handshake valid
  output ifu_req_ready, // Handshake ready

  // Note: the req-addr can be unaligned with the length indicated by req_len signal.
  //  The targetd ITCM ctrl modules will handle the unalign cases and split-and-merge works
  input  [`PC_SIZE-1:0] ifu_req_pc, // Fetch PC

  input  ifu_req_seq, // This request is a sequential instruction fetch
  // input  ifu_req_seq_rv32, // This request is incremented 32bits fetch
  
  input  [`PC_SIZE-1:0] ifu_req_last_pc, // The last accessed PC address (i.e., pc_r)
                             
  //    * IFetch RSP channel
  output ifu_rsp_valid, // Response valid 
  input  ifu_rsp_ready, // Response ready
  output ifu_rsp_err,   // Response error
  // Note: the RSP channel always return a valid instruction fetched from the fetching start PC address.
  //   The targetd ITCM ctrl modules will handle the unalign cases and split-and-merge works
  
  //output ifu_rsp_replay,   // Response error
  output [32-1:0] ifu_rsp_instr, // Response instruction

 
  input [`ADDR_SIZE-1:0] itcm_region_indic,
  output ifu2itcm_cmd_valid, // Handshake valid
  input  ifu2itcm_cmd_ready, // Handshake ready
  output [`ITCM_ADDR_WIDTH-1:0]   ifu2itcm_addr, //transcation to itcm start address
  output [`ITCM_RAM_AW-1:0] itcm_ram_addr,
  
  input  ifu2itcm_rsp_valid, // Response valid 
  output ifu2itcm_rsp_ready, // Response ready
  input  ifu2itcm_rsp_err,   // Response error
            // Note: the RSP rdata is inline with AXI definition
  input  [`ITCM_DATA_WIDTH-1:0] ifu2itcm_rsp_rdata, 

  input  ifu2itcm_holdup,

  input  clk,
  input  rst_n
  );

// ===========================================================================
//                   The itfctrl scheme introduction
//
// The instruction fetch is very tricky due to two reasons and purposes:
//   (1) We want to save area and dynamic power as much as possible
//   (2) The 32bits-length instructon may be in unaligned address
//
// In order to acheive above-mentioned purposes we define the tricky
//   fetch scheme detailed as below.
//
// 
// Firstly, several phrases are introduced here:
//   * Fetching target: the target address region including ITCM,
//         System Memory Fetch Interface or ICache
//            (Note: Sys Mem and I-cache are Exclusive with each other)
//   * Fetching target's Lane: The Lane here means the fetching 
//       target can read out one lane of data at one time. 
//       For example: 
//        * ITCM is 64bits wide SRAM, then it can read out one 
//          aligned 64bits one time (as a lane)
//        * System Memory is 32bits wide bus, then it can read out one 
//          aligned 32bits one time (as a lane)
//        * ICache line is N-Bytes wide SRAM, then it can read out one 
//          aligned N-Bytes one time (as a lane)
//   * Lane holding-up: The read-out Lane could be holding up there
//       For examaple:
//        * ITCM is impelemented as SRAM, the output of SRAM (readout lane)
//          will keep holding up and not change until next time the SRAM
//          is accessed (CS asserted) by new transaction
//        * ICache data ram is impelemented as SRAM, the output of
//          SRAM (readout lane) will keep holding up and not change until
//          next time the SRAM is accessed (CS asserted) by new transaction
//        * The system memory bus is from outside core peripheral or memory
//          we dont know if it will hold-up. Hence, we assume it is not
//          hoding up
//   * Crossing Lane: Since the 32bits-length instruction maybe unaligned with 
//       word address boundry, then it could be in a cross-lane address
//       For example: 
//        * If it is crossing 64bits boundry, then it is crossing ITCM Lane
//        * If it is crossing 32bits boundry, then it is crossing System Memory Lane
//        * If it is crossing N-Bytes boundry, then it is crossing ICache Lane
//   * IR register: The fetch instruction will be put into IR register which 
//       is to be used by decoder to decoding it at EXU stage
//       The Lower 16bits of IR will always be loaded with new coming
//       instructions, but in order to save dynamic power, the higher 
//       16bits IR will only be loaded when incoming instruction is
//       32bits-length (checked by mini-decode module upfront IR 
//       register)
//       Note: The source of IR register Din depends on different
//         situations described in detailed fetching sheme
//   * Leftover buffer: The ifetch will always speculatively fetch a 32bits
//       back since we dont know the instruction to be fetched is 32bits or
//       16bits length (until after it read-back and decoded by mini-decoder).
//       When the new fetch is crossing lane-boundry from current lane
//       to next lane, and if the current lane read-out value is holding up.
//       Then new 32bits instruction to be fetched can be concatated by 
//       "current holding-up lane's upper 16bits" and "next lane's lower 16bits".
//       To make it in one cycle, we push the "current holding-up lane's 
//       upper 16bits" into leftover buffer (16bits) and only issue one ifetch
//       request to memory system, and when it responded with rdata-back, 
//       directly concatate the upper 16bits rdata-back with leftover buffer
//       to become the full 32bits instruction.
//
// The new ifetch request could encounter several cases:
//   * If the new ifetch address is in the same lane portion as last fetch
//     address (current PC):
//     ** If it is crossing the lane boundry, and the current lane rdout is 
//        holding up, then
//        ---- Push current lane rdout's upper 16bits into leftover buffer
//        ---- Issue ICB cmd request with next lane address 
//        ---- After the response rdata back:
//            ---- Put the leftover buffer value into IR lower 16bits
//            ---- Put rdata lower 16bits into IR upper 16bits if instr is 32bits-long
//
//     ** If it is crossing the lane boundry, but the current lane rdout is not 
//        holding up, then
//        ---- First cycle Issue ICB cmd request with current lane address 
//            ---- Put rdata upper 16bits into leftover buffer
//        ---- Second cycle Issue ICB cmd request with next lane address 
//            ---- Put the leftover buffer value into IR lower 16bits
//            ---- Put rdata upper 16bits into IR upper 16bits if instr is 32bits-long
//
//     ** If it is not crossing the lane boundry, and the current lane rdout is 
//        holding up, then
//        ---- Not issue ICB cmd request, just directly use current holding rdata
//            ---- Put aligned rdata into IR (upper 16bits 
//                    only loaded when instr is 32bits-long)
//
//     ** If it is not crossing the lane boundry, but the current lane rdout is 
//        not holding up, then
//        ---- Issue ICB cmd request with current lane address, just directly use
//               current holding rdata
//            ---- Put aligned rdata into IR (upper 16bits 
//                    only loaded when instr is 32bits-long)
//   
//
//   * If the new ifetch address is in the different lane portion as last fetch
//     address (current PC):
//     ** If it is crossing the lane boundry, regardless the current lane rdout is 
//        holding up or not, then
//        ---- First cycle Issue ICB cmd reqeust with current lane address 
//            ---- Put rdata upper 16bits into leftover buffer
//        ---- Second cycle Issue ICB cmd reqeust with next lane address 
//            ---- Put the leftover buffer value into IR lower 16bits
//            ---- Put rdata upper 16bits into IR upper 16bits if instr is 32bits-long
//
//     ** If it is not crossing the lane boundry, then
//        ---- Issue ICB cmd request with current lane address, just directly use
//               current holding rdata
//            ---- Put aligned rdata into IR (upper 16bits 
//                    only loaded when instr is 32bits-long)
//
// ===========================================================================

// Needs to define ITCM_BASE_REGION
//wire ifu_req_pc2itcm = (ifu_req_pc[`ITCM_BASE_REGION] == itcm_region_indic[`ITCM_BASE_REGION]); 
//wire ifu_req_lane_cross = 1'b0 | ( ifu_req_pc2itcm & (ifu_req_pc[1] == 1'b1))                                       
//wire ifu_req_lane_begin = 1'b0 | ( ifu_req_pc2itcm & (ifu_req_pc[1] == 1'b0)) 
                         

  // The scheme to check if the current accessing PC is same as last accessed ICB address
  //   is as below:
  //     * We only treat this case as true when it is sequentially instruction-fetch
  //         reqeust, and it is crossing the boundry as unalgned (1st 16bits and 2nd 16bits
  //         is crossing the boundry)
  //         ** If the ifetch request is the begining of lane boundry, and sequential fetch,
  //            Then:
  //                 **** If the last time it was prefetched ahead, then this time is accessing
  //                        the same address as last time. Otherwise not.
  //         ** If the ifetch request is not the begining of lane boundry, and sequential fetch,
  //            Then:
  //                 **** It must be access the same address as last time.
  //     * Note: All other non-sequential cases (e.g., flush, branch or replay) are not
  //          treated as this case
  //  
  //wire req_lane_cross_r;
  //wire ifu_req_lane_same = ifu_req_seq & (ifu_req_lane_begin ? req_lane_cross_r : 1'b1);
  
  //wire ifu_req_lane_holdup = 1'b0 | ifu_req_pc2itcm  // & ifu2itcm_holdup & (~itcm_nohold)) 

  //wire ifu_req_hsked = ifu_req_valid & ifu_req_ready;
  
  
  // Implement the state machine for the ifetch req interface
  //
  //wire req_need_2uop_r;
  //wire req_need_0uop_r;

  

  // Save the indicate flags for this ICB transaction to be used
  wire [`PC_SIZE-1:0] ifu2itcm_cmd_addr;
  // wire ['ITCM_RAM_AW-1:0] ifu2itcm_cmd_addr;
     
  // Generate the ifetch response channel
  // 
  // The ifetch response instr will have 2 sources
  // Please see "The itfctrl scheme introduction" for more details 
  //    * Source #1: The concatenation by {rdata[15:0],leftover}, when
  //          ** the state is in 2ND uop
  //          ** the state is in 1ND uop but it is same-cross-holdup case
  //    * Source #2: The rdata-aligned, when
  //           ** not selecting leftover
   // The fetched instruction from ITCM rdata bus 
  wire[31:0] ifu2itcm_icb_rsp_instr = ifu2itcm_rsp_rdata;
  wire ifu2itcm_cmd_valid; // Handshake valid
  wire ifu2itcm_cmd_ready; // Handshake ready
  wire [`ITCM_ADDR_WIDTH-1:0]   ifu2itcm_addr; //transcation to itcm start address
  
  wire ifu2itcm_rsp_valid; // Response valid 
  wire ifu2itcm_rsp_ready; // Response ready
  wire ifu2itcm_rsp_err;   

 
  

endmodule
