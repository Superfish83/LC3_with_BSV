/*
    LC3_Proc.bsv: The LC-3 ISA Processor
*/

package LC3_Proc;

import LC3_Types::*;
import IMemory::*;
import DMemory::*;
import RFile::*;
import Decode::*;
import Execute::*;


interface LC3_Proc;
    method Action hostToCpu(Addr startAddr);
    method ActionValue#(Maybe#(CpuToHost)) cpuToHost;
endinterface: LC3_Proc

(* synthesize *)
module mkLC3_Proc(LC3_Proc);
    Reg#(Bool)      running <- mkReg(False);
    Reg#(Addr)      pc      <- mkRegU;
    IMemory         iMem    <- mkIMemoryF("../programs/program.vmh");
    DMemory         dMem    <- mkDMemoryF("../programs/progrma.vmh");
    RFile           rFile   <- mkRFile();

    Reg#(Maybe#(CpuToHost)) c2h <- mkReg(tagged Invalid);

    rule doProc (running);
        // (1)  Fetch
        let inst = iMem.req(pc);

        // DEBUG: Check memory value at pc
        $display("Mem[pc=x%x]: %b", pc, iMem.req(pc));

        // (2)  Decode - decode
        DecodedInst dInst = ?;
        dInst = decode(inst);
        // (2)  Decode - fetch registers
        let val1 = rFile.read1(dInst.rs1);
        let val2 = rFile.read2(dInst.rs2);

        // (3)  Execute
        let eResult = execute(dInst, val1, val2, pc);
        c2h <= eResult.c2h;

        // (4)  Memory operation
        if(isValid(eResult.memReq)) begin
            let memReq = fromMaybe(?, eResult.memReq);
            let res <- dMem.req(memReq);
            if(!memReq.writeMem) eResult.writeVal = tagged Valid res.data;
        end

        // (5)  Write back
        if(isValid(eResult.writeVal)) begin
            rFile.write(dInst.rd, fromMaybe(?, eResult.writeVal));
        end

        // (6)  Update PC
        pc <= pc + 1;
    endrule

    method Action hostToCpu(Addr startAddr) if (!running);
        pc <= startAddr;
        running <= True;
    endmethod
    method ActionValue#(Maybe#(CpuToHost)) cpuToHost();
        return c2h;
    endmethod
endmodule: mkLC3_Proc

endpackage: LC3_Proc