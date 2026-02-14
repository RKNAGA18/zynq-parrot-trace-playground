// USE OUR MOCK FILE INSTEAD
`include "bp_mock_defines.svh"

module bp_trace_encoder
 #(parameter trace_width_p = 64)
  (input                                clk_i
   , input                              reset_i

   // Input Packet (Using our Mock definition)
   , input [bp_be_commit_pkt_width_lp-1:0] commit_pkt_i
   , input                              commit_v_i
   , input                              commit_ready_i

   // Trace Output
   , output logic [trace_width_p-1:0]   trace_data_o
   , output logic                       trace_v_o
   , input                              trace_ready_i
   );

   // Cast the input bits into our local struct
   bp_be_commit_pkt_s commit_pkt;
   assign commit_pkt = commit_pkt_i;

   // Extract Signals
   logic [39:0] current_pc;
   logic [31:0] current_instr;

   assign current_pc    = commit_pkt.pc;
   assign current_instr = commit_pkt.instr;

   // (Logic will go here later)
   assign trace_data_o = '0;
   assign trace_v_o    = 1'b0;

endmodule
