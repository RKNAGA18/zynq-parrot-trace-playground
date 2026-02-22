#include "Vtb_encoder.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true); // Enable waveform dumping

    // Instantiate the compiled Verilog module
    Vtb_encoder* top = new Vtb_encoder;
    
    // Setup VCD dumping
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("encoder_test.vcd");

    int time = 0;
    // Run the simulation until $finish is called or timeout
    while (!Verilated::gotFinish() && time < 100) {
        top->clk = time % 2; // Toggle clock (0, 1, 0, 1...)
        top->eval();         // Evaluate the Verilog logic
        tfp->dump(time);     // Write to waveform
        time++;
    }

    top->final();
    tfp->close();
    delete top;
    delete tfp;
    return 0;
}
