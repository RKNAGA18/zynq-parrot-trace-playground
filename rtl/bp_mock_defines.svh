`ifndef BP_MOCK_DEFINES_SVH
`define BP_MOCK_DEFINES_SVH

// 1. Define the parameters we need
parameter vaddr_width_p = 40;
parameter paddr_width_p = 40;
parameter asid_width_p  = 10;
parameter branch_metadata_fwd_width_p = 0;

// 2. Define the Struct (Simplified for Simulation)
// We only care about PC and Instruction for now.
typedef struct packed {
    logic [vaddr_width_p-1:0] pc;          // 40 bits
    logic [31:0]              instr;       // 32 bits
    logic [29:0]              padding;     // Padding to make it ~100 bits
} bp_be_commit_pkt_s;

// 3. Define the Width Macro
localparam bp_be_commit_pkt_width_lp = $bits(bp_be_commit_pkt_s);

`endif
