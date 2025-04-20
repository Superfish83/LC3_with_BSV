/** 
 * Imemory.bsv 
 * 
 * This file provides support for Instruction memory of the cpu.
 * 
 * example usage:
 * module mkTb();
 *   IMemory iMem <- mkIMemory;
 *   ...
 *   rule doTb;
 *     let inst = iMem.req(pc);
 *     ...
 *   endrule;
 * endmodule;
 * 
 * initialization:  // TODO
 *  - iMem.load("file_name")
 * 
 */
 
package IMemory;

import RegFile :: * ;
import LC3_ProcTypes::*;

interface IMemory;
    method Inst req(Addr pc);
endinterface

module mkLC3IMemeory(IMemory);
    // x3000 - xFDFF
    RegFile#(Addr, Inst) mem <- mkRegFile(lc3_ORIG, lc3_END);

    method Inst req(Addr pc);
        return mem.sub(pc);
    endmethod

endmodule: mkLC3IMemeory

module mkLC3IMemeoryFile#(parameter String file_name)(IMemory);
    // x3000 - xFDFF
    RegFile#(Addr, Inst) mem <- mkRegFileLoad(file_name, lc3_ORIG, lc3_END);

    method Inst req(Addr pc);
        return mem.sub(pc);
    endmethod
endmodule: mkLC3IMemeoryFile


module mkIMemory(IMemory);
    IMemory iMem <- mkLC3IMemeory;

    method Inst req(Addr pc);
        return iMem.req(pc);
    endmethod

endmodule: mkIMemory

(* synthesize *)
module mkIMemoryF#(parameter String file_name)(IMemory);
    IMemory iMem <- mkLC3IMemeoryFile(file_name);

    method Inst req(Addr pc);
        return iMem.req(pc);
    endmethod

endmodule: mkIMemoryF

endpackage: IMemory