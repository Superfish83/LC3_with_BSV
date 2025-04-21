import LC3_ProcTypes::*;

function DecodedInst decode(Bit#(16) inst, Addr pc);
    let opcode   = inst[15:12];
    let rd       = inst[11:9];
    let rs1      = inst[8:6];
    let rs2      = inst[2:0];

    let offset6  = inst[5:0];
    let offset9  = inst[8:0];
    let offset11 = inst[10:0];
    
    let imm5     = inst[4:0];
    let trapv    = inst[7:0];
    Bool immFlag = (inst[5]==1);

    // Decode result (initially undefined)
    DecodedInst dInst = ?;
    dInst.opcode = opcode;
    dInst.brCond = Z;
    dInst.rd = tagged Invalid;
    dInst.rs1 = tagged Invalid;
    dInst.rs2 = tagged Invalid;
    dInst.val1 = tagged Invalid; 
    dInst.val2 = tagged Invalid; 
    dInst.val3 = tagged Invalid; 

    case(opcode)

        // Arithmetic & Logic Instructions
        opAdd, opAnd: begin
            dInst.rd = tagged Valid rd;
            dInst.rs1 = tagged Valid rs1;
            dInst.rs2 = immFlag ? tagged Invalid : tagged Valid rs2;
            dInst.val3 = immFlag ? tagged Valid signExtend(imm5) : tagged Invalid;
        end
        opNot: begin
            dInst.rd = tagged Valid rd;
            dInst.rs1 = tagged Valid rs1;
        end

        // Control Instructions
        opTrap: begin
            dInst.rs1 = tagged Valid rs1; // Always 0
            dInst.val3 = tagged Valid extend(trapv); // Trapvect
        end

        // Load & Store Instructions


        default: begin
            // ...
        end
    endcase

    return dInst;
endfunction
