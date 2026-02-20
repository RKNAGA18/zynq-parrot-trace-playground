`include "bp_mock_defines.svh"
`include "rtl/bp_nexus_defines.svh"

module bp_trace_encoder
 (
  input  logic clk_i,
  input  logic reset_i,
  input  bp_commit_pkt_s commit_pkt_i, 
  input  logic           commit_valid_i, 
  output nexus_trace_pkt_s trace_pkt_o,  
  output logic             trace_valid_o,
  input  logic             trace_ready_i 
 );

  logic [31:0] last_pc_r;
  logic [31:0] current_pc;
  logic [31:0] delta;
  logic        is_discontinuity;
  logic        is_compressed;
  
  logic [7:0]  timer_r; // NEW: The internal cycle counter

  nexus_trace_pkt_s next_packet;
  logic        fifo_ready_lo; 
  logic        fifo_v_li;     

  assign current_pc = commit_pkt_i.pc;
  assign delta = current_pc - last_pc_r;
  assign is_discontinuity = (delta != 32'd4) && (delta != 32'd0); 
  assign is_compressed = (delta[31:8] == 24'd0);

  // Packet Construction (Now includes Timestamp!)
  always_comb begin
    next_packet.src_id    = 2'b00;
    next_packet.timestamp = timer_r; // Attach the current timer value

    if (is_compressed) begin
        next_packet.mcode = NEXUS_MCODE_COMPRESSED;
        next_packet.addr  = delta; 
    end else begin
        next_packet.mcode = NEXUS_MCODE_DIRECT_BRANCH;
        next_packet.addr  = current_pc;
    end
  end

  assign fifo_v_li = commit_valid_i && is_discontinuity;

  // Clocked Logic: PC tracking AND Timer management
  always_ff @(posedge clk_i or posedge reset_i) begin
    if (reset_i) begin
      last_pc_r <= 32'd0;
      timer_r   <= 8'd0;
    end else begin
      // PC History Update
      if (commit_valid_i) begin
        last_pc_r <= current_pc;
      end
      
      // Timer Logic: Reset if we sent a packet, otherwise increment
      if (fifo_v_li && fifo_ready_lo) begin
        timer_r <= 8'd0; // Reset after successful transmission
      end else begin
        // Prevent overflow (cap at 255)
        if (timer_r != 8'hFF) begin 
            timer_r <= timer_r + 1'b1;
        end
      end
    end
  end

  simple_fifo #(.WIDTH($bits(nexus_trace_pkt_s)), .DEPTH(4)) trace_fifo
   (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .data_i(next_packet),     
    .v_i(fifo_v_li),       
    .ready_o(fifo_ready_lo), 
    .data_o(trace_pkt_o),     
    .v_o(trace_valid_o),
    .yumi_i(trace_ready_i && trace_valid_o) 
   );

endmodule
