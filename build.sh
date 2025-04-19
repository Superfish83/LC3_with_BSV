#!/bin/bash

cd ./src

base=../build
bdir=${base}/bdir
bindir=${base}/bin
simdir=${base}/simdir

mkdir -p ${bdir}
mkdir -p ${bindir}
mkdir -p ${simdir}

bsc -u -sim -aggressive-conditions -simdir ${simdir} -bdir ${bdir} ./TestBench.bsv
bsc -u -sim -aggressive-conditions -simdir ${simdir} -bdir ${bdir} -o ${bindir}/bsim -e mkTestBench