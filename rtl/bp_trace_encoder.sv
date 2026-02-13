`include "bp_common_defines.svh"
`include "bp_be_defines.svh"

module bp_trace_encoder
 import bp_common_pkg::*;
 import bp_be_pkg::*;
 #(parameter bp_params_e bp_params_p = e_bp_default_cfg
   `declare_bp_proc_params(bp_params_p)
   // Define the width of the trace packet (e.g., 64 bits)
   , parameter trace_width_p = 64
   )
  (input                                clk_i
   , input                              reset_i

   // The Commit Packet: Contains PC, Instruction, Privilege Mode
   // We use the struct defined in bp_be_pkg to automatically unpack signals
   , input [bp_be_commit_pkt_width_lp-1:0] commit_pkt_i
   
   // Flow Control: Don't trace if the backend is stalled/poisoned
   , input                              commit_v_i     // Is the packet valid?
   , input                              commit_ready_i // Is the backend ready?

   // Trace Output Interface (To FIFO)
   , output logic [trace_width_p-1:0]   trace_data_o   // The compressed packet
   , output logic                       trace_v_o      // "I have data for you"
   , input                              trace_ready_i  // "I am ready to receive"
   );

   // Internal Unpacking
   // This declares the structs so we can read .pc and .instr directly
   `declare_bp_be_internal_if_structs(vaddr_width_p, paddr_width_p, asid_width_p, branch_metadata_fwd_width_p);
   
   // Cast the input bits into the readable struct
   bp_be_commit_pkt_s commit_pkt;
   assign commit_pkt = commit_pkt_i;

   // Logic signals (We will use these in Day 3)
   logic [vaddr_width_p-1:0] current_pc;
   logic [instr_width_gp-1:0] current_instr;

   assign current_pc    = commit_pkt.pc;       // The Program Counter
   assign current_instr = commit_pkt.instr;    // The Instruction Bits

endmodule
