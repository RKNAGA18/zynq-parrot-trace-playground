#!/usr/bin/env python3

import os
import sys

# Attempt to load pyelftools for real symbol resolution
try:
    from elftools.elf.elffile import ELFFile
    HAS_ELFTOOLS = True
except ImportError:
    HAS_ELFTOOLS = False

print("========================================")
print(" ZynqParrot E-Trace Python Validator")
print("========================================")

trace_file = "trace_output.hex"
if not os.path.exists(trace_file):
    print(f"Error: {trace_file} not found. Run simulation first!")
    sys.exit(1)

def load_symbols(elf_path):
    symbols = {}
    if not HAS_ELFTOOLS:
        print("[WARN] pyelftools not installed. Run 'pip install pyelftools' for ELF mapping.")
        return symbols
    try:
        with open(elf_path, 'rb') as f:
            elf = ELFFile(f)
            symtab = elf.get_section_by_name('.symtab')
            if symtab:
                for sym in symtab.iter_symbols():
                    if sym['st_info']['type'] == 'STT_FUNC':
                        symbols[sym['st_value']] = sym.name
    except Exception as e:
        print(f"[ERROR] Failed to load ELF: {e}")
    return symbols

# Load real symbols if an ELF file is passed as an argument
SYMBOL_TABLE = load_symbols(sys.argv[1]) if len(sys.argv) > 1 else {}

def get_symbol(pc):
    # Fallback mock for demonstration if no ELF is provided
    mock_table = {0x1000: "main()", 0x1010: "printf()", 0xffffffff80000000: "trap_vector()"}
    if not SYMBOL_TABLE and pc in mock_table: return mock_table[pc]
    return SYMBOL_TABLE.get(pc, "")

# Note: This decoder currently assumes a non-speculative committed trace stream.
# Rollbacks/Exceptions are flagged in bp_be_commit_pkt_s but require future integration.

current_pc = 0
total_bytes_raw = 0
total_bytes_vle = 0
event_count = 0

print(f"{'TIME':<10} | {'TYPE':<15} | {'PC (HEX)':<20} | {'FUNCTION SYMBOL'}")
print("-" * 70)

with open(trace_file, 'r') as f:
    for line in f:
        hex_str = line.strip()
        if not hex_str: continue
        
        pkt = int(hex_str, 16)
        addr      = pkt & 0xFFFFFFFFFFFFFFFF
        timestamp = (pkt >> 64) & 0xFF
        mcode     = (pkt >> 74) & 0x3F
        
        total_bytes_raw += 8 
        event_count += 1

        if mcode == 0x03: # DIRECT_BRANCH
            current_pc = addr
            total_bytes_vle += 8
            print(f"+{timestamp:03d} cyc   | [FULL JUMP]     | 0x{current_pc:016x} | {get_symbol(current_pc)}")
        elif mcode == 0x09: # COMPRESSED
            current_pc = current_pc + addr
            total_bytes_vle += 1
            print(f"+{timestamp:03d} cyc   | [COMPRESSED]    | 0x{current_pc:016x} | {get_symbol(current_pc)}")

print("-" * 70)
print("🎯 BANDWIDTH BENCHMARK RESULTS:")
print(f"Trace Events Processed: {event_count}")
if total_bytes_raw > 0:
    savings = ((total_bytes_raw - total_bytes_vle) / total_bytes_raw) * 100
    avg_bytes = total_bytes_vle / event_count
    print(f"Raw 64-bit Trace Size:  {total_bytes_raw} bytes")
    print(f"VLE Compressed Size:    {total_bytes_vle} bytes")
    print(f"Average Bytes/Event:    {avg_bytes:.2f} bytes")
    print(f"Total Bandwidth Saved:  {savings:.2f}%")
else:
    print("No events processed.")
