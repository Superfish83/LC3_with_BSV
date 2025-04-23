// Define type of Address and Word
typedef Bit#(16)    Addr;
typedef Bit#(16)    Data;

// Define types related to instructions
typedef Bit#(16)    Inst;
typedef Bit#(4)     Opcode;
typedef Bit#(3)     RIndx;
// typedef enum {N, Z, P}       // nzp can appear multiple times. e.g. BRnz
// BrCond deriving (Bits, Eq);  // not used
typedef struct {
    Opcode  opcode;
    RIndx   rd;
    RIndx   rs1;
    RIndx   rs2;
    Data    imm;
    Bool    immFlag;
} DecodedInst deriving (Bits, Eq);

typedef struct {
    Opcode opcode;
    RIndx dst;
    Data data;
    Addr addr;
} ExecInst deriving(Bits, Eq);

Bit#(3) nMask = 3'b100;
Bit#(3) zMask = 3'b010;
Bit#(3) pMask = 3'b001;

// LC-3 Opcodes
//  - Arithmetic & Logic
Opcode opAdd    = 4'b0001;
Opcode opAnd    = 4'b0101;
Opcode opNot    = 4'b1001;
//  - Control
Opcode opBr     = 4'b0000;
Opcode opJmp    = 4'b1100;
Opcode opJsr    = 4'b0100;
Opcode opRti    = 4'b1000;
//  - Load/Store
Opcode opLd     = 4'b0010;
Opcode opLdi    = 4'b1010;
Opcode opLdr    = 4'b0110;
Opcode opLea    = 4'b1110;
Opcode opSt     = 4'b0011;
Opcode opSti    = 4'b1011;
Opcode opStr    = 4'b0111;
Opcode opTrap   = 4'b1111;

// CPU to Host type
typedef enum { TV_GETC, TV_OUT, TV_PUTS, TV_IN, TV_HALT }
CpuToHostType deriving (Bits, Eq);
typedef struct {
    CpuToHostType c2hType;
    Bit#(16) data;
} CpuToHost deriving (Bits, Eq);

// Execution Result
typedef struct {
    Maybe#(CpuToHost)   c2h;
    Maybe#(Data)        writeVal;
    Maybe#(MemRequest)  memReq;
} ExecResult deriving (Bits, Eq);

// TRAP Vectors
typedef Bit#(8) Trapvect;
Trapvect tvGetc = 8'h20;
Trapvect tvOut  = 8'h21;
Trapvect tvPuts = 8'h22;
Trapvect tvIn   = 8'h23;
Trapvect tvHalt = 8'h25;


// Memory Request & Response Types
typedef struct {
    Bool    writeMem;
    Addr    addr;
    Data    data;
} MemRequest deriving (Bits, Eq);

typedef struct {
    Data    data;
} MemResponse deriving (Bits, Eq);


// Instruction addresses
Addr  lc3_IMem_ORIG  = 16'h3000;
Addr  lc3_IMem_END   = 16'hfdff;
// Data addresses
Addr  lc3_DMem_ORIG  = 16'h3000; //16'hf000;
Addr  lc3_DMem_END   = 16'hfdff; //16'hfdff;
