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

// LC3 convention addresses
Addr  lc3_ORIG  = 16'h3000;
Addr  lc3_END   = 16'hFDFF;

// cpu to host
typedef enum { ExitCode, PrintChar, PrintInt, PrintHex }
CpuToHostType deriving (Bits, Eq);
typedef struct {
    CpuToHostType c2hType;
    Bit#(16) data;
} CpuToHost deriving (Bits, Eq);