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
    let n        = inst[11];
    let z        = inst[10];
    let p        = inst[9];

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
            dInst.imm   = signExtend(imm5); // immediate (optional)
        end

        // Control Instructions
        opBr: begin
            dInst.rd    = rd;  // the nzp value goes here.
            dInst.rs1   = ?;  
            dInst.rs2   = ?;
            dInst.imm   = signExtend(offset9);
        end

        opJmp: begin
            dInst.rd    = ?;
            dInst.rs1   = rs1;  // JMP destination
            dInst.rs2   = ?;
            dInst.imm   = ?; 
        end

        opJsr: begin
            let jsrFlag = inst[11];  // 0: JSRR  1: JSR 
            dInst.rd    = ?;
            dInst.rs1   = jsrFlag==0 ? rs1 : ?;  // JMP destination
            dInst.rs2   = ?;
            dInst.imm   = jsrFlag==1 ? signExtend(offset11) : ?;
            dInst.immFlag = (jsrFlag==1);  // Abuse of variable. (Caused by limitation of LC3)
        end                                // Better to reorganize the decoding structure or use Maybe to check validity of rs1 in the execution stage.

        opTrap: begin
            dInst.rd    = ?;
            dInst.rs1   = rs1;  // Always 0
            dInst.rs2   = ?;
            dInst.imm[7:0] = extend(trapv); // Trapvect
        end

        // Load & Store Instructions
        // DR and SR is assigned to rs1, BaseR is assigned to rs2.
        opLd, opLdr, opLdi, opLea, opSt, opStr, opSti: begin
            dInst.rd = rd;  // DR (for ld, ldr, lea)
            dInst.rs1 = rd; // SR (for st, str)
            case(opcode) // imm <- desired memory address
                opLdr, opStr: begin
                    dInst.rs2 = rs1; // BaseR
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
