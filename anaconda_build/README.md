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
    
`$ export TOKEN=$(anaconda auth -o <ORGANIZATION> --create --name <TOKENNAME>)`
    (ORGANIZATION=ooi)


## Building a package for release

1. Create the package, if it does not already exist

`$ anaconda -t $TOKEN package --create <ORGANIZATION>/<PACKAGENAME>`
 
2. Build the package

```bash
$ conda build <PACKAGEDIR>  # non-numpy-linked packages
$ conda build --numpy=1.12 <PACKAGEDIR>  # numpy-linked packages
```

3. Upload the package

`$ anaconda -t $TOKEN upload /path/to/package`

## Installation of a package

Packages are installed by name using anaconda and are typically installed under a virtual environment. 
E.g. on uframe-3-test, mi-instrument is installed under the ingest environment:

```bash
$ source activate ingest
$ conda install mi-instrument
```
