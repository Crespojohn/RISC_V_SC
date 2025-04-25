# RISC_V_SC
Description:
RISC-V 32I computer arch FPGA implementation on a Basys3 FPGA

The reason I wanted to make this project was to give university student the capability to implement a RISC-V 32I CPU with a low cost and highly available FPGA. This project consists of a few files that allow the processor to function and to showcase the capabilities of the Basys3 FPGA. 

---

## Features

- Systemverilog hardware files that describe how the logic of the processor work at low and high levels
- Test benches for each Systemverilog file
- VGA controller to map BRAM to a display for 1-bit color
- Instruction Memory loader and controller that loads hex instructions to the FPGA via UART
- RISC-V assembler to convert RISC-V assembly to binary for users to see each attribute of an instruction
- Vivado2023.2 xpr.zip to open a project with all the generated IP's loaded and configured

---

## Installation

TBD
