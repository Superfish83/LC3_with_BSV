package TestBench;

import LC3_Proc::*;
import LC3_ProcTypes::*;

typedef enum {Init, Run, End}
TestState deriving (Bits, Eq);

(* synthesize *)
module mkTestBench(Empty);
    LC3_Proc proc <- mkLC3_Proc;

    Reg#(Bit#(32)) cycle <- mkReg(0);
    Reg#(TestState) tState <- mkReg(Init);
    
    rule initTest (tState == Init);
        proc.hostToCpu(16'h3000);
        tState <= Run;
    endrule

    rule runTest (tState == Run);
        // For debugging, uncomment this to check testbench clock cycle 
        //$display("[TestBench] cycle %d", cycle);

        CpuToHost c2h <- proc.cpuToHost;
        case (c2h.c2hType)
            TV_OUT: begin
                $display("CPU called OUT: x%x", c2h.data);
            end
            TV_HALT: begin
                $display("CPU called HALT. Quitting...");
                tState <= End;
            end
        endcase
        cycle <= cycle + 1;
    endrule

    rule endTest (tState == End);
        $finish;
    endrule

endmodule: mkTestBench

endpackage