`include "bp_mock_defines.svh"
`include "rtl/bp_nexus_defines.svh"

module bp_trace_encoder
 (
  input  logic clk_i,
  input  logic reset_i,

  // CPU Input
  input  bp_commit_pkt_s commit_pkt_i, 
  input  logic           commit_valid_i, 

  // Output Interface (Now sending Nexus Packets!)
  output nexus_trace_pkt_s trace_pkt_o,  // 40-bit Struct
  output logic             trace_valid_o,
  input  logic             trace_ready_i 
 );

  // Internal Signals
  logic [31:0] last_pc_r;
  logic [31:0] current_pc;
  logic [31:0] delta;
  logic        is_discontinuity;
  
  // Packet Construction
  nexus_trace_pkt_s next_packet;

  // FIFO Signals
  logic        fifo_ready_lo; 
  logic        fifo_v_li;     

  // --- 1. Delta Compression Logic ---
  assign current_pc = commit_pkt_i.pc;
  assign delta = current_pc - last_pc_r;
  assign is_discontinuity = (delta != 32'd4) && (delta != 32'd0); 

  // --- 2. Packet Construction ---
  // We build the packet immediately, even if we don't send it yet.
  always_comb begin
    next_packet.mcode  = NEXUS_MCODE_DIRECT_BRANCH; // It's a Branch
    next_packet.src_id = 2'b00;                     // Core 0
    next_packet.addr   = current_pc;                // The Target
  end

  // We write to FIFO if Valid Jump detected
  assign fifo_v_li = commit_valid_i && is_discontinuity;

  always_ff @(posedge clk_i or posedge reset_i) begin
    if (reset_i) begin
      last_pc_r <= 32'd0;
    end else begin
      if (commit_valid_i) begin
        last_pc_r <= current_pc;
      end
    end
  end

  // --- 3. The FIFO Instance ---
  // Note: WIDTH is now 40 bits (Size of nexus_trace_pkt_s)
  simple_fifo #(.WIDTH($bits(nexus_trace_pkt_s)), .DEPTH(4)) trace_fifo
   (
    .clk_i(clk_i),
    .reset_i(reset_i),

    .data_i(next_packet),     // WRITE the Packet
    .v_i(fifo_v_li),       
    .ready_o(fifo_ready_lo), 

    .data_o(trace_pkt_o),     // READ the Packet
    .v_o(trace_valid_o),
    .yumi_i(trace_ready_i && trace_valid_o) 
   );

endmodule
