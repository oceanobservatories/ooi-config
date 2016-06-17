#!/bin/bash

$PYTHON setup.py install build build_ext -I${PREFIX}/include -L${PREFIX}/lib
