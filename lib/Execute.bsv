import LC3_Types::*;

function ExecResult execute(DecodedInst dInst, Data val1, Data val2);
    Maybe#(CpuToHost) c2h = tagged Invalid;
    Maybe#(Data) writeVal = tagged Invalid;
    Maybe#(MemRequest) memReq = tagged Invalid;
    
    case(dInst.opcode)
        // Arithmetic $ Logic Instructions
        opAdd: begin
            writeVal = tagged Valid ( val1 + (dInst.immFlag ? dInst.imm : val2) );
            //$display("source values: val1:%x, val2:%x", val1, val2);
        end
        opAnd: begin
            writeVal = tagged Valid ( val1 & (dInst.immFlag ? dInst.imm : val2) );
            //$display("source values: val1:%x, val2:%x", val1, val2);
        end
        opNot: begin
            writeVal = tagged Valid ( ~val1 );
            //$display("source values: val1:%x", val1);
        end

        // Control Instructions
        opTrap: begin
            case(dInst.imm[7:0])
                tvOut:  c2h = tagged Valid CpuToHost {c2hType: TV_OUT, data: val1};
                tvHalt: c2h = tagged Valid CpuToHost {c2hType: TV_HALT, data: ?};
            endcase
        end

        // Load & Store Instructions
        opLea: writeVal = tagged Valid dInst.imm;
        opLd: memReq = tagged Valid MemRequest 
                { writeMem: False, addr: dInst.imm, data: ?  };
        opLdr: memReq = tagged Valid MemRequest 
                { writeMem: False, addr: val1 + dInst.imm, data: ?  };
        opSt: memReq = tagged Valid MemRequest 
                { writeMem: True,  addr: dInst.imm, data: val2  };
        opStr: memReq = tagged Valid MemRequest 
                { writeMem: True,  addr: val1 + dInst.imm, data: val2  };

    endcase

    return ExecResult {c2h: c2h, writeVal: writeVal, memReq: memReq};
endfunction