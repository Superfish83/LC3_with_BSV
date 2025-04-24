import LC3_Types::*;

function ExecResult execute(DecodedInst dInst, Data val1, Data val2, Bit#(3) nzp, Addr pc);
    ExecResult eResult = ?;
    eResult.c2h = tagged Invalid;
    eResult.writeVal = tagged Invalid;
    eResult.memReq = tagged Invalid;
    eResult.dst = dInst.rd;
    eResult.addr = pc+1;
    
    case(dInst.opcode)
        // Arithmetic $ Logic Instructions
        opAdd: eResult.writeVal = tagged Valid ( val1 + (dInst.immFlag ? dInst.imm : val2) );
        opAnd: eResult.writeVal = tagged Valid ( val1 & (dInst.immFlag ? dInst.imm : val2) );
        opNot: eResult.writeVal = tagged Valid ( ~val1 );

        // Control Instructions
        opBr: begin
            let brTaken = ((nzp & dInst.rd) != 0);  // check branching condition
            eResult.addr = (pc+1) + (brTaken ? dInst.imm : 0);
            eResult.writeVal = tagged Invalid;  // mark invalid
        end

        opJmp: begin
            eResult.addr = val1;
        end

        opJsr: begin
            case(dInst.immFlag) // check the condition for jsr and jsrr
                True: eResult.addr = ((pc+1)+dInst.imm);  // jsr
                False: eResult.addr = val1;  // jsrr
            endcase
            eResult.brTaken = True;
            eResult.writeVal = tagged Valid (pc + 1);
        end

        opTrap: begin
            case(dInst.imm[7:0])
                tvIn:   eResult.c2h = tagged Valid CpuToHost {c2hType: TV_IN, data: ?};
                tvOut:  eResult.c2h = tagged Valid CpuToHost {c2hType: TV_OUT, data: val1};
                tvGetc: eResult.c2h = tagged Valid CpuToHost {c2hType: TV_GETC, data: ?};
                tvHalt: eResult.c2h = tagged Valid CpuToHost {c2hType: TV_HALT, data: ?};
            endcase
        end

        // Load & Store Instructions 
        opLea: eResult.writeVal = tagged Valid ((pc+1) + dInst.imm);
        opLd: eResult.memReq = tagged Valid MemRequest 
                { writeMem: False, addr: ((pc+1) + dInst.imm), data: ?  };
        opLdr: eResult.memReq = tagged Valid MemRequest 
                { writeMem: False, addr: (val1 + dInst.imm), data: ?  };
        opSt: eResult.memReq = tagged Valid MemRequest 
                { writeMem: True,  addr: ((pc+1) + dInst.imm), data: val2  };
        opStr: eResult.memReq = tagged Valid MemRequest 
                { writeMem: True,  addr: (val1 + dInst.imm), data: val2  };

        // TODO: Implement LDI, STI

    endcase

    return eResult;
endfunction