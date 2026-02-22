`include "bp_mock_defines.svh"
`include "rtl/bp_nexus_defines.svh"

// Note: clk is now an INPUT driven by the C++ wrapper!
module tb_encoder(input logic clk);
  
  logic reset;
  bp_commit_pkt_s commit_pkt;
  logic commit_valid;
  nexus_trace_pkt_s trace_pkt;
  logic trace_valid, trace_ready;

  // The include for simple_fifo has been removed from here!

  bp_trace_encoder dut (
    .clk_i(clk), .reset_i(reset),
    .commit_pkt_i(commit_pkt), .commit_valid_i(commit_valid),
    .trace_pkt_o(trace_pkt), .trace_valid_o(trace_valid), .trace_ready_i(trace_ready)
  );

  int cycle; // Cycle counter

  initial begin
    cycle = 0;
    reset = 1;
    commit_valid = 0;
    trace_ready = 1;
    commit_pkt.inst = 32'h0;
    commit_pkt.npc  = 64'h0;
    commit_pkt.priv_mode = 1'b0;
    commit_pkt.pc = 64'h0;
    $display("--- Verilator RV64 Simulation Start ---");
  end

  // Cycle-Accurate Stimulus Generation
  always_ff @(posedge clk) begin
    cycle <= cycle + 1;

    // Reset sequence
    if (cycle == 2) reset <= 0;
    if (cycle == 3) reset <= 1;
    if (cycle == 4) reset <= 0;

    // Case 1: Start execution
    if (cycle == 6) begin
      commit_valid <= 1; commit_pkt.pc <= 64'h0000_0000_0000_1000;
    end
    if (cycle == 7) commit_valid <= 0;

    // Case 2: Wait a few cycles, Small Jump
    if (cycle == 10) begin
      commit_valid <= 1; commit_pkt.pc <= 64'h0000_0000_0000_1010;
    end
    if (cycle == 11) commit_valid <= 0;

    // Case 3: Wait more cycles, Huge Jump
    if (cycle == 16) begin
      commit_valid <= 1; commit_pkt.pc <= 64'hFFFF_FFFF_8000_0000;
    end
    if (cycle == 17) commit_valid <= 0;

    // End simulation
    if (cycle == 25) begin
      $display("--- Simulation Complete ---");
      $finish;
    end
  end

  always @(negedge clk) begin
    if (trace_valid) begin
      if (trace_pkt.mcode == NEXUS_MCODE_COMPRESSED) begin
         $display("Cycle %0d: [COMPRESSED] Delay: %0d | Offset: %0d", 
                  cycle, trace_pkt.timestamp, trace_pkt.addr);
      end else if (trace_pkt.mcode == NEXUS_MCODE_DIRECT_BRANCH) begin
         $display("Cycle %0d: [FULL JUMP]  Delay: %0d | Target: %h", 
                  cycle, trace_pkt.timestamp, trace_pkt.addr);
      end
    end
  end
endmodule
