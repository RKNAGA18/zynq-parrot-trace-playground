`ifndef BP_NEXUS_DEFINES_SVH
`define BP_NEXUS_DEFINES_SVH

// 1. Nexus Message Codes (MCODE)
typedef enum logic [5:0] {
    NEXUS_MCODE_DIRECT_BRANCH   = 6'h03, // Full 32-bit Jump
    NEXUS_MCODE_COMPRESSED      = 6'h09, // Short Offset Jump (New!)
    NEXUS_MCODE_ERROR           = 6'h00 
} nexus_mcode_e;

// 2. The Packet Structure (40 bits)
// Note: In a real chip, we would chop bits off. 
// For now, we use the same container but change the 'mcode'.
typedef struct packed {
    nexus_mcode_e        mcode;   // 6 bits
    logic [1:0]          src_id;  // 2 bits
    logic [31:0]         addr;    // 32 bits (Stores Address OR Offset)
} nexus_trace_pkt_s;

`endif
