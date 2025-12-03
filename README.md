# RISC-V CPU
RISC-V CPU design with a 6 stage pipeline, data forwarding, hazard detection and branch prediction. This project was done to improve my understanding of the RISC-V architecture and general computer architecture principles. 

Current Design of the CPU:
![alt text](https://github.com/dantonklein/RISC-V-CPU/blob/master/Danton_RISCV.png)

Roadmap (Things I will be implementing next): 
1. Exeception/Interrupt Handling (Ecall, Ebreak, Sret.wfi)
2. Multiplication/Division Extension (RV32M)
3. Floating Point Extension (RV32F)
4. Atomic Extension (RV32A)
5. Virtual Memory Compatibility and other associated memory stuff (Fence.i, Fence, Sfence.vma)
6. Upgrade the design to the priveledged implementation and include CSR instructions (Csrrw, Csrrs, Csrrc, Csrrwi, Csrrsi, Csrrci)

Resources Used:
* https://github.com/ARC-Lab-UF/sv-tutorial/tree/main
* Computer Organization and Design RISC-V Edition: The Hardware Software Interface (The Morgan Kaufmann Series in Computer Architecture and Design)
* https://five-embeddev.com/riscv-user-isa-manual/Priv-v1.12/instr-table.html
* https://www.youtube.com/watch?v=7QWcCDkIyn8




RISC V architecture design by Danton Klein, a MS ECE grad from The University of Florida
