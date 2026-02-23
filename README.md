# ZynqParrot Trace Encoder (Standalone Prototype)

A cycle-accurate, standalone RISC-V hardware trace encoder prototype designed for integration into the **BlackParrot** (`bp_be_top`) backend pipeline . 

This repository serves as a proof-of-concept for compressing execution traces natively in hardware to overcome FPGA I/O bandwidth limitations when debugging soft-cores.

## Architecture & Features

This prototype mirrors the exact interfaces found in the FOSSi `bp_common` repository.
* **RV64 Alignment:** Native support for 64-bit addresses, directly mimicking the `bp_be_commit_pkt_s` struct.
* **Delta Filtering:** Combinational logic to suppress sequential PC updates (+4 bytes) and only trigger trace packets on pipeline discontinuities (branches/jumps).
* **Variable Length Encoding (VLE):** Hardware dynamic compression that detects small jumps and strips up to 56 bits of zeros, replacing 64-bit targets with 8-bit offsets.
* **Elastic Backpressure:** Parameterized circular FIFO ring-buffer utilizing `valid/ready/yumi` handshakes to prevent trace data loss during instruction traffic jams.
* **Nexus 5001 Packetization:** Outputs structured 80-bit packets (`MCODE`, `Source ID`, `Timestamp`, `Payload`).

## Simulation & Toolchain

The simulation environment has been migrated from event-driven testing to a cycle-accurate compiled C++ model using **Verilator**, matching industry-standard VLSI verification workflows.

### **1. Hardware Simulation (Verilator)**
Translates the SystemVerilog RTL into C++ and executes the cycle-accurate test vectors.
```bash
make all
