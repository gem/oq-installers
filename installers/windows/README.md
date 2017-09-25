## OpenQuake installers for Windows ##

### Requirements

- WINE: https://www.winehq.org/
- Python: https://www.python.org/
- NSIS: http://nsis.sourceforge.net/Main_Page
- OQ python dependencies: http://ftp.openquake.org/wheelhouse/windows
- Python markdown: https://pypi.python.org/pypi/Markdown

Microsoft Windows is not required.

### Build with Docker

#### Build Docker image
```bash
$ docker build --build-arg uid=$(id -u) --rm=true -t f26-wine -f docker/Dockerfile .
```
### Run the container
```bash
$ docker run -v $(pwd):/io -t -i --rm f26-wine
```

#### Custom branches
```bash
$ docker run -e GEM_SET_BRANCH=branch -e GEM_SET_BRANCH_TOOLS=branch -v $(pwd):/io -t -i --rm f26-wine
```
otherwise `master` is used.

### Manual installation 

#### Setup WINE prefix
- `export WINEPREFIX=/home/user/path/to/my/prefix`
- `cd src`
- `wget https://www.python.org/ftp/python/2.7.13/python-2.7.13.amd64.msi`
- `wine msiexec /i python-2.7.12.amd64.msi`
- `wine pip install wheel`

#### OpenQuake
- `cd src`
- `git clone [-b mybranch] https://github.com/gem/oq-hazardlib.git`
- `git clone [-b mybranch] https://github.com/gem/oq-engine.git`

#### Libs
- Download `py` and `py27` from the internal repo and put it into `src`

#### Run the builder
- `docker/build.sh`

### Errors making wheels

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
