`include "bp_mock_defines.svh"
`include "rtl/bp_nexus_defines.svh"

module tb_encoder;
  logic clk, reset;
  bp_commit_pkt_s commit_pkt;
  logic commit_valid;
  nexus_trace_pkt_s trace_pkt;
  logic trace_valid, trace_ready;

  `include "rtl/simple_fifo.sv"

  bp_trace_encoder dut (
    .clk_i(clk), .reset_i(reset),
    .commit_pkt_i(commit_pkt), .commit_valid_i(commit_valid),
    .trace_pkt_o(trace_pkt), .trace_valid_o(trace_valid), .trace_ready_i(trace_ready)
  );

  // Clock Generation (10ns period)
  always #5 clk = ~clk;

  initial begin
    $dumpfile("encoder_test.vcd");
    $dumpvars(0, tb_encoder);
    clk = 0; reset = 1; commit_valid = 0; trace_ready = 1; 
    #10 reset = 0; #10 reset = 1; #10 reset = 0;

    $display("--- Simulation Start ---");

    // Case 1: Start execution
    #10 commit_valid = 1; commit_pkt.pc = 32'h1000; 
    
    // Case 2: Wait 3 clock cycles (#30), then jump
    // Clock period is 10. Wait 30 = 3 cycles.
    #30 commit_pkt.pc = 32'h1010; 

    // Case 3: Wait 6 clock cycles (#60), then huge jump
    #60 commit_pkt.pc = 32'h80000000;

    #20 commit_valid = 0;
    #50;
    $finish;
  end

  // Monitor: Now prints the timestamp!
  always @(negedge clk) begin
    if (trace_valid) begin
      if (trace_pkt.mcode == NEXUS_MCODE_COMPRESSED) begin
         $display("Time %0t: [COMPRESSED] Delay: %0d cycles | Offset: %0d bytes", 
                  $time, trace_pkt.timestamp, trace_pkt.addr);
      end else if (trace_pkt.mcode == NEXUS_MCODE_DIRECT_BRANCH) begin
         $display("Time %0t: [FULL JUMP]  Delay: %0d cycles | Target: %h", 
                  $time, trace_pkt.timestamp, trace_pkt.addr);
      end
    end
  end
endmodule
