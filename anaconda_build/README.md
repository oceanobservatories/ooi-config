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

* Note that numpy=1.16 is now used for stream_engine, ion_functions, and ooi-data.
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
$ git config --global http.postBuffer 2097152000
```

An environment is provisioned with the dependencies specified in the enginemeta recipe and either or both of the repositories from the ingest_engine and stream_engine recipes (depending on which packages are specified; here both are specified) and activated for use. The environment name is flexible; here it's specified as *engine*

```bash
$ conda create -n engine enginemeta ingest_engine stream_engine
$ source activate engine
```

The management scripts can be run from within this environment as

```bash
$ manage-ingestng (or manage-streamng) start (or stop, etc.)
$ manage-ingest-handler start (or stop, etc.) playback (or recovered or telemetered)
```

The scripts generate log files within the *logs* sub-folder under the folder physically containing the "manage" scripts. The primary file for the ingest_engine script is *ingest_engine.error.log*. The primary file for the stream_engine script is *stream_engine.error.log*.
  
The environment can be deactivated and removed as

```bash
source deactivate
conda remove -n engine --all
```

## The other recipes 

* *ion-functions*: It's used for stream_engine during QC testing. It may also be used in other ways.
* *mi-instrument*: It's used for ingest_engine during data ingest.
* *ooi-status*: It's used to check data availability.
* *apscheduler*: It's used by mi-instrument and ooi-status. APScheduler (Advanced Python Scheduler) is a light, powerful in-process task scheduler used to schedule functions or python callables to run at specified times.
* *concurrentloghandler*: Used by ingest_engine and stream_engine to provide rolling logs that are concurrently accessible.
* *geomag*: Used by ion-functions to calculate magnetic variation/declination for any lat/lon/altitude and date using the National Geophsical Data Center, epoch 2015 data.
* *jsl*: a DSL for describing JSON schemas
* *libgswteos*: Used by pygsw and ion-functions. It draws from the oceanobservatories GSW-C repository. It invovles TEOS-10 (Thermodynamic Equation of Seawater - 2010) which is about thermodynamic properties of seawater (density, enthalpy, entropy).
* *ntplib*: Used by mi-instrument. It's an API to query NTP (network time protocol, for providing clock synchronization for computer systems) servers from python, providing utility functions to translate NTP field values to text.
* *ooi-data*: Used by stream_engine. Uses the oceanobservatories repository by same name. It appears to define the Postgres data model used by sqlalchemy.
* *ooi-instrument-agent*: Not sure but may be OBE due to ooi-port-agent
* *ooi-mission-executive*: Uses the oceanobservatories repository by same name. It appears to involve instrument agent drivers
* *ooi_port_agent*: Used by stream_engine. Uses the oceanobservatories repository by same name. It communicates between the cabled instruments and the Instrument Agent Drivers. It uses RabbitMQ messaging to pass data between them.
* *psycogreen*: Used by ooi-status to enable psycopg2 to work with coroutine libraries (via internal asynchronous calls) with a blocking interface so regular code can run unmodified.
* *pygsw*: Used by ion-functions. Uses the oceanobservatories repository by same name. It uses libgswteos to provide python bindings for the TEOS-10 v3.0.3 GSW Oceanographic Toolbox in C.
* *pysmb*: Used by ooi_port_agent. It's an experiential SMB/CIFS python library that supports file sharing between Linux and Windows platforms.
* *pysoundfile*: An audio library used to read/write sound files
* *python-consul*: Used by mi-instrument and ooi-instrument-agent. It's a python API to Consul.
* *qpid-python*: Used by mi-instrument. It's python API to Qpid.
* *setuptools_cython*: Used by ion-functions. It's a superset of python that gives C-like performance with code written mostly in python.
* *sure*: An idiomatic testing library for python. Unsure if it's used in OOI as Nose is used extensively.
* *tqdm*: Used by mi-instrument to provide efficient progress meters on any iterable python construct.
