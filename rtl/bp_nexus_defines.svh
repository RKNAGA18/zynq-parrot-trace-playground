`ifndef BP_NEXUS_DEFINES_SVH
`define BP_NEXUS_DEFINES_SVH

typedef enum logic [5:0] {
    NEXUS_MCODE_DIRECT_BRANCH   = 6'h03, 
    NEXUS_MCODE_COMPRESSED      = 6'h09, 
    NEXUS_MCODE_ERROR           = 6'h00 
} nexus_mcode_e;

// Expanded Packet Structure (48 bits total)
typedef struct packed {
    nexus_mcode_e        mcode;     // 6 bits
    logic [1:0]          src_id;    // 2 bits
    logic [7:0]          timestamp; // 8 bits: Cycles since last jump
    logic [31:0]         addr;      // 32 bits
} nexus_trace_pkt_s;

`endif
