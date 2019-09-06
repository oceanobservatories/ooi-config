#!/bin/bash

# make and populate the installation folder with the code in the Git repo
mkdir $PREFIX/stream_engine
cd $SRC_DIR
git submodule update --init --recursive
cp -r * $PREFIX/stream_engine

# set up links in the installation bin folder to key components
if [[ ! -d $PREFIX/bin ]]; then
    mkdir $PREFIX/bin
fi
cd $PREFIX/bin
ln -s ../stream_engine/manage-streamng manage-streamng
