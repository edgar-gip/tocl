#!/bin/sh
octave -p ${CLSYSPATH}/octave -p ${CLSYSPATH}/octave/combination -p ${CLSYSPATH}/octave/io -p ${CLSYSPATH}/octave/measures -q ${CLSYSPATH}/octave/combineEM.m $@
