`include "bp_mock_defines.svh"

module tb_encoder;
  logic clk, reset;
  bp_commit_pkt_s commit_pkt;
  logic commit_valid;
  
  // Output Signals
  logic [31:0] trace_data;
  logic        trace_valid;
  logic        trace_ready;

  // Include FIFO
  `include "rtl/simple_fifo.sv"

  bp_trace_encoder dut (
    .clk_i(clk),
    .reset_i(reset),
    .commit_pkt_i(commit_pkt),
    .commit_valid_i(commit_valid),
    .trace_data_o(trace_data),
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
    // Ready is HIGH, so this should appear immediately.
    #10;
    commit_valid = 1;
    commit_pkt.pc = 32'h1000; 
    #10;
    commit_pkt.pc = 32'h2000; 
    #10;
    
    // Case 2: Backpressure (Traffic Jam)
    // We STOP listening. The FIFO must hold the data.
    trace_ready = 0; 
    $display("--- Backpressure Active (Ready=0) ---");
    
    commit_pkt.pc = 32'h3000; // Should be Stored
    #10;
    commit_pkt.pc = 32'h4000; // Should be Stored
    #10;
    
    // Stop the CPU, Wake up the Receiver
    commit_valid = 0; 
    trace_ready = 1;
    $display("--- Backpressure Released (Ready=1) ---");
    
    #100; // Give time for FIFO to empty
    $display("--- Simulation End ---");
    $finish;
  end

  // FIX: Monitor on NEGEDGE to avoid race conditions
  always @(negedge clk) begin
    if (trace_valid) begin
      $display("Time %0t: Trace Triggered! Sent PC: %h", $time, trace_data);
    end
  end

endmodule
