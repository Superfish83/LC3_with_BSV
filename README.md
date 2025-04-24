# LC-3 with Bluespec
## This project implements LC-3, a simple 16-bit computer architecture, with Bluespec(bsv).

**About LC-3: https://en.wikipedia.org/wiki/Little_Computer_3**

This is a project made for studying computer architecture.

Dept. of Computer Science and Engineering, Seoul National University. 
Kim Yeonjun, Lim Junseo {kyjun0803@snu.ac.kr, zirajs@snu.ac.kr}

## Requirements

To compile and test our LC-3 implementation, you need to have the Bluespec compiler (bsc) installed on your machine.

https://github.com/B-Lang-org/bsc

You may refer to the installation guide on our blog.

- https://blog.yeonjun.kr/post/44 (English)
- https://blog.yeonjun.kr/post/43 (Korean)

## How to build the processor and testbench

    $ bash build.sh sim         -> Build for simulation
    $ bash build.sh verilog     -> Compile to Verilog files

  
## How to run testbench simulation


    $ bash build.sh run

  
## Running a program

LC-3 is based on the Neumann model. The instructions and data(stack and global variables) share the same memory space.

To run a program, write your LC-3 machine code at */programs/program.vmh*, and then run the testbench simulation. To feed user input into the program, you should write your input data at */programs/input.dat*. The LC-3 system call for input (TRAP x20 or TRAP x23) will read the file one character at a time, and store it at register r0.


Supported LC-3 instructions in this implementation:
- ADD, AND, NOT
- BR, JMP, JSR
- LD, LDR, LEA, ST, STR
- TRAP x20, x21, x22, x25

STI, LDI and TRAP x23 (PUTS) are currently not supported.