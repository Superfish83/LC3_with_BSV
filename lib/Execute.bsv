import LC3_Types::*;

function ExecResult execute(DecodedInst dInst, Data val1, Data val2, Addr pc);
    ExecResult eResult = ?;
    eResult.c2h = tagged Invalid;
    eResult.writeVal = tagged Invalid;
    eResult.memReq = tagged Invalid;
    eResult.dst = dInst.rd;
    eResult.addr = ?;
    
    case(dInst.opcode)
        // Arithmetic $ Logic Instructions
        opAdd: begin
            eResult.writeVal = tagged Valid ( val1 + (dInst.immFlag ? dInst.imm : val2) );
            //$display("source values: val1:%x, val2:%x", val1, val2);
        end
        opAnd: begin
            eResult.writeVal = tagged Valid ( val1 & (dInst.immFlag ? dInst.imm : val2) );
            //$display("source values: val1:%x, val2:%x", val1, val2);
        end
        opNot: begin
            eResult.writeVal = tagged Valid ( ~val1 );
            //$display("source values: val1:%x", val1);
        end

        // Control Instructions
        opBr: begin
            Bit#(3) nzp;
            nzp[0] = pack(val1 < 0);
            nzp[1] = pack(val1 == 0);
            nzp[2] = pack(val1 > 0);
            eResult.brTaken = ((nzp & dInst.rd) > 0);
            eResult.addr = (pc+1) + dInst.imm;
            eResult.writeVal = tagged Invalid;
        end

        opJmp: begin
            eResult.addr = val1;
        end

        opJsr: begin
            case(dInst.immFlag)
                True: eResult.addr = ((pc+1)+dInst.imm);
                False: eResult.addr = val1;
            endcase
            eResult.brTaken = True;
            eResult.writeVal = tagged Valid (pc + 1);
        end

        opTrap: begin
            case(dInst.imm[7:0])
                tvOut:  eResult.c2h = tagged Valid CpuToHost {c2hType: TV_OUT, data: val1};
                tvHalt: eResult.c2h = tagged Valid CpuToHost {c2hType: TV_HALT, data: ?};
            endcase
        end

        // Load & Store Instructions
        opLea: eResult.writeVal = tagged Valid ((pc+1) + dInst.imm);
        opLd: eResult.memReq = tagged Valid MemRequest 
                { writeMem: False, addr: ((pc+1) + dInst.imm), data: ?  };
        opLdr: eResult.memReq = tagged Valid MemRequest 
                { writeMem: False, addr: (val2 + dInst.imm), data: ?  };
        opSt: eResult.memReq = tagged Valid MemRequest 
                { writeMem: True,  addr: ((pc+1) + dInst.imm), data: val1  };
        opStr: eResult.memReq = tagged Valid MemRequest 
                { writeMem: True,  addr: (val2 + dInst.imm), data: val1  };

        // TODO: Implement LDI, STI

    endcase

    return eResult;
endfunction