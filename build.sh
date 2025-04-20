#!/bin/bash

cd ./src

if [ "$1" = "run" ];
then
    echo "Running simulation...";
    ./build/bin/bsim;
else
    base=../build
    bdir=${base}/bdir

    if [ "$1" = "sim" ];
    then
        bindir=${base}/bin
        simdir=${base}/simdir

        mkdir -p ${bdir}
        mkdir -p ${bindir}
        mkdir -p ${simdir}

        bsc -u -sim -aggressive-conditions -simdir ${simdir} -bdir ${bdir} ./TestBench.bsv
        bsc -u -sim -aggressive-conditions -simdir ${simdir} -bdir ${bdir} -o ${bindir}/bsim -e mkTestBench
        echo "Build complete! Enter 'bash build.sh run' to run simulation."
    elif [ "$1" = "verilog" ];
    then
        vdir=${base}/verilog

        mkdir -p ${vdir}

        bsc -u -verilog -aggressive-conditions -bdir ${bdir} ./TestBench.bsv
        mv -v ./*.v ${vdir}

        echo "Build complete! The complied .v files are at ./build/verilog."
    else
        echo "error"
    fi
fi
