# 64-bit Single-Cycle CPU (Verilog)

This repository contains the complete design, verification, and documentation for a **64-bit single-cycle CPU** implemented in **Verilog**, developed as a final project for an Advanced Processor Systems / Computer Architecture course.

The processor follows a **MIPS-like single-cycle datapath** and includes a fully structural adder hierarchy, behavioral ALU extensions, complete control logic, memory subsystems, and exhaustive module-level and system-level verification.

---

## 📐 Architecture Overview

The CPU is a **single-cycle design**, meaning each instruction completes in one clock cycle. The datapath includes:

- Program Counter (PC)
- Instruction Memory
- Control Unit
- Register File (32 × 64-bit)
- ALU (Add, Sub, Logic, Mul, Div)
- Data Memory
- Branch Comparator
- Sign Extension, Shifter, and Multiplexers

Arithmetic and control are coordinated by a centralized control unit decoding instruction opcode and function fields.

---

## 🔧 Key Design Features

### Structural Adder Hierarchy
The ALU adder is built **bottom-up**, strictly following structural modeling:
- Half Adder
- 1-bit Full Adder
- 4-bit Ripple-Carry Adder
- 16-bit Adder
- 32-bit Adder
- 64-bit Adder

### Subtractor
Implemented using two’s complement:
```
A − B = A + (~B + 1)
```
The subtractor reuses the structural 64-bit adder.

### Multiplier and Divider
- Implemented as **behavioral single-cycle units**
- Signed arithmetic using Verilog `*`, `/`, and `%`
- Full 128-bit product support for multiplication
- Divide-by-zero detection for division

### Register File
- 32 registers × 64-bit
- Synchronous write, asynchronous read
- Register x0 is hardwired to zero
- No bypass or forwarding logic

---

## 🧪 Verification Strategy

Every module in the design is independently verified using a dedicated testbench.

### Module-Level Testbenches
- Half adder, full adder, adders (4/16/32/64)
- Subtractor
- Logic unit
- Multiplier
- Divider
- ALU
- Register file
- Instruction memory
- Data memory
- Control unit
- Sign extension
- Shifter
- Multiplexers
- Program counter
- Branch comparator

### System-Level Verification
A top-level CPU testbench executes an assigned arithmetic expression step-by-step, demonstrating:
- Instruction fetch
- Decode
- Execute
- Memory access
- Write-back

Final results are validated against expected memory values.

---

## 📂 Repository Structure

```
.
├── src/                # Verilog RTL modules
├── tb/                 # Testbenches for every module
├── hex/                # Instruction and data memory initialization files
└── README.md
```

---

## ▶️ How to Run (Vivado)

1. Create a new Vivado project
2. Add all files under `src/` as design sources
3. Add all files under `tb/` as simulation sources
4. Set the desired testbench as the simulation top
5. Run behavioral simulation
6. Inspect waveforms and console output

For full CPU execution, set `tb_CPU.v` as the simulation top.

---

## 🛠 Tools Used

- **Vivado Design Suite**
- **Verilog HDL**
- **GTKWave / Vivado Waveform Viewer**
- **Git & GitHub**

---
