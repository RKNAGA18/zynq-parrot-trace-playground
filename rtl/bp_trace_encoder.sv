`include "bp_mock_defines.svh"

module bp_trace_encoder
 (
  input  logic clk_i,
  input  logic reset_i,

  input  bp_commit_pkt_s commit_pkt_i, 
  input  logic           commit_valid_i, 

  output logic [31:0]    trace_data_o,
  output logic           trace_valid_o
 );

  logic [31:0] last_pc_r;
  logic [31:0] current_pc;
  logic [31:0] delta;
  logic        is_discontinuity;

  assign current_pc = commit_pkt_i.pc;
  assign delta = current_pc - last_pc_r;
  assign is_discontinuity = (delta != 32'd4) && (delta != 32'd0); 

  always_ff @(posedge clk_i or posedge reset_i) begin
    if (reset_i) begin
      last_pc_r     <= 32'd0;
      trace_valid_o <= 1'b0;
      trace_data_o  <= 32'd0;
    end else begin
      if (commit_valid_i) begin
        last_pc_r <= current_pc;
        if (is_discontinuity) begin
          trace_valid_o <= 1'b1;
          trace_data_o  <= current_pc; 
        end else begin
          trace_valid_o <= 1'b0;
        end
      end else begin
        trace_valid_o <= 1'b0;
      end
    end
  end
endmodule
