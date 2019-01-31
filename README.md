# Builders for OpenQuake [![Build Status](https://travis-ci.org/gem/oq-containers.svg?branch=master)](https://travis-ci.org/gem/oq-container)

<img align="left" src="https://github.com/gem/oq-infrastructure/raw/master/logos/oq-logo.png" width="400px">

Powered by
<img src="https://upload.wikimedia.org/wikipedia/commons/7/79/Docker_%28container_engine%29_logo.png" width="100px">

* Windows NSIS builder
* Linxu/macOS (env) standalone builder
* Linux (opt) standalone installer

### Internals

* Jenkins' Docker containers
* wheel builders


## Testing on Travis

All the builders and installers are tested via Travis + Docker with the following logic:

- master branch: all the tests are run. Build may take a while
- other branches: no tests are run unless one of these tags are added to the commit message
   - `[WHEELS]`: run wheels builder
   - `[UNIX]`: build unix installers (env/opt)
   - `[WIN]`: build NSIS Windows installer

