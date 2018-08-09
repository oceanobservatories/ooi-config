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
    * save this token for subsequent use, but don't commit it to the repo!
    * use it every time you upload using this account for the organization
    
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

## Wrap-up after building

After building and uploading of packages is complete, terminate the anaconda session by logging out.

`$ anaconda logout`

## Installation of a package

Packages are installed using `conda` by downloading them from the anaconda cloud. Packages should be installed under 
the root environment on the deployment machine, however the can also be installed under a virtual environment for
local development. E.g. on uframe-3-test, mi-instrument is installed under the root environment:

```bash
$ conda install mi-instrument
```

## The stream/ingest recipes, packages and environment

These recipes are located in the *enginemeta*, *ingest_engine* and *stream_engine* folders. The enginemeta recipe declares the dependencies required for use in an environment that can be used to run the code obtained from the ingest_engine and stream_engine recipes. Modify it only as those dependencies change.

The ingest_engine and stream_engine recipes declare the enginemeta package as a dependency. The packages built from them are named the same as the recipes. They obtain and install their respective Git repositories from a tagged checkout point (that's specified in the recipe) into their respective packages:

* ssh://uframe-cm.ooi.rutgers.edu:29418/ingest_engine
* https://github.com/oceanobservatories/stream_engine

These recipes must be obtained from [this repository](https://github.com/oceanobservatories/ooi-config), modified as needed and built locally from the anaconda_build folder as 

```bash
$ conda build enginemeta
$ conda build ingest_engine
$ conda build stream_engine
```

It's possible the last of the 3 of the above commands will fail with the following error
* error: RPC failed; result=52 HTTP code=0

If that occurs do a Ctrl-C to exit and then run the following command prior to retrying the build command
```bash
$ git config --global http.postBuffer 1048576000
```

An environment is provisioned with the dependencies specified in the enginemeta recipe and either or both of the repositories from the ingest_engine and stream_engine recipes (depending on which packages are specified; here both are specified) and activated for use. The environment name is flexible; here it's specified as *engine*

```bash
$ conda create --use-local -n engine ingest_engine stream_engine
$ source activate envname
```

The management scripts can be run from within this environment as

```bash
$ manage-ingestng (or manage-streamng) start (or stop, etc.)
```

The scripts generate log files within the *logs* sub-folder under the folder physically containing the "manage" scripts. The primary file for the ingest_engine script is *ingest_engine.error.log*. The primary file for the stream_engine script is *stream_engine.error.log*.
  
The environment can be deactivated and removed as

```bash
source deactivate
conda remove -n envname --all
```
