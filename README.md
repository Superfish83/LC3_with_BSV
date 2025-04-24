# LC-3 with Bluespec
## This project implements LC-3, a simple 16-bit computer architecture, with Bluespec(bsv).

**About LC-3: https://en.wikipedia.org/wiki/Little_Computer_3**

This is a project made for studying computer architecture.

Dept. of Computer Science and Engineering, Seoul National University  
Kim Yeonjun, Lim Junseo
{ kyjun0803@snu.ac.kr, zirajs@snu.ac.kr }

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

LC-3 is a von Neuman model machine. The instructions and data share the same memory space.
To run a program, write your LC-3 machine code at /programs/program.vmh, and then run the testbench simulation.

Currently supported instructions:
- add, and, not
- br(n,z,p), jsr, jmp
- ld, ldr, lea, st, str
- trap(x21, x25)