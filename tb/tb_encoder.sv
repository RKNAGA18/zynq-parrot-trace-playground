`include "bp_mock_defines.svh"

module tb_encoder;

  // 1. Clock and Reset Generation
  logic clk;
  logic reset;

  // 2. Signals to Connect to DUT (Device Under Test)
  bp_commit_pkt_s commit_pkt;
  logic           commit_valid;
  
  logic [31:0]    trace_data;
  logic           trace_valid;

  // 3. Instantiate the Encoder Module
  bp_trace_encoder dut (
    .clk_i(clk),
    .reset_i(reset),
    
    // Input
    .commit_pkt_i(commit_pkt),
    .commit_valid_i(commit_valid),

    // Output
    .trace_data_o(trace_data),
    .trace_valid_o(trace_valid)
  );

  // 4. Clock Generation (Flip every 5 ticks)
  always #5 clk = ~clk;

  // 5. The Test Scenario
  initial begin
    // Setup for Waveform Viewing
    $dumpfile("encoder_test.vcd");
    $dumpvars(0, tb_encoder);

    // Initialize
    clk = 0;
    reset = 1;
    commit_valid = 0;
    commit_pkt.pc = 32'd0;
    commit_pkt.instr = 32'd0;

    // Reset Sequence
    #10 reset = 0;
    #10 reset = 1; // Pulse Reset
    #10 reset = 0;

    $display("--- Simulation Start ---");

    // Case 1: Send PC 0x1000
    #10;
    commit_valid = 1;
    commit_pkt.pc = 32'h00001000;
    #10;
    
    // Case 2: Step to 0x1004 (Delta = 4, Should be IGNORED)
    commit_pkt.pc = 32'h00001004;
    #10;

    // Case 3: Jump to 0x2000 (Delta != 4, Should TRIGGER)
    commit_pkt.pc = 32'h00002000;
    #10;

    // Case 4: Step to 0x2004 (Delta = 4, Should be IGNORED)
    commit_pkt.pc = 32'h00002004;
    #10;

    commit_valid = 0;
    #20;
    
    $display("--- Simulation End ---");
    $finish;
  end

  // Monitor: Watch what happens
  always @(posedge clk) begin
    if (trace_valid) begin
      $display("Time %0t: Trace Triggered! Sent PC: %h", $time, trace_data);
    end
  end

endmodule
