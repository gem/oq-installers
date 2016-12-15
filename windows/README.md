## OpenQuake installers for Windows ##

Work in progress.

### Requirements

- WINE: https://www.winehq.org/
- NSIS: http://nsis.sourceforge.net/Main_Page
- The OQ python dependencies: http://ftp.openquake.org/windows/oq-engine/

Microsoft Windows is not required.

### Setup WINE prefix
- `export WINEPREFIX=/home/user/path/to/my/prefix`
- `cd src`
- `wget https://www.python.org/ftp/python/2.7.12/python-2.7.12.amd64.msi`
- `wine msiexec /i python-2.7.12.amd64.msi`
- in `regedit` add to `HKEY_CURRENT_USER\Environment\PATH`: `C:\Python27:C:\Program Files (x86)\NSIS`
- `wine pip install wheel`

### Dependencies

#### OpenQuake
- `cd src`
- `git clone https://github.com/gem/oq-hazardlib.git`
- `git clone https://github.com/gem/oq-engine.git`

#### Python
- `cd src`
- `wine msiexec /a python-2.7.12.amd64.msi /qb TARGETDIR=..\python-dist\python2.7`

#### Libs
- `cd python-dist`
- `wine pip install --force-reinstall --ignore-installed --upgrade --no-index --prefix . ../src/py/*.whl ../src/py27/*.whl ../src/oq-hazardlib ../src/oq-engine`

### Setup OpenQuake
- `cp -r src/oq-engine/demos ..`
- `cp -r src/oq-engine/openquake.cfg ..`
- run NSIS:` wine makensis installer.nsi`

### Open issues

See https://github.com/gem/oq-installers/issues
