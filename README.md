# DLX Processor — Two-Stage Pipeline in SystemVerilog

## Overview

This project implements a 32-bit DLX processor using a simplified two-stage pipeline:
- **Stage 1 (Preprocessor)**: Decodes instructions and prepares ALU operands
- **Stage 2 (ALU)**: Executes arithmetic, logic, shift, and memory operations

The processor architecture and instruction behavior follow an enhanced version of the DLX ISA.

---

## Features

- **SystemVerilog RTL** design using:
  - `typedef`, `enum` for readable opcodes
  - Modular ALU components: arithmetic and shift units
  - `interface.sv` to connect DUT and testbench
- Two-stage pipeline: instruction preparation and execution
- Supports:
  - Arithmetic ops: ADD, SUB, HADD
  - Logic ops: AND, OR, XOR, NOT
  - Shifting: Logical/Arithmetic Left/Right
  - Memory access: LOADBYTE, LOADHALF, LOADWORD, etc.

---


