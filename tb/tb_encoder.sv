`timescale 1ns/1ps
`include "bp_mock_defines.svh" // Include the mock definitions

module tb_encoder();

   logic clk, reset;
   
   // Mock Inputs
   logic [39:0] mock_pc;
   logic [31:0] mock_instr;
   logic        mock_v, mock_ready;
   
   // The Packet Signal
   logic [bp_be_commit_pkt_width_lp-1:0] commit_pkt_cast; 

   // Outputs
   logic [63:0] trace_data;
   logic        trace_v, trace_ready;

   // Clock Gen
   initial clk = 0;
   always #5 clk = ~clk;

   // DUT (Device Under Test)
   bp_trace_encoder DUT (
       .clk_i(clk)
      ,.reset_i(reset)
      ,.commit_pkt_i(commit_pkt_cast)
      ,.commit_v_i(mock_v)
      ,.commit_ready_i(mock_ready)
      ,.trace_data_o(trace_data)
      ,.trace_v_o(trace_v)
      ,.trace_ready_i(trace_ready)
    );

   initial begin
      $dumpfile("encoder_test.vcd");
      $dumpvars(0, tb_encoder);

      // Initialize
      reset = 1; mock_v = 0;
      #20; reset = 0;

      // Test 1: PC = 0x1000
      @(posedge clk);
      mock_pc = 40'h1000;
      mock_instr = 32'h00000013; 
      // Pack the struct manually: {PC, Instr, Padding} matches the struct order
      commit_pkt_cast = {mock_pc, mock_instr, 30'd0}; 
      $display("Sent PC: %h", mock_pc);

      // Test 2: PC = 0x1004
      @(posedge clk);
      mock_pc = 40'h1004;
      commit_pkt_cast = {mock_pc, mock_instr, 30'd0};
      $display("Sent PC: %h", mock_pc);

      #50;
      $display("--------------------------------------------------");
      $display("  COMPILATION SUCCESS!  (For Real This Time)");
      $display("--------------------------------------------------");
      $finish;
   end
endmodule
