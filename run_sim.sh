#!/bin/bash
iverilog -g2012 \
  -I rtl \
  -o encoder_test \
  tb/tb_encoder.sv \
  rtl/bp_trace_encoder.sv \
  rtl/simple_fifo.sv \
  rtl/bp_nexus_defines.svh 

if [ $? -eq 0 ]; then
    echo "COMPILATION SUCCESS! Running Simulation..."
    ./encoder_test
else
    echo "COMPILATION FAILED"
fi
