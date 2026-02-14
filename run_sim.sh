#!/bin/bash

# Simple Compile - No weird folders needed anymore
iverilog -g2012 \
  -I rtl \
  -o sim_encoder \
  tb/tb_encoder.sv rtl/bp_trace_encoder.sv

# Run
if [ -f sim_encoder ]; then
    ./sim_encoder
else
    echo "Failed."
fi
