`ifndef BP_NEXUS_DEFINES_SVH
`define BP_NEXUS_DEFINES_SVH

typedef enum logic [5:0] {
    NEXUS_MCODE_DIRECT_BRANCH   = 6'h03, 
    NEXUS_MCODE_COMPRESSED      = 6'h09, 
    NEXUS_MCODE_ERROR           = 6'h00 
} nexus_mcode_e;

// 80-bit Nexus Packet (RV64 Ready)
typedef struct packed {
    nexus_mcode_e        mcode;     // 6 bits
    logic [1:0]          src_id;    // 2 bits
    logic [7:0]          timestamp; // 8 bits
    logic [63:0]         addr;      // 64-bit Address payload
} nexus_trace_pkt_s;

`endif
