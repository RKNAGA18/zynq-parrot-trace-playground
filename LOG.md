13th feb 26
**Progress**: 
- Analyzed RISC-V Trace Spec (Branch Trace section).
- Created `bp_trace_encoder.sv` module shell.
- Mapped `bp_be_commit_pkt` signals to the trace encoder inputs.
**Technical Details**: 
- Used `bp_be_commit_pkt_s` struct to unpack PC and Instruction without manual bit slicing.
- Defined the output interface to match the Trace Spec packet format.
