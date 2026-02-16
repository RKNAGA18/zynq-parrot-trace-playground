`include "bp_mock_defines.svh"

module bp_trace_encoder
 (
  input  logic clk_i,
  input  logic reset_i,

  // CPU Input
  input  bp_commit_pkt_s commit_pkt_i, 
  input  logic           commit_valid_i, 

  // Output Interface (Now with Backpressure!)
  output logic [31:0]    trace_data_o,
  output logic           trace_valid_o,
  input  logic           trace_ready_i // NEW: The outside world tells us if it's ready
 );

  // Internal Logic Signals
  logic [31:0] last_pc_r;
  logic [31:0] current_pc;
  logic [31:0] delta;
  logic        is_discontinuity;
  
  // FIFO Signals
  logic        fifo_ready_lo; // Is the FIFO ready to take our data?
  logic        fifo_v_li;     // Do we want to write to the FIFO?
  logic        fifo_yumi_li;  // Did the outside world consume the data?

  // --- 1. The Compression Logic (Same as Day 3) ---
  assign current_pc = commit_pkt_i.pc;
  assign delta = current_pc - last_pc_r;
  assign is_discontinuity = (delta != 32'd4) && (delta != 32'd0); 

  // We want to write to FIFO IF: 
  // 1. The CPU sent a valid commit 
  // 2. AND it is a discontinuity (jump)
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

  // --- 2. The FIFO Instance ---
  simple_fifo #(.WIDTH(32), .DEPTH(4)) trace_fifo
   (
    .clk_i(clk_i),
    .reset_i(reset_i),

    // Write Side (Encoder -> FIFO)
    .data_i(current_pc),   // The data to save
    .v_i(fifo_v_li),       // "I want to save this"
    .ready_o(fifo_ready_lo), // "Okay, I have space"

    // Read Side (FIFO -> Outside World)
    .data_o(trace_data_o),
    .v_o(trace_valid_o),
    .yumi_i(trace_ready_i && trace_valid_o) // "Yumi" means Valid AND Ready (Handshake)
   );

endmodule
