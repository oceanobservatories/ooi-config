# OOI Anaconda Build Definitions

## Setup for building

1. Install [miniconda](http://conda.pydata.org/miniconda.html)
    
2. Install the anaconda build packages

```
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

## Building a package for production

1. Create the package, if it does not already exist

`$ anaconda -t $TOKEN package --create <ORGANIZATION>/<PACKAGENAME>`
 
2. Submit the package build to the build queue

`$ anaconda -t $TOKEN build submit --label main`

## Building a package for dev/test

1. Create the package, if it does not already exist

`$ anaconda -t $TOKEN package --create <ORGANIZATION>/<PACKAGENAME>`
 
2. Submit the package build to the build queue

`$ anaconda -t $TOKEN build submit --label dev`
