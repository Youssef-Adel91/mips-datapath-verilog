# MIPS Datapath Implementation in Verilog

## 📌 Project Overview
[cite_start]This repository contains a structural and behavioral implementation of a single-cycle MIPS Datapath using Verilog[cite: 767, 769]. [cite_start]The project specifically focuses on designing the core Datapath components without the Control Unit[cite: 770]. [cite_start]Control signals are manually handled and assigned within the testbench to verify functionality[cite: 805, 806].

## ⚙️ Features & Supported Instructions
[cite_start]The datapath successfully executes three main types of MIPS instructions[cite: 809]:
* [cite_start]**Arithmetic & Logical:** `ADD`, `SUB`, `AND`, `OR`, `SLT` [cite: 810]
* [cite_start]**Load/Store:** `LW`, `SW` [cite: 812]
* [cite_start]**Branching:** `BEQ` [cite: 811]

## 🛠️ Components Implemented
* **ALU (Arithmetic Logic Unit):** Handles mathematical and bitwise operations.
* **Register File:** 32x32-bit registers for data storage and retrieval.
* [cite_start]**Instruction & Data Memories:** Stores instructions (preloaded) and handles memory read/write operations[cite: 813].
* **Multiplexers & Sign Extension:** Manages data routing and 16-to-32-bit sign extension.

## 🚀 How to Run and Test
[cite_start]Since the Control Unit is intentionally omitted, the simulation relies on a robust Testbench (`testbench.v`)[cite: 770, 772]. 

1. Clone the repository:
   ```bash
   git clone [https://github.com/yourusername/mips-datapath-verilog.git](https://github.com/yourusername/mips-datapath-verilog.git)
