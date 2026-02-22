#!/bin/bash
set -e # Exit immediately if a command fails

echo "======================================"
echo " Starting Verilator C++ Compilation..."
echo "======================================"

# Added rtl/simple_fifo.sv to the compilation list!
verilator --cc --exe --trace -Wno-fatal -Irtl --top-module tb_encoder rtl/bp_trace_encoder.sv rtl/simple_fifo.sv tb/tb_encoder.sv tb/sim_main.cpp

make -j -C obj_dir -f Vtb_encoder.mk Vtb_encoder

echo "======================================"
echo " Compilation Success! Running Binary..."
echo "======================================"

./obj_dir/Vtb_encoder
