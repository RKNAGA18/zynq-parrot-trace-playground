#include <iostream>
#include <fstream>
#include <string>
#include <cstdint>
#include <iomanip>

using namespace std;

// C++ Stub for ZynqParrot Trace Driver
// Parses 80-bit Nexus packets from the RTL simulation

int main() {
    ifstream file("trace_output.hex");
    if (!file.is_open()) {
        cerr << "Error: trace_output.hex not found!" << endl;
        return 1;
    }

    cout << "========================================" << endl;
    cout << " ZynqParrot C++ Trace Driver (Stub)" << endl;
    cout << "========================================" << endl;

    string hex_str;
    uint64_t current_pc = 0;

    while (file >> hex_str) {
        // Pad to 20 hex characters (80 bits) if necessary
        while (hex_str.length() < 20) hex_str = "0" + hex_str;

        // Split the 80-bit string into upper 16 bits and lower 64 bits
        string upper_hex = hex_str.substr(0, 4);
        string lower_hex = hex_str.substr(4, 16);

        uint32_t upper_bits = stoul(upper_hex, nullptr, 16);
        uint64_t addr = stoull(lower_hex, nullptr, 16);

        uint8_t timestamp = upper_bits & 0xFF;
        uint8_t mcode = (upper_bits >> 10) & 0x3F;

        if (mcode == 0x03) { // DIRECT_BRANCH
            current_pc = addr;
            cout << "+ " << setw(3) << setfill('0') << (int)timestamp 
                 << " cyc | [FULL JUMP]  PC: 0x" << hex << current_pc << dec << endl;
        } 
        else if (mcode == 0x09) { // COMPRESSED
            current_pc += addr;
            cout << "+ " << setw(3) << setfill('0') << (int)timestamp 
                 << " cyc | [COMPRESSED] PC: 0x" << hex << current_pc << dec << endl;
        }
    }
    file.close();
    return 0;
}
