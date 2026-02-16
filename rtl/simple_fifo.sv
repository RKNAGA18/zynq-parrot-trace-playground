module simple_fifo
 #(parameter WIDTH = 32, parameter DEPTH = 4)
 (
  input  logic             clk_i,
  input  logic             reset_i,

  // --- Enqueue (Write) Side ---
  input  logic [WIDTH-1:0] data_i,
  input  logic             v_i,      // Valid: "I want to write"
  output logic             ready_o,  // Ready: "I have space"

  // --- Dequeue (Read) Side ---
  output logic [WIDTH-1:0] data_o,
  output logic             v_o,      // Valid: "I have data for you"
  input  logic             yumi_i    // Yumi: "I consumed it" (You-Me handshake)
 );

  // Internal Memory (The Array)
  logic [WIDTH-1:0] mem_r [DEPTH-1:0];
  
  // Pointers
  logic [$clog2(DEPTH)-1:0] wptr_r, rptr_r;
  logic [$clog2(DEPTH+1)-1:0] count_r; // How many items are in the FIFO

  // Status Flags
  logic full, empty;
  assign full  = (count_r == DEPTH);
  assign empty = (count_r == 0);

  // Handshake Logic
  assign ready_o = !full;  // We are ready if we represent NOT full
  assign v_o     = !empty; // We are valid if we are NOT empty
  assign data_o  = mem_r[rptr_r]; // Always output the data at the read pointer

  always_ff @(posedge clk_i or posedge reset_i) begin
    if (reset_i) begin
      wptr_r  <= 0;
      rptr_r  <= 0;
      count_r <= 0;
    end else begin
      // WRITE Operation
      if (v_i && !full) begin
        mem_r[wptr_r] <= data_i;
        wptr_r        <= wptr_r + 1; // Auto-wraps due to bit width? No, needs modulo or power-of-2 depth.
                                     // Since DEPTH=4 (2 bits), adding 1 to '11' becomes '00'. Magic!
      end

      // READ Operation
      if (yumi_i && !empty) begin
        rptr_r <= rptr_r + 1;
      end

      // COUNT Update
      case ({ (v_i && !full), (yumi_i && !empty) })
        2'b10: count_r <= count_r + 1; // Write only
        2'b01: count_r <= count_r - 1; // Read only
        default: count_r <= count_r;   // Both or Neither
      endcase
    end
  end

endmodule
