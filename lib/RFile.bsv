import LC3_ProcTypes::*;
import Vector::*;

interface RFile;
    method Action write(RIndx rindx, Data data);
    method Data read1(RIndx rindx);
    method Data read2(RIndx rindx);
endinterface

(* synthesize *)
module mkRFile(RFile);
    Vector#(8, Reg#(Data)) rFile <- replicateM(mkReg(0));

    method Action write(RIndx rindx, Data data);
        rFile[rindx] <= data;
    endmethod

    method Data read1(RIndx rindx);
        return rFile[rindx];
    endmethod
    method Data read2(RIndx rindx);
        return rFile[rindx];
    endmethod

endmodule