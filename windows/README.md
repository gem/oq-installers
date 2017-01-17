## OpenQuake installers for Windows ##

Work in progress.

### Requirements

- WINE: https://www.winehq.org/
- Python: https://www.python.org/
- NSIS: http://nsis.sourceforge.net/Main_Page
- OQ python dependencies: http://ftp.openquake.org/wheelhouse/windows
- Python markdown: https://pypi.python.org/pypi/Markdown

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
- `cd oq-engine`
 - `wine python install bdist_wheel -d ..`
- `cd oq-hazardlib`
 - `wine python install bdist_wheel -d ..`

#### Python
- `cd src`
- `wine msiexec /a python-2.7.12.amd64.msi /qb TARGETDIR=../python-dist/python2.7`

#### Libs
- `wine pip install --force-reinstall --ignore-installed --upgrade --no-index --prefix python-dist src/py/*.whl src/py27/*.whl src/openquake.*.whl`

Setup of the sole `oq-engine` and `oq-hazardlib` can be done adding `--no-deps` to the command above.

### Setup OpenQuake
- `cp -r src/oq-engine/demos .`
- `cp -r src/oq-engine/openquake.cfg .`
- `python -m markdown src/oq-engine/README.md > README.html`
- run NSIS:` wine makensis /V4 installer.nsi`

### Open issues

#### Errors making wheels

An error like this

```python
Traceback (most recent call last):
  File "setup.py", line 122, in <module>
    zip_safe=False,
  File "C:\Python27\lib\distutils\core.py", line 151, in setup
    dist.run_commands()
  File "C:\Python27\lib\distutils\dist.py", line 953, in run_commands
    self.run_command(cmd)
  File "C:\Python27\lib\distutils\dist.py", line 972, in run_command
    cmd_obj.run()
  File "C:\Python27\lib\site-packages\wheel\bdist_wheel.py", line 236, in run
    self.write_record(self.bdist_dir, self.distinfo_dir)
  File "C:\Python27\lib\site-packages\wheel\bdist_wheel.py", line 441, in write_record
    relpath = os.path.relpath(path, bdist_dir)
  File "C:\Python27\lib\ntpath.py", line 529, in relpath
    % (path_prefix, start_prefix))
ValueError: path is on drive , start on drive Z:
```

means that the source code folder has a path which is too deep. Try saving sources in a less deep path (like `C:\Temp`).

See also https://github.com/gem/oq-installers/issues
