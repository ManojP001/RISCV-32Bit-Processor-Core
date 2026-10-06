# 32-Bit RISC-V (RV32I) Processor Core

A synthesizable, single-cycle 32-bit RISC-V processor core designed and implemented in **Verilog HDL (IEEE 1364)**. Implements the RV32I base integer instruction subset with full architectural support for arithmetic, logical, immediate, memory, and conditional branch operations.

---

## 🏛️ Micro-Architecture & Datapath Overview

The core implements a classic Harvard-style micro-architecture with independent instruction fetch and data execution paths:

```text
 ┌────────────┐     pc      ┌────────────────────┐  instruction  ┌──────────────┐
 │     PC     │────────────►│       IMEM         │──────────────►│   CONTROL    │
 │ (Register) │             │ (Instruction ROM)  │               │    UNIT      │
 └─────▲──────┘             └────────────────────┘               └──────┬───────┘
       │                                                                │ control
       │                            instruction[19:15] = rs1            │ signals
       │                            instruction[24:20] = rs2            │
       │                            instruction[11:7]  = rd             ▼
       │                            ┌─────────────────────┐       ┌───────────┐
       │                            │    REGISTER FILE    │──────►│    ALU    │
       │                            │  (Outputs r_data1,  │       │(Calculator│
       │                            │          r_data2)   │       └─────┬─────┘
       │                            └─────────────────────┘             │
       │                                                                │ alu_result
       │                       Next PC = PC + 4                         ▼
       └─────────────────────────────────────────────────────── Write back to
                                                               Register File (rd)!
```

---

## 📁 Repository Structure

```text
├── rtl/
│   ├── program_counter.v      # 32-bit Program Counter register with async reset
│   ├── instruction_memory.v   # ROM block holding program machine code
│   ├── register_file.v        # 32x32-bit dual-read, single-write Register File (x0 hardwired to 0)
│   ├── alu.v                  # 32-bit Arithmetic Logic Unit with zero-flag branch evaluation
│   ├── imm_gen.v              # Immediate Generator with 32-bit sign extension (I, S, B-types)
│   ├── control_unit.v         # Main Control Unit decoding 7-bit opcodes into control signals
│   └── riscv_core.v           # Top-level processor core integrating datapath and control
├── tb/
│   └── tb_riscv_core.v        # Directed self-checking verification testbench
└── README.md                  # Project documentation
```

---

## ⚙️ Key Architectural Features

1. **Dedicated Program Counter (`program_counter.v`):**
   - Implements sequential $+4$ byte-aligned instruction pointer progression.
   - Active-low asynchronous reset to `0x00000000`.

2. **Dual-Read Register File (`register_file.v`):**
   - 32 general-purpose 32-bit registers (`x0` through `x31`).
   - Register `x0` is permanently hardwired to `32'h00000000` (reads return zero, writes are ignored).
   - Dual asynchronous read ports enable 0-cycle operand fetches for single-cycle execution.

3. **Immediate Generator & Sign Extender (`imm_gen.v`):**
   - Unpacks and sign-extends 12-bit and 13-bit literals across I-type (`ADDI`, `LW`), S-type (`SW`), and B-type (`BEQ`) instructions into full 32-bit operands.

4. **32-Bit Arithmetic Logic Unit (`alu.v`):**
   - Supports 8 core operations: `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SLT`.
   - Generates dedicated `zero_flag` for conditional branch evaluation.

5. **Centralized Control Unit (`control_unit.v`):**
   - 100% latch-free combinational decoder setting micro-architectural control lines (`reg_write`, `alu_src`, `mem_write`, `mem_to_reg`, `branch`).

---

## 📋 Supported Instruction Set (RV32I Subset)

| Type | Instruction | Opcode | Description |
|:---:|:---:|:---:|:---|
| **R-Type** | `ADD`, `SUB` | `7'b0110011` | Register-to-register arithmetic addition / subtraction |
| **R-Type** | `AND`, `OR`, `XOR` | `7'b0110011` | Bitwise logical operations |
| **R-Type** | `SLL`, `SRL`, `SLT` | `7'b0110011` | Logical shifts and set-less-than signed comparison |
| **I-Type** | `ADDI` | `7'b0010011` | Add immediate constant to register |
| **I-Type** | `LW` | `7'b0000011` | Load word from data memory into register |
| **S-Type** | `SW` | `7'b0100011` | Store word from register to data memory |
| **B-Type** | `BEQ` | `7'b1100011` | Branch to target address if source registers are equal |

---

## 🧪 Verification & Simulation

The core is verified using a directed testbench (`tb_riscv_core.v`) executing an assembled sequence:
```assembly
ADDI x1, x0, 5    # Load 5 into Register x1
ADDI x2, x0, 10   # Load 10 into Register x2
ADD  x3, x1, x2   # x3 = x1 + x2 (5 + 10 = 15)
```

The testbench dynamically asserts register `x3 == 32'd15` on cycle completion, confirming correct instruction decode, register file read/write, ALU computation, and writeback datapath connectivity.

---

## 🛠️ Tools & Technologies
- **HDL:** Verilog (IEEE 1364)
- **Simulation:** Icarus Verilog (`iverilog`), ModelSim / QuestaSim, EDAPlayground
- **Waveform Viewer:** GTKWave

---

## 👤 Author
**Manoj Pattanshetty**  
*VLSI RTL Design & Verification Engineer*  
Bangalore, India | [LinkedIn Profile](https://linkedin.com/)
