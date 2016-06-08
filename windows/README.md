## OpenQuake installers for Windows ##

Work in progress. Not suitable for production. Use at your own risk.

### Requirements

- WINE: https://www.winehq.org/
- NSIS: http://nsis.sourceforge.net/Main_Page
- The OQ python dependencies: http://ftp.openquake.org/windows/oq-engine/

Microsoft Windows is not required.

#### Setup python
- wget https://www.python.org/ftp/python/2.7.11/python-2.7.11.msi
- wine msiexec /a python-2.7.11.msi /qb TARGETDIR=python2.7
- Untar the downloaded dependencies in `lib`

### Setup OpenQuake
- cd oq-hazardlib; wine python setup.py build --compiler=mingw32
- copy build and seppedups (inside geo)
- cd oq-engine; wine python setup.py build --compiler=mingw32
- copy builda
- copy `demos` and the `openquake.cfg` from oq-engine to the project root

### Open issues

See https://github.com/gem/oq-nsis/issues