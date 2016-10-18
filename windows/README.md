## OpenQuake installers for Windows ##

Work in progress.

### Requirements

- WINE: https://www.winehq.org/
- NSIS: http://nsis.sourceforge.net/Main_Page
- The OQ python dependencies: http://ftp.openquake.org/windows/oq-engine/

Microsoft Windows is not required.

#### Setup python (32bit)
- `export WINEPREFIX=/home/user/path/to/my/prefix`
- `export WINEARCH=win32`
- `wget https://www.python.org/ftp/python/2.7.12/python-2.7.12.msi`
- `wine msiexec /a python-2.7.12.msi /qb TARGETDIR=python2.7`
- Untar the downloaded dependencies in `lib`

#### Setup python (64bit)
- `export WINEPREFIX=/home/user/path/to/my/prefix`
- `wget https://www.python.org/ftp/python/2.7.12/python-2.7.12.amd64.msi`
- `wine msiexec /a python-2.7.12.amd64.msi /qb TARGETDIR=python2.7`

#### Setup build environment
- in `regedit` add to `HKEY_CURRENT_USER\Environment\PATH`: `C:\Python27:C:\Program Files (x86)\NSIS`
- Untar the downloaded dependencies in `lib`

### Setup OpenQuake
- `cd oq-hazardlib; wine python setup.py build`
- copy build to lib
- `cd oq-engine; wine python setup.py build`
- copy build to lib
- copy `demos` and the `openquake.cfg` from oq-engine to the project root
- run NSINS:` wine makensis installer.nsi`

### Open issues

See https://github.com/gem/oq-installers/issues
