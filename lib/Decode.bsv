import LC3_Types::*;

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

    // Decode result (initially undefined)
    DecodedInst dInst = ?;
    dInst.opcode = opcode;
    dInst.immFlag = (inst[5]==1);

    case(opcode)
        // Arithmetic & Logic Instructions
        opAdd, opAnd, opNot: begin
            dInst.rd    = rd;   // destination
            dInst.rs1   = rs1;  // source 1
            dInst.rs2   = rs2;  // source 2 (optional)
            dInst.imm  = signExtend(imm5); // immediate (optional)
        end

        // Control Instructions
        //      * todo: BR, JMP, JSR, JSRR
        opTrap: begin
            dInst.rs1   = rs1;  // Always 0
            dInst.imm[7:0] = extend(trapv); // Trapvect
        end

        // Load & Store Instructions
        //      * todo: LDI, STI
        opLd, opLdr, opLea, opSt, opStr: begin
            dInst.rd = rd;  // DR (for ld, ldr, lea)
            dInst.rs2 = rd; // SR (for st, str)
            case(opcode) // val3 <- desired memory address
                opLdr, opStr: begin
                    dInst.rs1 = rs1; // BaseR
                    dInst.imm = signExtend(offset6); // offset from BaseR
                end
                default: dInst.imm = (pc+1) + signExtend(offset9); // pc+1 + offset
            endcase
        end
        
        default: begin
            //
        end
    endcase

    return dInst;
endfunction
