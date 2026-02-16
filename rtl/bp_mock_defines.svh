`ifndef BP_MOCK_DEFINES_SVH
`define BP_MOCK_DEFINES_SVH

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] instr;
} bp_commit_pkt_s;

`endif
