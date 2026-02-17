`include "bp_mock_defines.svh"
`include "rtl/bp_nexus_defines.svh" // Include the new dictionary

module tb_encoder;
  logic clk, reset;
  bp_commit_pkt_s commit_pkt;
  logic commit_valid;
  
  // Output Signals (Now using the Struct)
  nexus_trace_pkt_s trace_pkt;
  logic             trace_valid;
  logic             trace_ready;

  `include "rtl/simple_fifo.sv"

  bp_trace_encoder dut (
    .clk_i(clk),
    .reset_i(reset),
    .commit_pkt_i(commit_pkt),
    .commit_valid_i(commit_valid),
    .trace_pkt_o(trace_pkt),   // Connect Packet
    .trace_valid_o(trace_valid),
    .trace_ready_i(trace_ready)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("encoder_test.vcd");
    $dumpvars(0, tb_encoder);

    clk = 0; reset = 1; commit_valid = 0; 
    trace_ready = 1; 
    
    #10 reset = 0;
    #10 reset = 1; 
    #10 reset = 0;

    $display("--- Simulation Start ---");

    // Case 1: Normal Jump (0x1000 -> 0x2000)
    #10;
    commit_valid = 1;
    commit_pkt.pc = 32'h1000; 
    #10;
    commit_pkt.pc = 32'h2000; // Jump!
    #10;
    
    // Case 2: Backpressure Test
    trace_ready = 0; 
    commit_pkt.pc = 32'h3000; 
    #10;
    
    commit_valid = 0; 
    trace_ready = 1; 
    #50;

    $display("--- Simulation End ---");
    $finish;
  end

  // Monitor: Unpack the Nexus Packet
  always @(negedge clk) begin
    if (trace_valid) begin
      $display("Time %0t: PACKET RECEIVED!", $time);
      $display("  -> Type: %h (Direct Branch)", trace_pkt.mcode);
      $display("  -> Addr: %h", trace_pkt.addr);
    end
  end

endmodule
