import LC3_ProcTypes::*;

function ExecResult execute(DecodedInst dInst);
    let no_c2h = CpuToHost {c2hType: NO_SIGNAL, data: ?};
    CpuToHost c2h = no_c2h;
    Maybe#(Data) writeVal = tagged Invalid;
    
    case(dInst.opcode)
        // Arithmetic $ Logic Instructions
        opAdd: begin
            writeVal = tagged Valid ( fromMaybe(?, dInst.val1) + fromMaybe(?, dInst.val2) );
            //$display("source values: val1:%x, val2:%x", val1, val2);
        end
        opAnd: begin
            writeVal = tagged Valid ( fromMaybe(?, dInst.val1) + fromMaybe(?, dInst.val2) );
            //$display("source values: val1:%x, val2:%x", val1, val2);
        end
        opNot: begin
            writeVal = tagged Valid ( ~fromMaybe(?, dInst.val1) );
            //$display("source values: val1:%x", val1);
        end

        // Control Instructions
        opTrap: begin
            case(fromMaybe(?, dInst.val3)[7:0])
                tvOut:  c2h = CpuToHost {c2hType: TV_OUT, data: fromMaybe(?, dInst.val1)};
                tvHalt: c2h = CpuToHost {c2hType: TV_HALT, data: ?};
            endcase
        end

        // Load & Store Instructions

    endcase

    return ExecResult {c2h: c2h, writeVal: writeVal};
endfunction