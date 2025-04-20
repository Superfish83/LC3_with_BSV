/*
    Proc.bsv: The LC-3 Processor
*/

package LC3_Proc;

// Define type of Address and Word
typedef Bit#(16)    Addr;
typedef Bit#(16)    Word;

// Define types related to instructions
typedef Bit#(16)    Inst;
typedef Bit#(4)     Opcode;
typedef Bit#(3)     RIndx;
typedef Bit#(6)     Offset6;
typedef struct {
    Opcode opcode;
    Maybe#(RIndx) dst;
    Maybe#(RIndx) src1;
    Maybe#(Offset6) offset;
} DecodedInst deriving (Bits, Eq);

// Define LC-3 Opcodes
//  - Arithmetic & Logic
Opcode opAdd    = 4'b0001;
Opcode opAnd    = 4'b0101;
Opcode opNot    = 4'b1001;
//  - Control
Opcode opBr     = 4'b0000;
Opcode opJmp    = 4'b1100;
Opcode opJsr    = 4'b0100;
Opcode opRet    = 4'b1100;
Opcode opRti    = 4'b1000;
Opcode opTrap   = 4'b1111;
//  - Load/Store
Opcode opLd     = 4'b0010;
Opcode opLdi    = 4'b1010;
Opcode opLdr    = 4'b0110;
Opcode opLea    = 4'b1110;
Opcode opSt     = 4'b0011;
Opcode opSti    = 4'b0011;
Opcode opStr    = 4'b0011;

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
typedef enum { ExitCode, PrintChar, PrintInt }
CpuToHostType deriving (Bits, Eq);
typedef struct {
    CpuToHostType c2hType;
    Bit#(16) data;
} CpuToHost deriving (Bits, Eq);


(* synthesize *)
module mkLC3_Proc(LC3_Proc);
    Reg#(Bool) running <- mkReg(False);
    Reg#(Addr) pc <- mkRegU;
    /*
    RFile       rf <- mkRFile;
    IMemory     iMem <- mkIMemory;
    DMemory     dMem <- mkDMemory;*/

    rule doProc (running);
        /*
        let inst = iMem.req(pc);
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
            c2h.c2hType = PrintInt;
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