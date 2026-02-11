#include <stdio.h>

class bsg_zynq_pl {
public:
    bsg_zynq_pl(int argc, char **argv) {
        printf("[ZynqParrot] Initializing Virtual FPGA Driver...\n");
    }
};

int main(int argc, char **argv) {
    printf("========================================\n");
    printf("  GSoC 2026: ZynqParrot Trace Simulator \n");
    printf("  Student: R. Naga Arjun (VIT Chennai)  \n");
    printf("========================================\n");

    bsg_zynq_pl zpl(argc, argv);

    printf("[ZynqParrot] Simulation Driver Loaded Successfully.\n");
    return 0;
}
