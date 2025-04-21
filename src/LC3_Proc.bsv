/*
    Proc.bsv: The LC-3 Processor
*/

package LC3_Proc;

import IMemory :: *;
import LC3_ProcTypes::*;


function DecodedInst decodeInst(Bit#(16) inst, Addr pc);
    let opcode  = inst[15:12];
    let rd      = inst[11:9];
    let rs1     = inst[8:6];
    let offset  = inst[5:0];

    let immFlag = inst[5];
    let imm5    = inst[4:0];
    let rs2     = inst[2:0];

    // Decode result (initially undefined)
    DecodedInst dInst = ?;
    case(opcode)
        opAdd: begin
            // ...
        end
        default: begin
            // ...
        end
    endcase

    return dInst;
endfunction



interface LC3_Proc;
    method Action hostToCpu(Addr startAddr);
    method ActionValue#(CpuToHost) cpuToHost;
endinterface: LC3_Proc


(* synthesize *)
module mkLC3_Proc(LC3_Proc);
    Reg#(Bool)      running <- mkReg(False);
    Reg#(Addr)      pc      <- mkRegU;
    IMemory         iMem    <- mkIMemoryF("../sample_programs/add.vmh");
    /*
    RFile       rf <- mkRFile;
    DMemory     dMem <- mkDMemory;*/

    rule doProc (running);
        let inst = iMem.req(pc);
        // check imem
        $display("mem: %b", iMem.req(pc));
        /*
        let dInst = decodeInst(inst, pc);
        let rVal1 = rf.rd1(dInst.src1);
        let rVal2 = rf.rd2(dInst.src2);
        let eInst = exec(dInst, rVal1, rVal2, pc);
        */
        pc <= pc + 1;
    endrule

    method Action hostToCpu(Addr startAddr) if (!running);
        pc <= startAddr;
        running <= True;
    endmethod
    method ActionValue#(CpuToHost) cpuToHost();
        if (pc < 'h3012) begin
            CpuToHost c2h = ?;
            c2h.c2hType = PrintHex;
            c2h.data = pc;
            return c2h;
        end
        else begin
            CpuToHost c2h = ?;
            c2h.c2hType = ExitCode;
            return c2h;
        end 
    endmethod
endmodule: mkLC3_Proc

endpackage: LC3_Proc