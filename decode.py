#!/usr/bin/env python3

import os

print("========================================")
print(" ZynqParrot E-Trace Python Decoder")
print("========================================")

trace_file = "trace_output.hex"
if not os.path.exists(trace_file):
    print(f"Error: {trace_file} not found. Run simulation first!")
    exit(1)

current_pc = 0

with open(trace_file, 'r') as f:
    for line_num, line in enumerate(f):
        hex_str = line.strip()
        if not hex_str: continue
        
        # Convert the 80-bit hex string to an integer
        pkt = int(hex_str, 16)
        
        # Unpack the Nexus packet struct using bitwise shifts
        addr      = pkt & 0xFFFFFFFFFFFFFFFF         # Bottom 64 bits
        timestamp = (pkt >> 64) & 0xFF               # Next 8 bits
        src_id    = (pkt >> 72) & 0x03               # Next 2 bits
        mcode     = (pkt >> 74) & 0x3F               # Top 6 bits
        
        # Reconstruct the CPU Execution Path
        if mcode == 0x03: # DIRECT_BRANCH
            current_pc = addr
            print(f"Time +{timestamp:03d} cycles | [FULL JUMP]  CPU jumped to PC: 0x{current_pc:016x}")
            
        elif mcode == 0x09: # COMPRESSED
            current_pc = current_pc + addr
            print(f"Time +{timestamp:03d} cycles | [COMPRESSED] CPU stepped to PC: 0x{current_pc:016x} (Saved 56 bits of bandwidth!)")
            
        else:
            print(f"Time +{timestamp:03d} cycles | [ERROR] Unknown Packet MCODE: {mcode}")
