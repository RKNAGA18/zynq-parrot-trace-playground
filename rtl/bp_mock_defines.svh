`ifndef BP_MOCK_DEFINES_SVH
`define BP_MOCK_DEFINES_SVH

// Simulating realistic 64-bit RISC-V (RV64) types
typedef logic [63:0] bp_vaddr_t;
typedef logic [31:0] bp_instr_t;

// The official-looking Commit Packet
typedef struct packed {
    bp_vaddr_t pc;         // 64-bit Program Counter
    bp_vaddr_t npc;        // 64-bit Next Program Counter
    bp_instr_t inst;       // 32-bit Instruction
    logic      priv_mode;  // Privilege mode (e.g., User/Machine)
} bp_commit_pkt_s;

`endif
