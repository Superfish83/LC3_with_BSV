package TestBench;

import LC3_Proc::*;
import LC3_Types::*;

typedef enum {Init, Run, SysIn, Getc, Puts, End}
TestState deriving (Bits, Eq);

(* synthesize *)
module mkTestBench(Empty);
    String program_path = "../programs/program.vmh";
    String input_path = "../programs/input.dat";
    Reg#(File) inputFile <- mkReg(?); 

    Bool debugMode = False;

    LC3_Proc proc <- mkLC3_Proc(program_path, input_path, debugMode);

    Reg#(Bit#(32)) cycle <- mkReg(0);
    Reg#(TestState) tState <- mkReg(Init);
    
    rule initTest (tState == Init);
        proc.hostToCpu(tagged Valid 16'h3000, tagged Invalid);
        tState <= Run;
        
        let f <- $fopen(input_path, "r");
        inputFile <= f;
    endrule

    rule runSysIn (tState == SysIn);
        let i <- $fgetc(inputFile);
        $display("Input> %c", i);
        if(debugMode) $display("CPU called IN: %c", i);
        
        Data iData = truncate(pack(i));
        proc.hostToCpu(tagged Invalid, tagged Valid iData);
        tState <= Run;
    endrule
    
    rule runGetC (tState == Getc);
        let i <- $fgetc(inputFile);
        if(debugMode) $display("CPU called GETC: %c", i);
        
        Data iData = truncate(pack(i));
        proc.hostToCpu(tagged Invalid, tagged Valid iData);
        tState <= Run;

    endrule

    rule runTest (tState == Run);
        let c2h <- proc.cpuToHost();

        if(isValid(c2h)) begin
            let c2hType = fromMaybe(?, c2h).c2hType;
            let data = fromMaybe(?, c2h).data;
            case (c2hType)
                TV_IN: begin
                    tState <= SysIn;
                end
                TV_OUT: begin
                    if (debugMode) $display("CPU called OUT: %c", data);
                    else $write("%c", data);
                end
                TV_GETC: begin
                    tState <= Getc;
                end
                TV_HALT: begin
                    $display("\nCPU called HALT. Quitting...");
                    tState <= End;
                end
            endcase
        end
        cycle <= cycle + 1;
    endrule

    rule endTest (tState == End);
        $finish;
    endrule

endmodule: mkTestBench

endpackage