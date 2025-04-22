/** 
 * Dmemory.bsv 
 * 
 * This file provides an interface for the Data Memory (DMem).
 * [Note] This implementation is NOT how real memory devices(DRAMs) are made,
 *        but is a mere imitation with a large RegFile. (only for simulation)
 *
 */

package DMemory;

import RegFile :: * ;
import LC3_Types::*;

interface DMemory;
    method ActionValue#(MemResponse) req(MemRequest reqData);
endinterface

module mkDMemFromFile#(parameter String file_name)(DMemory);
    RegFile#(Addr, Data) mem <- mkRegFileLoad(file_name, lc3_DMem_ORIG, lc3_DMem_END);

    method ActionValue#(MemResponse) req(MemRequest reqData);
        if(reqData.writeMem) mem.upd(reqData.addr, reqData.data);
        return MemResponse {
            data: (reqData.writeMem ? 0 : mem.sub(reqData.addr))
        };
    endmethod
endmodule: mkDMemFromFile

(* synthesize *)
// Make Memory File from vmh file, following LC-3 memory conventions
module mkDMemoryF#(parameter String file_name)(DMemory);
    DMemory dMem <- mkDMemFromFile(file_name);

    method ActionValue#(MemResponse) req(MemRequest reqData);
        let res <- dMem.req(reqData);
        return res;
    endmethod

endmodule: mkDMemoryF

endpackage: DMemory