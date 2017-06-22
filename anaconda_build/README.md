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
