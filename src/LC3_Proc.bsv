/*
    Proc.bsv: The LC-3 Processor
*/

package LC3_Proc;

import IMemory::*;
import RFile::*;
import LC3_ProcTypes::*;
import Decode::*;
import Execute::*;


interface LC3_Proc;
    method Action hostToCpu(Addr startAddr);
    method ActionValue#(CpuToHost) cpuToHost;
endinterface: LC3_Proc

(* synthesize *)
module mkLC3_Proc(LC3_Proc);
    Reg#(Bool)      running <- mkReg(False);
    Reg#(Addr)      pc      <- mkRegU;
    IMemory         iMem    <- mkIMemoryF("../programs/program.vmh");
    RFile           rFile   <- mkRFile();
    /* DMemory      dMem    <- mkDMemory;*/

    Reg#(CpuToHost) c2h     <- mkReg(CpuToHost { c2hType: NO_SIGNAL, data: ? });

    rule doProc (running);
        // (1)  Fetch
        let inst = iMem.req(pc);

        // DEBUG: Check memory value at pc
        $display("Mem[pc=x%x]: %b", pc, iMem.req(pc));

        // (2)  Decode
        DecodedInst dInst = decode(inst, pc);
        //      Read source registers
        dInst.val1 = isValid(dInst.rs1) ?
            tagged Valid rFile.read1(fromMaybe(?, dInst.rs1)) :
            tagged Invalid;
        dInst.val2 = isValid(dInst.rs2) ?
            tagged Valid rFile.read2(fromMaybe(?, dInst.rs2)) :
            dInst.val3;

        // (3)  Execute
        let execResult = execute(dInst);
        c2h <= execResult.c2h;

        // (5)  Write back
        if(isValid(execResult.writeVal)) begin
            rFile.write(fromMaybe(?, dInst.rd), fromMaybe(?, execResult.writeVal));
        end

        // (6)  Update PC
        pc <= pc + 1;
    endrule

    method Action hostToCpu(Addr startAddr) if (!running);
        pc <= startAddr;
        running <= True;
    endmethod
    method ActionValue#(CpuToHost) cpuToHost();
        return c2h;
    endmethod
endmodule: mkLC3_Proc

endpackage: LC3_Proc