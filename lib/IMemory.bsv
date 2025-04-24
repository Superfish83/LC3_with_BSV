/** 
 * Imemory.bsv 
 * 
 * This file provides an interface for the Instruction Memory (IMem).
 * [Note] This implementation is NOT how real memory devices(DRAMs) are made,
 *        but is a mere imitation with a large RegFile. (only for simulation)
 *
 */
 
package IMemory;

import RegFile::*;
import LC3_Types::*;
// import MemoryTypes::*;  TODO: Add type definitions?

interface IMemory;
    method Inst req(Addr pc);
endinterface

module mkIMemFromFile#(parameter String file_name)(IMemory);
    RegFile#(Addr, Inst) mem <- mkRegFileLoad(file_name, lc3_IMem_ORIG, lc3_IMem_END);

    method Inst req(Addr pc);
        return mem.sub(pc);
    endmethod
endmodule: mkIMemFromFile

// Dummy memory module (for circuit synthesis)
module mkIMemDummy#(parameter String file_name)(IMemory);
    method Inst req(Addr reqData);
        Inst res = ?;
        return res;
    endmethod
endmodule: mkIMemDummy

(* synthesize *)
// Make Memory File from vmh file, following LC-3 memory conventions
module mkIMemoryF#(parameter String file_name)(IMemory);
    IMemory iMem <- mkIMemFromFile(file_name);
    //IMemory iMem <- mkIMemDummy(file_name);

    method Inst req(Addr pc);
        return iMem.req(pc);
    endmethod

endmodule: mkIMemoryF

endpackage: IMemory