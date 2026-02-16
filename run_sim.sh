#!/bin/bash

# Compile all files: Testbench + Encoder + FIFO + Dictionaries
iverilog -g2012 \
  -I rtl \
  -o encoder_test \
  tb/tb_encoder.sv \
  rtl/bp_trace_encoder.sv \
  rtl/simple_fifo.sv

# Check if compilation succeeded
if [ $? -eq 0 ]; then
    echo "--------------------------------------------------------"
    echo "   COMPILATION SUCCESS!  (Running Simulation...)"
    echo "--------------------------------------------------------"
    ./encoder_test
else
    echo "COMPILATION FAILED"
fi
