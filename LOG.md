13th feb 26
**Progress**: 
- Analyzed RISC-V Trace Spec (Branch Trace section).
- Created `bp_trace_encoder.sv` module shell.
- Mapped `bp_be_commit_pkt` signals to the trace encoder inputs.
**Technical Details**: 
- Used `bp_be_commit_pkt_s` struct to unpack PC and Instruction without manual bit slicing.
- Defined the output interface to match the Trace Spec packet format.
### 19th Feb 26 Progress: Timestamp Integration (Day 7)
* **Objective:** Embed precise timing information into the trace packets to allow cycle-accurate reconstruction of the program execution flow by the hardware debugger.
* **Implementation:**
    * Expanded the `nexus_trace_pkt_s` struct in `rtl/bp_nexus_defines.svh` to 48 bits by adding an 8-bit `timestamp` field.
    * Implemented a local cycle counter (`timer_r`) inside `bp_trace_encoder.sv` that increments on every clock edge.
    * **Logic Update:** Configured the encoder to snapshot the current counter value and attach it to the trace packet whenever a jump is detected.
    * Implemented **Relative Timestamps (Delta Time)**: The counter automatically resets to zero after every successfully transmitted packet to save bit-width and optimize bandwidth.
* **Verification:** Modified the testbench (`tb/tb_encoder.sv`) to simulate variable execution delays (e.g., waiting 3 and 6 clock cycles between jumps). The simulation monitor successfully verified that the packets contained the exact delta cycle counts (`Delay: 2 cycles` and `Delay: 5 cycles`), proving the hardware math is accurate.
