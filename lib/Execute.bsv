import LC3_Types::*;

function ExecResult execute(DecodedInst dInst);
    Maybe#(CpuToHost) c2h = tagged Invalid;
    Maybe#(Data) writeVal = tagged Invalid;
    Maybe#(MemRequest) memReq = tagged Invalid;
    
    case(dInst.opcode)
        // Arithmetic $ Logic Instructions
        opAdd: begin
            writeVal = tagged Valid ( dInst.val1 + (dInst.immFlag ? dInst.val3 : dInst.val2) );
            //$display("source values: val1:%x, val2:%x", val1, val2);
        end
        opAnd: begin
            writeVal = tagged Valid ( dInst.val1 & (dInst.immFlag ? dInst.val3 : dInst.val2) );
            //$display("source values: val1:%x, val2:%x", val1, val2);
        end
        opNot: begin
            writeVal = tagged Valid ( ~dInst.val1 );
            //$display("source values: val1:%x", val1);
        end

        // Control Instructions
        opTrap: begin
            case(dInst.val3[7:0])
                tvOut:  c2h = tagged Valid CpuToHost {c2hType: TV_OUT, data: dInst.val1};
                tvHalt: c2h = tagged Valid CpuToHost {c2hType: TV_HALT, data: ?};
            endcase
        end

        // Load & Store Instructions
        opLea: writeVal = tagged Valid dInst.val3;
        opLd: memReq = tagged Valid MemRequest 
                { writeMem: False, addr: dInst.val3, data: ?  };
        opLdr: memReq = tagged Valid MemRequest 
                { writeMem: False, addr: dInst.val1 + dInst.val3, data: ?  };
        opSt: memReq = tagged Valid MemRequest 
                { writeMem: True,  addr: dInst.val3, data: dInst.val2  };
        opStr: memReq = tagged Valid MemRequest 
                { writeMem: True,  addr: dInst.val1 + dInst.val3, data: dInst.val2  };

    endcase

    return ExecResult {c2h: c2h, writeVal: writeVal, memReq: memReq};
endfunction