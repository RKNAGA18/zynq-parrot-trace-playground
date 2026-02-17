`ifndef BP_NEXUS_DEFINES_SVH
`define BP_NEXUS_DEFINES_SVH

// 1. Nexus Message Codes (MCODE)
// These are the "Types" of messages we can send.
typedef enum logic [5:0] {
    NEXUS_MCODE_DIRECT_BRANCH   = 6'h03, // Standard Jump
    NEXUS_MCODE_INDIRECT_BRANCH = 6'h04, // Register Jump
    NEXUS_MCODE_ERROR           = 6'h00  // Something broke
} nexus_mcode_e;

// 2. The Packet Structure
// Total Width: 6 + 2 + 32 = 40 bits
typedef struct packed {
    nexus_mcode_e        mcode;   // 6 bits: Type
    logic [1:0]          src_id;  // 2 bits: Core ID
    logic [31:0]         addr;    // 32 bits: The Data
} nexus_trace_pkt_s;

`endif
