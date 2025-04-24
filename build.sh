#!/bin/bash

cd ./src

if [ "$1" = "run" ];
then
    echo "[build.sh] Running simulation...";
    echo "";
    ./../build/bin/bsim;
    echo "";
    echo "[build.sh] Simulation is over."
else
    base=../build
    bdir=${base}/bdir
    libdir=../lib

    if [ "$1" = "sim" ];
    then
        echo "[build.sh] Building for simulation...";
        echo "";

        bindir=${base}/bin
        simdir=${base}/simdir

        mkdir -p ${bdir}
        mkdir -p ${bindir}
        mkdir -p ${simdir}

        bsc -u -sim -aggressive-conditions -simdir ${simdir} -p +:${libdir} -bdir ${bdir} ./TestBench.bsv
        bsc -u -sim -aggressive-conditions -simdir ${simdir} -p ${libdir}:+ -bdir ${bdir} -o ${bindir}/bsim -e mkTestBench
        
        echo "";
        echo "[build.sh] Build complete! Enter 'bash build.sh run' to run simulation."
    elif [ "$1" = "verilog" ];
    then
        echo "[build.sh] Compiling to Verilog files...";
        echo "";
        
        vdir=${base}/verilog

        mkdir -p ${vdir}
        
        bsc -u -verilog -aggressive-conditions -bdir ${bdir} -p ${libdir}:+ ./TestBench.bsv
        mv -v ./*.v ${vdir}
        mv -v ${libdir}/*.v ${vdir}
        primitives_v_dir="/opt/tools/bsc/latest/lib/Verilog";
        cp ${primitives_v_dir}/RegFile.v ${vdir}

        echo "";
        echo "[build.sh] The complied .v files are at ./build/verilog."
    else
        echo "error"
    fi
fi
