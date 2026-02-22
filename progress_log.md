# GSoC 2026 Progress Log: ZynqParrot Trace Encoder

### 13th Feb 26 Progress: Initial Setup (Day 1)
* Analyzed RISC-V Trace Spec (Branch Trace section).
* Created `bp_trace_encoder.sv` module shell.
* Mapped `bp_be_commit_pkt` signals to the trace encoder inputs.
* **Technical Details:**
  * Used `bp_be_commit_pkt_s` struct to unpack PC and Instruction without manual bit slicing.
  * Defined the output interface to match the Trace Spec packet format.

### 14th Feb 26 Progress: Mocking & Environment Setup (Day 2)
* **Objective:** Create a lightweight, standalone simulation environment to bypass the complex dependencies of the full BlackParrot build.
* **Implementation:**
    * Created `rtl/bp_mock_defines.svh` to mock the necessary BlackParrot struct definitions (`bp_commit_pkt_s`).
    * Set up the project directory structure (`rtl/` for logic, `tb/` for tests).
    * Created the simulation script `run_sim.sh` using Icarus Verilog (`iverilog`) for rapid iteration.
* **Verification:** Successfully compiled and ran a basic simulation, confirming the toolchain was working independently of the heavy BlackParrot repository.

### 15th Feb 26 Progress: Delta Compression Logic (Day 3)
* **Objective:** Implement the core hardware logic to filter out sequential instruction execution and only report program flow changes (branches/jumps).
* **Implementation:**
    * Created `rtl/bp_trace_encoder.sv` with a state register `last_pc_r`.
    * Implemented combinational delta calculation: `delta = current_pc - last_pc_r`.
    * **Decision Logic:** Assert `trace_valid_o` only when `delta != 4` (indicating a jump).
* **Verification:** Simulation waveforms confirmed the encoder ignores sequential steps (PC + 4) and triggers only on jumps (e.g., 0x1000 -> 0x2000).

### 16th Feb 26 Progress: FIFO Buffer & Backpressure (Day 4)
* **Objective:** Prevent data loss when the debug interface (receiver) is busy by implementing a First-In-First-Out (FIFO) buffer.
* **Implementation:**
    * Created `rtl/simple_fifo.sv`, a parameterized ring-buffer FIFO.
    * Integrated the FIFO into `bp_trace_encoder.sv` to store jumps when the output is stalled.
    * Implemented the `valid`/`ready`/`yumi` handshake protocol to manage data flow.
* **Verification:** Validated a "Traffic Jam" scenario where the receiver signal `trace_ready_i` was held low; data was successfully stored in the FIFO and released in order once the receiver became ready.

### 17th Feb 26 Progress: Nexus Packetization (Day 5)
* **Objective:** Transition from sending raw binary data to sending structured packets compliant with the IEEE-ISTO 5001 Nexus Trace standard (Lite).
* **Implementation:**
    * Created `rtl/bp_nexus_defines.svh` to define the 40-bit trace packet structure (`nexus_trace_pkt_s`) and Message Codes (`MCODE`).
    * Updated `bp_trace_encoder.sv` to pack `MCODE`, `Source ID`, and `Address` into a single struct before buffering.
    * Updated `tb/tb_encoder.sv` to "unpack" and verify the struct fields during simulation.
* **Verification:** Simulation output correctly identified packets as `Direct Branch (0x03)` and extracted the target address, proving protocol compliance.

### 18th Feb 26 Progress: Variable Length Encoding (VLE) (Day 6)
* **Objective:** Optimize trace bandwidth by implementing dynamic packet compression for short jumps.
* **Implementation:**
    * Updated `rtl/bp_nexus_defines.svh` to include `NEXUS_MCODE_COMPRESSED (0x09)`.
    * Modified `bp_trace_encoder.sv` to calculate jump distance (`delta`).
    * **Decision Logic:**
        * If `delta < 256 bytes`: Send **Compressed Packet** (Payload = Offset).
        * If `delta >= 256 bytes`: Send **Full Packet** (Payload = Target Address).
* **Verification:** Simulation confirmed the hardware automatically switches between Full and Compressed formats based on the jump distance, significantly reducing bandwidth for small loops.

### 19th Feb 26 Progress: Timestamp Integration (Day 7)
* **Objective:** Embed precise timing information into the trace packets to allow cycle-accurate reconstruction of the program execution flow by the hardware debugger.
* **Implementation:**
    * Expanded the `nexus_trace_pkt_s` struct in `rtl/bp_nexus_defines.svh` to 48 bits by adding an 8-bit `timestamp` field.
    * Implemented a local cycle counter (`timer_r`) inside `bp_trace_encoder.sv` that increments on every clock edge.
    * **Logic Update:** Configured the encoder to snapshot the current counter value and attach it to the trace packet whenever a jump is detected.
    * Implemented **Relative Timestamps (Delta Time)**: The counter automatically resets to zero after every successfully transmitted packet to save bit-width and optimize bandwidth.
* **Verification:** Modified the testbench (`tb/tb_encoder.sv`) to simulate variable execution delays (e.g., waiting 3 and 6 clock cycles between jumps). The simulation monitor successfully verified that the packets contained the exact delta cycle counts (`Delay: 2 cycles` and `Delay: 5 cycles`), proving the hardware math is accurate.

### 20th Feb 26 Progress: RV64 Architecture Alignment (Day 8)
* **Objective:** Align the standalone trace prototype with BlackParrot's 64-bit (RV64) architecture based on maintainer feedback regarding the `commit_pkt` structures.
* **Implementation:**
    * Updated `rtl/bp_mock_defines.svh` to mirror the official struct, introducing `bp_vaddr_t` (64-bit) for the Program Counter and `bp_instr_t` (32-bit) for the instruction payload.
    * Upgraded the `nexus_trace_pkt_s` structure to 80 bits to accommodate a full 64-bit address payload.
    * Modified the `bp_trace_encoder.sv` data path and delta calculation logic to operate on 64-bit wires natively.
    * **VLE Adjustment:** The `is_compressed` logic was updated to verify that the upper 56 bits of the 64-bit delta are zero, ensuring accurate compression on the wider bus.
* **Verification:** The testbench successfully simulated a 64-bit kernel-space jump (`0xFFFFFFFF80000000`), proving the architecture's readiness for integration with `bp_common_be_if.svh`.

### 21st Feb 26 Progress: Cycle-Accurate Verilator Migration (Day 9)
* **Objective:** Migrate the simulation environment from an event-driven simulator (Icarus Verilog) to a high-speed, cycle-accurate compiled C++ model using Verilator, aligning with FOSSi maintainer recommendations.
* **Implementation:**
    * Created a C++ testbench wrapper (`tb/sim_main.cpp`) to instantiate the Verilated model, drive the simulation clock natively, and manage VCD waveform generation.
    * Refactored `tb/tb_encoder.sv` into a strict, cycle-accurate state machine, removing unsupported `#delay` statements to comply with Verilator's synthesis rules.
    * Rewrote `run_sim.sh` to translate the SystemVerilog RTL into optimized C++ and compile it into a standalone, high-performance binary executable.
* **Verification:** The compiled Verilator binary successfully executed the RV64 test cases—including VLE compression and kernel-space jumps—proving the standalone trace architecture is fully compatible with industry-standard verification toolchains.
