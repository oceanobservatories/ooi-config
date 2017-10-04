#!/bin/bash

# make and populate the installation folder with the code in the Git repo
mkdir $PREFIX/ingest_engine
cd $SRC_DIR
cp -r * $PREFIX/ingest_engine

# set up links in the installation bin folder to key components
cd $PREFIX/bin
ln -s ../ingest_engine/manage-ingestng manage-ingestng
ln -s ../ingest_engine/manage-ingest-handler manage-ingest-handler
