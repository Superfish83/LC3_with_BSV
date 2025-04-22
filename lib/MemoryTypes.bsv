import LC3_ProcTypes::*;

typedef struct {
    Bool    write;
    Addr    addr;
    Data    data;
} MemRequest deriving (Bits, Eq);

typedef struct {
    Data    data;
} MemResponse deriving (Bits, Eq);


// Instruction addresses
Addr  lc3_IMem_ORIG  = 16'h3000;
Addr  lc3_IMem_END   = 16'h3dff;
// Data addresses
Addr  lc3_DMem_ORIG  = 16'hf000;
Addr  lc3_DMem_END   = 16'hfdff;