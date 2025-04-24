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
    method Action hostToCpu(Maybe#(Addr) startAddr, Maybe#(Data) sysIn);
    method ActionValue#(Maybe#(CpuToHost)) cpuToHost;
endinterface: LC3_Proc

(* synthesize *)
module mkLC3_Proc#(parameter String program_path, parameter String input_path,
                    parameter Bool debugMode)(LC3_Proc);
    Reg#(Bool)      running <- mkReg(False);
    Reg#(Addr)      pc      <- mkRegU;
    Reg#(Bit#(3))   nzp     <- mkReg(0);
    IMemory         iMem    <- mkIMemoryF(program_path);
    DMemory         dMem    <- mkDMemoryF(program_path);
    RFile           rFile   <- mkRFile();

    Reg#(Maybe#(CpuToHost)) c2h <- mkReg(tagged Invalid);

    rule doProc (running);
        // (1)  Fetch
        let inst = iMem.req(pc);

        // DEBUG: Check memory value at pc
        if(debugMode) $display("Mem[pc=x%x]: %b", pc, iMem.req(pc));

        // (2)  Decode - decode
        DecodedInst dInst = ?;
        dInst = decode(inst);
        // (2)  Decode - fetch registers
        let val1 = rFile.read1(dInst.rs1);
        let val2 = rFile.read2(dInst.rs2);

        // (3)  Execute
        let eResult = execute(dInst, val1, val2, nzp, pc);
        c2h <= eResult.c2h;
        if(isValid(eResult.c2h)) begin
            case(fromMaybe(?, eResult.c2h).c2hType)
                TV_IN, TV_GETC, TV_HALT: running <= False;
            endcase
        end

        // (4)  Memory operation
        if(isValid(eResult.memReq)) begin
            let memReq = fromMaybe(?, eResult.memReq);
            let res <- dMem.req(memReq);
            if(!memReq.writeMem) eResult.writeVal = tagged Valid res.data;
        end

        // (5)  Write back
        if(isValid(eResult.writeVal)) begin
            let wVal = fromMaybe(?, eResult.writeVal);
            rFile.write(dInst.rd, wVal);
            // update NZP flag
            if(wVal < 0)    nzp <= 3'b100;
            if(wVal == 0)   nzp <= 3'b010;
            if(wVal > 0)    nzp <= 3'b001;
        end

        // (6)  Update PC
        pc <= eResult.addr;
    endrule

    method Action hostToCpu(Maybe#(Addr) startAddr, Maybe#(Data) sysIn) if (!running);
        if (isValid(startAddr)) pc <= fromMaybe(?, startAddr);
        if (isValid(sysIn)) rFile.write(pack(3'b000), fromMaybe(?, sysIn));
        c2h <= tagged Invalid;
        running <= True;
    endmethod
    method ActionValue#(Maybe#(CpuToHost)) cpuToHost();
        return c2h;
    endmethod
endmodule: mkLC3_Proc

endpackage: LC3_Proc