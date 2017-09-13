# OOI Anaconda Build Definitions

## Setup for building

1. Install [miniconda](http://conda.pydata.org/miniconda.html)
    
2. Install the anaconda build packages

```bash
$ conda update conda
$ conda install conda-build anaconda-client anaconda-build
```
    
3. Login
    * Create an account on http://anaconda.org if you haven't already
    
`$ anaconda login`

4. Create a token
    * you can skip this step if you are not uploading to an organization
    * save this token for next time, but don't commit it to the repo!
    
```bash
$ export TOKEN=$(anaconda auth -o ooi --create --name <TOKENNAME>)
```

where `TOKENNAME` can be set to any user-preferred value.

## Building a package for release

First time only, create the package (we are using the `ooi` organization). E.g. to create the `mi-instrument` package for 
the first time:

```bash
$ anaconda -t $TOKEN package --create ooi/mi-instrument
```

1. Build the package

Conda builds are mananged in this project (`ooi-config`) for each OOI project. E.g. to create the mi-instrument build:

```bash
$ conda build --numpy=1.12 ~/ooi-config/anaconda_build/mi-instrument
```

* Note that numpy is only required for some packages. For those packages, omit the numpy option.

This will install the mi-instrument package in the miniconda installation folder based on the local platform, package name,
and package version, e.g. building version 0.4.0 of mi-instrument on a Mac will yield 
`~/miniconda/conda-bld/osx-64/mi-instrument-0.4.0-py27_0.tar.bz2`

2. Create platform specific packages

We need to have `linux-64` and `osx-64` builds to support our developer and deployment users. E.g. if you had created a 
build on a Mac (`osx-64`) you would create the build for CentOS (`linux-64`) using the following command:

```bash
$ conda convert --platform linux-64 ~/miniconda/conda-bld/osx-64/mi-instrument* -o ~/miniconda/conda-bld
```

3. Upload the package

```bash
$ anaconda -t $TOKEN upload ~/miniconda/conda-bld/*/mi-instrument-0.4.0-py27_0.tar.bz2
```

## Installation of a package

Packages are installed using `conda` by downloading them from the anaconda cloud. Packages should be installed under 
the root environment on the deployment machine, however the can also be installed under a virtual environment for
local development. E.g. on uframe-3-test, mi-instrument is installed under the root environment:

```bash
$ conda install mi-instrument
```

## The stream/ingest engines and environment

The recipes are located in the <i>enginemeta</i>, <i>ingestEngine</i> and <i>streamEngine</i> folders. The enginemeta recipe declares the dependencies used while installing the packages built from the other recipes (ingestEngine and streamEngine). Modify it only as those dependencies change. The other recipes are based on the whole codebases via clones of the following Git repositories.

* git clone ssh://uframe-cm.ooi.rutgers.edu:29418/ingest_engine
* git clone https://github.com/oceanobservatories/stream_engine

The ingestEngine and streamEngine recipes declare the enginemeta package as a dependency. When built, these recipes expect the code from the corresponding repositories to be pulled into the builder's $HOME/uframes/engines folder and the appropriate checkout locations activated as

```bash
$ cd $HOME/uframes/engines/stream_engine
$ git fetch
$ git checkout v1.3.7
$ git submodule update --init --recursive
$ cd $HOME/uframes/engines/ingest_engine
$ git fetch
$ git checkout build_8.0_20170630
```

Once done they need to be TAR/bzip'd there. Whenever the code bases represented by these repositories are modified, these TARs need to be updated. Use the following commands to TAR/bzip them

```bash
$ tar jcf ingest_engine.tar.bz2 ingest_engine
$ tar jcf stream_engine.tar.bz2 stream_engine
```

Each of these recipes is used to create a package when running these commands from the folder containing these recipes

```bash
$ conda build enginemeta
$ conda build ingestEngine
$ conda build streamEngine
```

An environment is built and activated with the dependencies specified in the enginemeta recipe and either or both of the repositories from the ingestEngine and streamEngine recipes as (where <i>envname</i> represents a name to specify for the environment)

```bash
$ conda create --use-local -n envname [ingest_engine stream_engine]
source activate envname
```

The management scripts can be run from within this environment as

```bash
$ cd $CONDA_PREFIX/ingest_engine (or stream_engine)
$ manage-ingestng (or manage-streamng) start (or stop, etc.)
```

The environment can be deactivated and removed as

```bash
source deactivate
conda remove -n engine --all
```
