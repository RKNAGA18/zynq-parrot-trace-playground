`include "bp_mock_defines.svh"
`include "rtl/bp_nexus_defines.svh"

module tb_encoder(input logic clk);
  
  logic reset;
  bp_commit_pkt_s commit_pkt;
  logic commit_valid;
  nexus_trace_pkt_s trace_pkt;
  logic trace_valid, trace_ready;

  bp_trace_encoder dut (
    .clk_i(clk), .reset_i(reset),
    .commit_pkt_i(commit_pkt), .commit_valid_i(commit_valid),
    .trace_pkt_o(trace_pkt), .trace_valid_o(trace_valid), .trace_ready_i(trace_ready)
  );

  int cycle; 
  int fd; // File descriptor for trace dumping

  initial begin
    cycle = 0;
    reset = 1;
    commit_valid = 0;
    trace_ready = 1;
    commit_pkt.inst = 32'h0;
    commit_pkt.npc  = 64'h0;
    commit_pkt.priv_mode = 1'b0;
    commit_pkt.pc = 64'h0;
    
    // Open a file to write our raw hardware packets
    fd = $fopen("trace_output.hex", "w");
    $display("--- Verilator RV64 Simulation Start ---");
  end

  always_ff @(posedge clk) begin
    cycle <= cycle + 1;
    if (cycle == 2) reset <= 0;
    if (cycle == 3) reset <= 1;
    if (cycle == 4) reset <= 0;

    if (cycle == 6) begin
      commit_valid <= 1; commit_pkt.pc <= 64'h0000_0000_0000_1000;
    end
    if (cycle == 7) commit_valid <= 0;

    if (cycle == 10) begin
      commit_valid <= 1; commit_pkt.pc <= 64'h0000_0000_0000_1010;
    end
    if (cycle == 11) commit_valid <= 0;

    if (cycle == 16) begin
      commit_valid <= 1; commit_pkt.pc <= 64'hFFFF_FFFF_8000_0000;
    end
    if (cycle == 17) commit_valid <= 0;

    if (cycle == 25) begin
      $display("--- Simulation Complete. Trace dumped to trace_output.hex ---");
      $fclose(fd);
      $finish;
    end
  end

  // Hardware output stream: Just raw hex bits!
  always @(negedge clk) begin
    if (trace_valid) begin
      $fdisplay(fd, "%020x", trace_pkt); 
    end
  end
endmodule
