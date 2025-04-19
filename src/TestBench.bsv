package TestBench;

import LC3_Proc::*;

typedef enum {Init, Run, End}
TestState deriving (Bits, Eq);

(* synthesize *)
module mkTestBench(Empty);
    LC3_Proc proc <- mkLC3_Proc;

    Reg#(Bit#(32)) cycle <- mkReg(0);
    Reg#(TestState) tState <- mkReg(Init);
    
    rule initTest (tState == Init);
        proc.hostToCpu('h3000);
        tState <= Run;
    endrule

    rule runTest (tState == Run);
        $display("[TestBench] cycle %d", cycle);

        CpuToHost c2h <- proc.cpuToHost;
        case (c2h.c2hType)
            PrintInt: begin
                $display("CPU: %x", c2h.data);
            end
            ExitCode: begin
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